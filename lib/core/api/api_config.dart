class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const Duration timeout = Duration(seconds: 25);

  static Uri buildUrl(String path, {Map<String, dynamic>? queryParameters}) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$baseUrl$normalizedPath');

    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }

    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        ...queryParameters.map((key, value) => MapEntry(key, value.toString())),
      },
    );
  }
}
