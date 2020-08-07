// Author Agus Widhiyasa
import 'dart:convert';
import 'dart:io';

import 'pesan.dart';
import 'package:dio/dio.dart' as httpDio;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'exception.dart';

class ApiConfiguration {
  const ApiConfiguration({
    this.baseUrl,
    this.developmentBaseUrl,
    this.productionApiUrl,
    this.developmentApiUrl,
    this.isProduction
  }): assert(baseUrl != null, "Base Url tidak boleh kosong"),
  assert(productionApiUrl != null, "Production URL tidak boleh kosong");

  final String baseUrl;
  final String developmentBaseUrl;
  final String productionApiUrl;
  final String developmentApiUrl;

  /// Set evn path is to __Production__ or __Development__
  final bool isProduction;

  String get apiUrl {
    if (developmentApiUrl == null) {
      return productionApiUrl;
    }

    if (isProduction) {
      return productionApiUrl;
    } else {
      return developmentApiUrl;
    }
  }

  String get urlBase {
    if (developmentBaseUrl == null) {
      return this.baseUrl;
    }
    
    if (isProduction) {
      return this.baseUrl;
    } else {
      return this.developmentBaseUrl;
    }
  }
}

mixin OnInvalidToken {
  void onLogout(String message) {}
}

/// Abstract class for basic api function
class BaseApi {

  BaseApi(ApiConfiguration configuration) {
    if (configuration.developmentApiUrl == null) {
      this._configuration = ApiConfiguration(
        baseUrl            : configuration.baseUrl,
        productionApiUrl   : configuration.productionApiUrl,
        developmentApiUrl  : configuration.developmentApiUrl,
        isProduction       : configuration.isProduction
      );
      this._apiUrl = configuration.productionApiUrl;
    } else {
      this._apiUrl = configuration.isProduction ? configuration.productionApiUrl : configuration.developmentApiUrl;
      this._configuration = configuration;
    }
  }

  @protected
  String           _apiUrl;
  ApiConfiguration _configuration;

  ApiConfiguration  get configuration  => _configuration;
  String            get apiUrl        => _apiUrl; 

  /// Concat [baseUrl] with given [path]
  String baseUrl(String path) => this._apiUrl + path;

  /// Format [param] `Map<String, dynamic>` menjadi form __urlEncoded__
  /// 
  /// contoh dari:
  /// ```
  ///   var data = {
  ///     "data1": "value1",
  ///     "data2": "value2"
  ///   }
  /// ```
  /// menjadi:
  /// 
  /// `data1=value1&data2=value2`
  String fromMapToFormUrlEncoded(Map<String, String> param) {
    var parts = [];
    param.forEach((key, val) {
      parts.add(
          '${Uri.encodeQueryComponent(key)}=${Uri.encodeQueryComponent(val)}');
    });

    return parts.join("&");
  }

  Map<String, String> get formEncodedHeader => {
    'Content-Type': 'application/x-www-form-urlencoded'
  };

  /// Simplified [http.Response] checking.
  /// 
  /// Jika status response == 200 maka parsing data dan check status
  /// jika kosong throw default [CustomException] 
  Map<String, dynamic> _checkingResponse(Response response) {
    // if (!configuration.isProduction) print("JSON Response ${response.body}");
    switch (response.statusCode) {
      case 200:
        var _response = json.decode(response.body);
        if (_response['status'] == 'success') {
          return _response;
        } else {
          throw CustomException(_response['message']);
        }
        break;
      case 401:
        throw CustomException("Token Expired", addInfo: "LOGOUT");
      default: 
        throw CustomException(Pesan.ERR_JARINGAN);
    }
  }
}

/// Default unAuth Api access
class Api extends BaseApi {
  Api(this.configuration) : super(configuration);

  final ApiConfiguration configuration;


  /// Simplified post to api call
  /// 
  /// [url] akan langsung di concat dengan base url
  Future<Map<String, dynamic>> postToApi(String url, { Map<String, String> postParams }) async {
    var body = fromMapToFormUrlEncoded(postParams);
    try {
      var response = await post(
        baseUrl(url), 
        body: body, 
        headers: formEncodedHeader
      );

      return _checkingResponse(response);
    } catch(e) {
      if (!configuration.isProduction) print("URL $url, ${e.toString()}");
      throw CustomException(e.toString());
    }
  }

  /// Get data from api,
  /// 
  /// [url] path will be concated with [URLs.BASE_API], 
  /// 
  /// ex: `"path1"` will be converted to `http://base.url/path1`
  /// 
  /// custom [header], default will `null`
  Future<Map<String, dynamic>> getFromApi(String url, { Map<String, String> header }) async {
    try {
      final response = await get(baseUrl(url), headers: header);
      return _checkingResponse(response);
    } catch (e) {
      if (!configuration.isProduction) print("URL $url, ${e.toString()}");
      throw CustomException("Terjadi Kesalahan Jaringan");
    }
  }

}


/// Auth api base class
/// 
/// all access example [getFromApi] will added default auth header,
/// so its not required to add auth
class AuthApi extends BaseApi {

  AuthApi(this.accessToken, this.configuration): 
    assert(accessToken != null, "Akses token tidak boleh kosong!"), 
    super(configuration);

  final String accessToken;
  final ApiConfiguration configuration;
  
  OnInvalidToken delegate;

  /// Default auth header for default auth
  Map<String, String> get authHeader => {'Authorization': 'Bearer $accessToken'};

  /// Auth Header using when 
  Map<String, String> get authUrlEncoded => {
    'Authorization': 'Bearer $accessToken',
    'Content-Type': 'application/x-www-form-urlencoded'
  };

  /// Fetch data from api from [url] with default [authHeader]
  Future<Map<String, dynamic>> getFromApi(String url) async {
    try {
      final response = await get(baseUrl(url), headers: authHeader);
      return _checkingResponse(response);
    } catch (e) {
      if (!configuration.isProduction) print("URL $url, ${e.toString()}");
      throw CustomException(Pesan.ERR_JARINGAN);
    }
  }

  /// Send data to Api by given [url],
  /// 
  /// [postParameter] parameter required to post data to server, can be `null` 
  /// ``` 
  /// await postToApi('path1', {
  ///     'param1': 'value1',
  ///     'param2': 'value2'
  /// })
  /// ```
  /// 
  /// For custm header can using by parameter [httpHeader], when `null` it will be using default auth header
  Future<Map<String, dynamic>> postToApi(String url, { Map<String, String> postParameter, Map<String, dynamic> httpHeader }) async {
    String body = postParameter != null ? fromMapToFormUrlEncoded(postParameter) : null;
    try {
      var headers = authHeader;
      if (postParameter != null) headers = authUrlEncoded;
      if (httpHeader != null) headers = httpHeader;
      final response = await post(baseUrl(url), body: body, headers: headers);
      return _checkingResponse(response);
    } catch (e) {
      if (!configuration.isProduction) print("URL $url, ${e.toString()}");
      throw CustomException(e.toString());
    }
  }

  /// Same as `postToApi` instead it will using REST PUT
  /// 
  /// See:
  ///   * [AuthApi.postToApi]
  Future<Map<String, dynamic>> putToApi(String url, { Map<String, String> postParameter, Map<String, String> httpHeader }) async {
    var body = postParameter != null ? fromMapToFormUrlEncoded(postParameter) : null;
    try {
      var headers = authHeader;
      if (postParameter != null) headers = authUrlEncoded;
      if (httpHeader != null) headers = httpHeader;
      final response = await put(baseUrl(url), body: body, headers: headers);
      return _checkingResponse(response);
    } catch (e) {
      if (!configuration.isProduction) print("URL $url, ${e.toString()}");
      throw CustomException(Pesan.ERR_JARINGAN);
    }
  }

  /// Same as `postToApi` instead using REST DELETE
  /// 
  /// See:
  ///   * [AuthApi.postToApi]
  Future<Map<String, dynamic>> deleteFromApi(String url, { Map<String, String> httpHeader }) async {
    try {
      var headers = authHeader;
      if (httpHeader != null) headers = httpHeader;
      final response = await delete(baseUrl(url), headers: headers);
      return _checkingResponse(response);
    } catch (e) {
      if (!configuration.isProduction) print("URL $url, ${e.toString()}");
      throw CustomException(Pesan.ERR_JARINGAN);
    }
  }

  /// Custom post to api using [httpDio.Dio]
  /// 
  /// path [url] will be concated to [URLs.BASE_API]
  /// 
  /// [postParameters] is using for parameter to send to server
  /// 
  /// Example:
  /// ```
  /// await postToApiUsingDio('path1', {
  ///     "param1": "value1",
  ///     "param2": "value2"
  /// });
  /// ```
  /// 
  /// See Also:
  ///   * [AuthApi.postToApi]
  Future<Map<String, dynamic>> postToApiUsingDio(String url, { Map<String, dynamic> postParameters }) async {
    httpDio.Dio dio = httpDio.Dio();

    httpDio.FormData body = postParameters != null ? httpDio.FormData.fromMap(postParameters) : null;

    try {
      var response = await dio.post(
        baseUrl(url),
        data: body,
        options: httpDio.Options(headers: {
          HttpHeaders.authorizationHeader: 'Bearer $accessToken',
          HttpHeaders.contentTypeHeader: 'multipart/form-data'
        })
      );

      var _response = response.data;
      if (_response['status'] == 'success') {
        return _response;
      } else {
        throw CustomException(_response['message']);
      }
    } catch (e) {
      if (!configuration.isProduction) print("URL $url, ${e.toString()}");
      throw CustomException(Pesan.ERR_JARINGAN);
    }
  }

  /// Simplified [http.Response] checking.
  /// 
  /// Jika status response == 200 maka parsing data dan check status
  /// jika kosong throw default [CustomException] 
  Map<String, dynamic> _checkingResponse(Response response) {
    if (response.statusCode != 401) {
      return super._checkingResponse(response);
    } else {
      if (delegate != null) {
        delegate.onLogout("Hehehe Logout!");
      } else {
        throw CustomException("Terjadi Kesalahan Jaringan");
      }
    }
  }
}

// END API

// API with Version
class UrlConfiguration {
  const UrlConfiguration({
    @required this.baseProdUrl,
    @required this.baseDevUrl,
    this.apiProdUrl,
    this.apiDevUrl,
    this.pathApiPrefix    = 'api/',
    this.isProduction     = true,
  }): assert(baseProdUrl != null, "Base Prod url tidak boleh kosong");

  final String baseProdUrl;
  final String baseDevUrl;

  final String apiProdUrl;
  final String apiDevUrl;

  /// Concat [baseUrl] from prefix
  /// 
  /// default prefix `"api/"`
  final String pathApiPrefix;

  /// Set api go to production or developemtn
  final bool isProduction;

  String get apiUrl {
    if (apiProdUrl != null) {
      if (apiDevUrl == null) {
        return apiProdUrl;
      }

      return isProduction ? apiProdUrl : apiDevUrl;
    } else {
      if (baseDevUrl == null) {
        return baseProdUrl + pathApiPrefix;
      }

      if (isProduction) {
        return baseProdUrl + pathApiPrefix;
      } else {
        return baseDevUrl + pathApiPrefix;
      }
    }
  }

  String get urlBase {
    if (baseDevUrl == null) {
      return baseProdUrl;
    }

    return isProduction ? baseProdUrl : baseDevUrl;
  }
}

/// Abstract class for basic api function
class BaseApiWithVersion {

  BaseApiWithVersion(this._configuration, this.version);

  String           version;
  UrlConfiguration _configuration;

  UrlConfiguration  get configuration   => _configuration;
  String            get apiUrl          => _configuration.apiUrl; 

  /// Concat [baseUrl] with given [path]
  String baseUrl(String path) => this._configuration.apiUrl + path;

  /// Format [param] `Map<String, dynamic>` menjadi form __urlEncoded__
  /// 
  /// contoh dari:
  /// ```
  ///   var data = {
  ///     "data1": "value1",
  ///     "data2": "value2"
  ///   }
  /// ```
  /// menjadi:
  /// 
  /// `data1=value1&data2=value2`
  String fromMapToFormUrlEncoded(Map<String, String> param) {
    var parts = [];
    param.forEach((key, val) {
      parts.add(
          '${Uri.encodeQueryComponent(key)}=${Uri.encodeQueryComponent(val)}');
    });

    return parts.join("&");
  }

  Map<String, String> get formEncodedHeader => {
    'Content-Type'  : 'application/x-www-form-urlencoded',
    'version'       : version
  };

  /// Simplified [http.Response] checking.
  /// 
  /// Jika status response == 200 maka parsing data dan check status
  /// jika kosong throw default [CustomException] 
  Map<String, dynamic> _checkingResponse(Response response) {
    // if (!configuration.isProduction) print("JSON Response ${response.body}");
    switch (response.statusCode) {
      case 200:
        var _response = json.decode(response.body);
        if (_response['status'] == 'success') {
          return _response;
        } else {
          throw CustomException(_response['message']);
        }
        break;
      case 401:
        throw CustomException("Token Expired", addInfo: "LOGOUT");
      default: 
        throw CustomException(Pesan.ERR_JARINGAN);
    }
  }
}

/// Default unAuth Api access
class ApiWithVersion extends BaseApiWithVersion {
  ApiWithVersion(this.configuration, [this.version = "1.0"]) : super(configuration, version);

  final UrlConfiguration configuration;
  final String version;


  /// Simplified post to api call
  /// 
  /// [url] akan langsung di concat dengan base url
  Future<Map<String, dynamic>> postToApi(String url, { Map<String, String> postParams }) async {
    var body = fromMapToFormUrlEncoded(postParams);
    try {
      var response = await post(
        baseUrl(url), 
        body: body, 
        headers: formEncodedHeader
      );

      return _checkingResponse(response);
    } catch(e) {
      if (!configuration.isProduction) print("URL $url, ${e.toString()}");
      throw CustomException(e.toString());
    }
  }

  /// Get data from api,
  /// 
  /// [url] path will be concated with [URLs.BASE_API], 
  /// 
  /// ex: `"path1"` will be converted to `http://base.url/path1`
  /// 
  /// custom [header], default will `null`
  Future<Map<String, dynamic>> getFromApi(String url, { Map<String, String> header }) async {
    try {
      final response = await get(baseUrl(url), headers: header);
      return _checkingResponse(response);
    } catch (e) {
      if (!configuration.isProduction) print("URL $url, ${e.toString()}");
      throw CustomException(Pesan.ERR_JARINGAN);
    }
  }

  /// Custom post to api using [httpDio.Dio]
  /// 
  /// path [url] will be concated to [URLs.BASE_API]
  /// 
  /// [postParameters] is using for parameter to send to server
  /// 
  /// Example:
  /// ```
  /// await postToApiUsingDio('path1', {
  ///     "param1": "value1",
  ///     "param2": "value2"
  /// });
  /// ```
  /// 
  /// See Also:
  ///   * [AuthApi.postToApi]
  Future<Map<String, dynamic>> postToApiUsingDio(String url, { Map<String, dynamic> postParameters }) async {
    httpDio.Dio dio = httpDio.Dio();

    httpDio.FormData body = postParameters != null ? httpDio.FormData.fromMap(postParameters) : null;

    try {
      var response = await dio.post(
        baseUrl(url),
        data: body,
        options: httpDio.Options(
          method: "POST",
          headers: {
          HttpHeaders.contentTypeHeader   : 'multipart/form-data',
          'version'                       : version
        })
      );

      var _response = response.data;
      if (_response['status'] == 'success') {
        return _response;
      } else {
        throw CustomException(_response['message']);
      }
    } catch (e) {
      if (!configuration.isProduction) print("DIO URL $url, ${e.toString()}");
      throw CustomException(Pesan.ERR_JARINGAN);
    }
  }

}


/// Auth api base class
/// 
/// all access example [getFromApi] will added default auth header,
/// so its not required to add auth
class AuthApiWithVersion extends BaseApiWithVersion {

  AuthApiWithVersion(this.accessToken, this.configuration, [this.version = "1.0"]): 
    assert(accessToken != null, "Akses token tidak boleh kosong!"), 
    super(configuration, version);

  final String accessToken;
  final String version;
  final UrlConfiguration configuration;

  /// Default auth header for default auth
  Map<String, String> get authHeader => {'Authorization': 'Bearer $accessToken'};

  /// Auth Header using when 
  Map<String, String> get authUrlEncoded => {
    'Authorization' : 'Bearer $accessToken',
    'Content-Type'  : 'application/x-www-form-urlencoded',
    'version'       : version
  };

  /// Fetch data from api from [url] with default [authHeader]
  Future<Map<String, dynamic>> getFromApi(String url) async {
    try {
      final response = await get(baseUrl(url), headers: authHeader);
      return _checkingResponse(response);
    } catch (e) {
      if (!configuration.isProduction) print("URL $url, ${e.toString()}");
      throw CustomException(Pesan.ERR_JARINGAN);
    }
  }

  /// Send data to Api by given [url],
  /// 
  /// [postParameter] parameter required to post data to server, can be `null` 
  /// ``` 
  /// await postToApi('path1', {
  ///     'param1': 'value1',
  ///     'param2': 'value2'
  /// })
  /// ```
  /// 
  /// For custm header can using by parameter [httpHeader], when `null` it will be using default auth header
  Future<Map<String, dynamic>> postToApi(String url, { Map<String, String> postParameter, Map<String, dynamic> httpHeader }) async {
    String body = postParameter != null ? fromMapToFormUrlEncoded(postParameter) : null;
    try {
      var headers = authHeader;
      if (postParameter != null) headers = authUrlEncoded;
      if (httpHeader != null) headers = httpHeader;
      final response = await post(baseUrl(url), body: body, headers: headers);
      return _checkingResponse(response);
    } catch (e) {
      if (!configuration.isProduction) print("URL $url, ${e.toString()}");
      throw CustomException(e.toString());
    }
  }

  /// Same as `postToApi` instead it will using REST PUT
  /// 
  /// See:
  ///   * [AuthApi.postToApi]
  Future<Map<String, dynamic>> putToApi(String url, { Map<String, String> postParameter, Map<String, String> httpHeader }) async {
    var body = postParameter != null ? fromMapToFormUrlEncoded(postParameter) : null;
    try {
      var headers = authHeader;
      if (postParameter != null) headers = authUrlEncoded;
      if (httpHeader != null) headers = httpHeader;
      final response = await put(baseUrl(url), body: body, headers: headers);
      return _checkingResponse(response);
    } catch (e) {
      if (!configuration.isProduction) print("URL $url, ${e.toString()}");
      throw CustomException(Pesan.ERR_JARINGAN);
    }
  }

  /// Same as `postToApi` instead using REST DELETE
  /// 
  /// See:
  ///   * [AuthApi.postToApi]
  Future<Map<String, dynamic>> deleteFromApi(String url, { Map<String, String> httpHeader }) async {
    try {
      var headers = authHeader;
      if (httpHeader != null) headers = httpHeader;
      final response = await delete(baseUrl(url), headers: headers);
      return _checkingResponse(response);
    } catch (e) {
      if (!configuration.isProduction) print("URL $url, ${e.toString()}");
      throw CustomException(Pesan.ERR_JARINGAN);
    }
  }

  /// Custom post to api using [httpDio.Dio]
  /// 
  /// path [url] will be concated to [URLs.BASE_API]
  /// 
  /// [postParameters] is using for parameter to send to server
  /// 
  /// Example:
  /// ```
  /// await postToApiUsingDio('path1', {
  ///     "param1": "value1",
  ///     "param2": "value2"
  /// });
  /// ```
  /// 
  /// See Also:
  ///   * [AuthApi.postToApi]
  Future<Map<String, dynamic>> postToApiUsingDio(String url, { Map<String, dynamic> postParameters }) async {
    httpDio.Dio dio = httpDio.Dio();

    httpDio.FormData body = postParameters != null ? httpDio.FormData.fromMap(postParameters) : null;

    try {
      var response = await dio.post(
        baseUrl(url),
        data: body,
        options: httpDio.Options(headers: {
          HttpHeaders.authorizationHeader : 'Bearer $accessToken',
          HttpHeaders.contentTypeHeader   : 'multipart/form-data',
          'version'                       : version
        })
      );

      var _response = response.data;
      if (_response['status'] == 'success') {
        return _response;
      } else {
        throw CustomException(_response['message']);
      }
    } catch (e) {
      if (!configuration.isProduction) print("URL $url, ${e.toString()}");
      throw CustomException(Pesan.ERR_JARINGAN);
    }
  }
}