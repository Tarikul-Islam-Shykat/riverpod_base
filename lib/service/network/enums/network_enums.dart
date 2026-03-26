enum RequestMethod { GET, POST, PUT, DELETE }


enum NetworkEventType {
  requestStarted,
  requestSucceeded,
  requestFailed,
  tokenRefreshed,
  noInternet,
}


// Custom exception class
enum NetworkExceptionType {
  noInternet,
  server,
  timeout,
  cancelled,
  unauthorized,
  unknown,
}
