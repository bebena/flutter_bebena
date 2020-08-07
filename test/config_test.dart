import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bebena/apis.dart';

void main() {
  const APIConfig = UrlConfiguration(
    baseProdUrl   : "http://monarchbaliapp.com/", 
    baseDevUrl    : "http://dev.monarchbaliapp.com/",
    isProduction  : false
  );
  test("UrlConfiguration test", () {
    expect(APIConfig.apiUrl, "http://dev.monarchbaliapp.com/api/");
  });
}