
import 'package:riverpod_base/service/network/endpoints/endpoints.dart';

class NetworkConfigOptions {
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Map<String, String> defaultHeaders;
  final int maxRetries;
  final bool showToastOnError;
  final bool enableLogging;

  const NetworkConfigOptions({
    this.baseUrl = Urls.baseUrl,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.defaultHeaders = const {
      Urls.apiKeyName: Urls.apiKey,
      'Content-Type': 'application/json'
    },
    this.maxRetries = 3,
    this.showToastOnError = true,
    this.enableLogging = true,
  });
}
