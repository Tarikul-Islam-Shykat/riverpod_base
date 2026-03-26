// ignore_for_file: non_constant_identifier_names, file_names

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/secrets/secret_storage.dart';
import '../../../core/secrets/secrets_type.dart';
import '../enums/network_enums.dart';
import '../events/network_events.dart';
import '../exceptions/network_exceptions.dart';
import '../options/network_options.dart';
import '../status/network_status_code.dart';


class NetworkConfig {
  final Dio _dio;
  final NetworkConfigOptions _options;
  final StreamController<NetworkEvent> _eventController;

  NetworkConfig({
    NetworkConfigOptions? options,
  })  : _options = options ?? const NetworkConfigOptions(),
        _dio = Dio(),
        _eventController = StreamController<NetworkEvent>.broadcast() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio.options = BaseOptions(
      baseUrl: _options.baseUrl,
      connectTimeout: _options.connectTimeout,
      receiveTimeout: _options.receiveTimeout,
      headers: _options.defaultHeaders,
      validateStatus: (status) => status! < 500,
    );

    // Fix SSL certificate issues (for development/testing)
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Emit request started event
    _eventController.add(NetworkEvent(type: NetworkEventType.requestStarted));

    // Add auth token if required
    if (options.extra['is_auth'] == true) {
      try {
        final token =
            await SecureStorageService.getValue(StorageKey.accessToken);

        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        } else {
          _eventController.add(NetworkEvent(
            type: NetworkEventType.requestFailed,
            message: 'Authentication token not found',
          ));
          return handler.reject(
            DioException(
              requestOptions: options,
              error: 'Authentication token not found',
            ),
          );
        }
      } catch (e) {
        _eventController.add(NetworkEvent(
          type: NetworkEventType.requestFailed,
          message: 'Failed to retrieve auth token',
        ));
        return handler.reject(
          DioException(
            requestOptions: options,
            error: 'Failed to retrieve auth token',
          ),
        );
      }
    }

    // Minimal logging
    if (_options.enableLogging && kDebugMode) {
      log('🌐 ${options.method} ${options.uri}');
    }

    handler.next(options);
  }

  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    // Minimal logging
    if (_options.enableLogging && kDebugMode) {
      log('✅ [${response.statusCode}]');
    }

    // Emit success event
    _eventController.add(NetworkEvent(
      type: NetworkEventType.requestSucceeded,
      statusCode: response.statusCode,
      data: response.data,
    ));

    handler.next(response);
  }

  // Error interceptor with retry logic built-in
  Future<void> _onError(DioException e, ErrorInterceptorHandler handler) async {
    // Handle automatic retry for network errors (built-in retry)
    if (_shouldRetry(e)) {
      final attempt = ((e.requestOptions.extra['retry_count'] ?? 0) as int) + 1;

      if (attempt <= _options.maxRetries) {
        e.requestOptions.extra['retry_count'] = attempt;
        await Future.delayed(Duration(milliseconds: 500 * attempt));
        try {
          final response = await _dio.fetch(e.requestOptions);
          return handler.resolve(response);
        } catch (retryError) {
          // Continue to error handling if retry fails
        }
      }
    }

    // Handle automatic token refresh on 401
    if (e.response?.statusCode == 401 &&
        e.requestOptions.extra['is_auth'] == true &&
        e.requestOptions.extra['token_refreshed'] != true) {
      try {
        final newToken = await _refreshToken();
        if (newToken != null) {
          e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          e.requestOptions.extra['token_refreshed'] = true;
          _eventController
              .add(NetworkEvent(type: NetworkEventType.tokenRefreshed));

          final response = await _dio.fetch(e.requestOptions);
          return handler.resolve(response);
        }
      } catch (refreshError) {
        if (_options.enableLogging && kDebugMode) {
          log('❌ Token refresh failed: $refreshError');
        }
      }
    }

    // Map and emit failure event
    final networkException = _mapDioExceptionToNetworkException(e);
    _eventController.add(NetworkEvent(
      type: NetworkEventType.requestFailed,
      message: networkException.message,
      statusCode: networkException.statusCode,
    ));

    // Minimal error logging
    if (_options.enableLogging && kDebugMode) {
      log('❌ ${networkException.message}');
    }

    handler.next(e);
  }

  // Determine if we should retry based on error type
  bool _shouldRetry(DioException err) {
    // Don't retry on client errors (4xx) except for specific cases
    if (err.response?.statusCode != null) {
      final statusCode = err.response!.statusCode!;
      if (statusCode >= 400 && statusCode < 500) {
        return false;
      }
    }

    // Retry on network issues and server errors (5xx)
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.unknown ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }

  // Stream to listen for network events
  Stream<NetworkEvent> get networkEvents => _eventController.stream;

  // Main API request handler - OPTIMIZED
  Future<dynamic> ApiRequestHandler(
    RequestMethod method,
    String endpoint,
    dynamic body, {
    bool isAuth = false,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    String? contentType,
    String? baseUrl,
  }) async {
    try {
      Response response;
      final options = Options(
        headers: contentType != null ? {'Content-Type': contentType} : null,
        extra: {'is_auth': isAuth},
      );

      // Temporarily change base URL if provided
      final originalBaseUrl = baseUrl != null ? _dio.options.baseUrl : null;
      if (baseUrl != null) {
        _dio.options.baseUrl = baseUrl;
      }

      switch (method) {
        case RequestMethod.GET:
          response = await _dio.get(
            endpoint,
            data: body,
            queryParameters: queryParameters,
            options: options,
            cancelToken: cancelToken,
          );
          break;

        case RequestMethod.POST:
          response = await _dio.post(
            endpoint,
            data: body,
            queryParameters: queryParameters,
            options: options,
            cancelToken: cancelToken,
          );
          break;

        case RequestMethod.PUT:
          response = await _dio.put(
            endpoint,
            data: body,
            queryParameters: queryParameters,
            options: options,
            cancelToken: cancelToken,
          );
          break;

        case RequestMethod.DELETE:
          response = await _dio.delete(
            endpoint,
            queryParameters: queryParameters,
            options: options,
            cancelToken: cancelToken,
          );
          break;
      }

      // Restore original base URL if it was changed
      if (originalBaseUrl != null) {
        _dio.options.baseUrl = originalBaseUrl;
      }

      return response.data;
    } on DioException catch (e) {
      throw _mapDioExceptionToNetworkException(e);
    } catch (e) {
      throw NetworkException(
        message: e.toString(),
        type: NetworkExceptionType.unknown,
      );
    }
  }

  // Convenience methods
  Future<dynamic> get(String endpoint, dynamic body, {bool isAuth = false}) {
    return ApiRequestHandler(RequestMethod.GET, endpoint, body, isAuth: isAuth);
  }

  Future<dynamic> post(String endpoint, dynamic body, {bool isAuth = false}) {
    return ApiRequestHandler(RequestMethod.POST, endpoint, body,
        isAuth: isAuth);
  }

  Future<dynamic> put(String endpoint, dynamic body, {bool isAuth = false}) {
    return ApiRequestHandler(RequestMethod.PUT, endpoint, body, isAuth: isAuth);
  }

  Future<dynamic> delete(String endpoint, {bool isAuth = false}) {
    return ApiRequestHandler(RequestMethod.DELETE, endpoint, null,
        isAuth: isAuth);
  }

  Future<dynamic> requestWithCustomBaseUrl(
    RequestMethod method,
    String customBaseUrl,
    String endpoint,
    dynamic body, {
    bool isAuth = false,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    String? contentType,
  }) {
    return ApiRequestHandler(
      method,
      endpoint,
      body,
      isAuth: isAuth,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      contentType: contentType,
      baseUrl: customBaseUrl,
    );
  }

  // Token refresh method
  Future<String?> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      if (refreshToken == null) return null;

      final response = await _dio.post(
        '/refresh-token',
        data: {'refresh_token': refreshToken},
        options: Options(extra: {'is_auth': false}),
      );

      final newToken = response.data['token'];
      await prefs.setString('token', newToken);
      return newToken;
    } catch (e) {
      return null;
    }
  }

  // Map Dio exceptions to custom exceptions
  NetworkException _mapDioExceptionToNetworkException(DioException e) {
    String message;
    NetworkExceptionType type;
    int? statusCode = e.response?.statusCode;

    if (e.response != null) {
      // Extract error message from response
      try {
        final responseData = e.response!.data;
        if (responseData is Map && responseData.containsKey('message')) {
          message = responseData['message'].toString();
        } else if (responseData is Map && responseData.containsKey('error')) {
          message = responseData['error'].toString();
        } else {
          message = StatusCodeError().getStatusCodeMessage(statusCode!);
        }
      } catch (_) {
        message = StatusCodeError().getStatusCodeMessage(statusCode!);
      }
      type = statusCode == 401
          ? NetworkExceptionType.unauthorized
          : NetworkExceptionType.server;
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      message = 'Request timeout - Please try again';
      type = NetworkExceptionType.timeout;
    } else if (e.type == DioExceptionType.cancel) {
      message = 'Request was cancelled';
      type = NetworkExceptionType.cancelled;
    } else {
      // This handles "no internet" scenarios
      message = 'No internet connection - Please check your network';
      type = NetworkExceptionType.noInternet;
    }

    return NetworkException(
      message: message,
      type: type,
      statusCode: statusCode,
    );
  }

  void dispose() {
    _dio.close();
    _eventController.close();
  }
}

