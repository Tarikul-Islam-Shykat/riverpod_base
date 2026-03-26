
import '../enums/network_enums.dart';

class NetworkEvent {
  final NetworkEventType type;
  final String? message;
  final dynamic data;
  final int? statusCode;

  NetworkEvent({
    required this.type,
    this.message,
    this.data,
    this.statusCode,
  });
}