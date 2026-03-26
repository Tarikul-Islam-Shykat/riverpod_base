
import '../enums/network_enums.dart';

class NetworkException implements Exception {
  final String message;
  final NetworkExceptionType type;
  final int? statusCode;

  NetworkException({
    required this.message,
    required this.type,
    this.statusCode,
  });

  @override
  String toString() => message;
}