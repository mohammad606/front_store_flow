class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic response;

  const ApiException(this.message, {this.statusCode, this.response});

  @override
  String toString() {
    final buffer = StringBuffer('ApiException');
    if (statusCode != null) {
      buffer.write('($statusCode)');
    }
    buffer.write(': $message');
    return buffer.toString();
  }
}
