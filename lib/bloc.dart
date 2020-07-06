import 'dart:async';

import 'package:flutter/foundation.dart';

enum BlocStatus {
  error,

  success,

  loading,

  init
}

abstract class BaseBloc {
  void dispose();
}

/// Default block state agar mempermudah pemanggilan
class BlocState<T> {
  BlocState({
    this.status   = BlocStatus.init,
    this.message,
    this.data
  });

  final BlocStatus status;
  final T data;
  final String message;

  @override
  String toString() {
    return "$status - $message";
  }
}

/// Base block/Parent bloc
class Bloc<T> extends BaseBloc {

  @mustCallSuper
  Bloc() { init(); }

  @protected
  StreamController _controller = StreamController<BlocState<T>>();
  Stream get stream => _controller.stream;
  StreamSink get sink => _controller.sink;

  /// Initialize status to [BlocStatus.init] so, status is not null when
  /// first initialized, avoiding NULL exception
  void init() => _controller.add(BlocState<T>(status: BlocStatus.init, data: null));

  /// Sink [data] when bloc completed
  set success(T data) => sink.add(BlocState<T>( status: BlocStatus.success, data: data ));

  /// Sink [message] to stream when fetching is loading
  set loading(String message) => sink.add(BlocState<T>( status: BlocStatus.loading, message: message ));

  /// Set loading with [data]
  set loadingData(T data) => sink.add(BlocState<T>( status: BlocStatus.loading, message: '', data: data ));

  /// Show [errorMessage] when operational fail
  set error(String errorMessage) => sink.add(BlocState<T>( status: BlocStatus.error, message: errorMessage ));

  /// Get success [BlocState] data when success
  BlocState<T> getSuccess(T data) => BlocState<T>( status: BlocStatus.success, data: data );

  /// Get success [BlocState] data when error
  BlocState<T> getError(String errorMessage) => BlocState<T>( status: BlocStatus.error, message: errorMessage );


  @mustCallSuper
  @override
  void dispose() {
    _controller.close();
  }
}

/// Same as [Bloc] but with broadcast function
class BlocBroadcast<T> extends BaseBloc {

  @mustCallSuper
  BlocBroadcast() { init(); }

  @protected
  StreamController _controller = StreamController<BlocState<T>>.broadcast();
  Stream get stream => _controller.stream;
  StreamSink get sink => _controller.sink;

  void init() => _controller.add(BlocState<T>(status: BlocStatus.init, data: null));

  /// Set when [data] successfuly fetched
  set success(T data) => sink.add(BlocState<T>( status: BlocStatus.success, data: data ));

  set loadingData(T data) => sink.add(BlocState<T>( status: BlocStatus.loading, message: '', data: data ));

  /// Send [message] to stream when fetching is loading
  set loading(String message) => sink.add(BlocState<T>( status: BlocStatus.loading, message: message ));

  /// Show [errorMessage] when operational fail
  set error(String errorMessage) => sink.add(BlocState<T>( status: BlocStatus.error, message: errorMessage ));

  void errorWithData(T data, String errorMessage) => sink.add(BlocState<T>( status: BlocStatus.error, message: errorMessage, data: data ));


  @mustCallSuper
  @override
  void dispose() {
    _controller.close();
  }
}