class StatusCodeError {
  String getStatusCodeMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request - Please check your input';
      case 401:
        return 'Unauthorized - Please login again';
      case 403:
        return 'Access denied';
      case 404:
        return 'Resource not found';
      case 408:
        return 'Request timeout';
      case 500:
        return 'Server error - Please try again later';
      case 502:
        return 'Bad gateway - Server is temporarily unavailable';
      case 503:
        return 'Service unavailable - Please try again later';
      default:
        return 'Server error ($statusCode)';
    }
  }
}

