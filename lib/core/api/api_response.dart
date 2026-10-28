class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? code;
  final Map<String, dynamic>? raw;

  const ApiResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.code,
    this.raw,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic data)? fromJson,
  ) {
    final dynamic rawData = json['data'];
    T? parsedData;

    if (fromJson != null && rawData != null) {
      parsedData = fromJson(rawData);
    } else if (rawData != null) {
      parsedData = rawData as T?;
    }

    final dynamic status = json['status'];
    final bool isSuccess = status == true || status == 'success';
    final int? statusCode = json['code'] is int
        ? json['code'] as int
        : int.tryParse('${json['code']}');

    return ApiResponse<T>(
      success: isSuccess,
      message: (json['message'] ?? 'No message').toString(),
      data: parsedData,
      code: statusCode,
      raw: json,
    );
  }
}
