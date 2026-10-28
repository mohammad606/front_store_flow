import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_exception.dart';
import 'api_response.dart';

class BaseApiService {
  final http.Client _client;

  BaseApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<ApiResponse<T>> get<T>({
    required String path,
    required T Function(dynamic data) fromJson,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    String? token,
  }) {
    return request<T>(
      method: 'GET',
      path: path,
      fromJson: fromJson,
      queryParameters: queryParameters,
      headers: headers,
      token: token,
    );
  }

  Future<ApiResponse<T>> post<T>({
    required String path,
    required T Function(dynamic data) fromJson,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    String? token,
  }) {
    return request<T>(
      method: 'POST',
      path: path,
      fromJson: fromJson,
      body: body,
      headers: headers,
      token: token,
    );
  }

  Future<ApiResponse<T>> request<T>({
    required String method,
    required String path,
    required T Function(dynamic data) fromJson,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    String? token,
  }) async {
    final uri = ApiConfig.buildUrl(path, queryParameters: queryParameters);

    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      if (headers != null) ...headers,
    };

    try {
      late final http.Response response;
      final encodedBody = body == null ? null : jsonEncode(body);

      switch (method.toUpperCase()) {
        case 'GET':
          response = await _client
              .get(uri, headers: requestHeaders)
              .timeout(ApiConfig.timeout);
          break;
        case 'POST':
          response = await _client
              .post(uri, headers: requestHeaders, body: encodedBody)
              .timeout(ApiConfig.timeout);
          break;
        case 'PUT':
          response = await _client
              .put(uri, headers: requestHeaders, body: encodedBody)
              .timeout(ApiConfig.timeout);
          break;
        case 'PATCH':
          response = await _client
              .patch(uri, headers: requestHeaders, body: encodedBody)
              .timeout(ApiConfig.timeout);
          break;
        case 'DELETE':
          response = await _client
              .delete(uri, headers: requestHeaders, body: encodedBody)
              .timeout(ApiConfig.timeout);
          break;
        default:
          throw const ApiException('Unsupported HTTP method.');
      }

      final decodedBody = _decodeResponse(response.body);
      final apiResponse = ApiResponse<T>.fromJson(decodedBody, fromJson);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return apiResponse;
      }

      throw ApiException(
        apiResponse.message.isNotEmpty ? apiResponse.message : 'Request failed.',
        statusCode: response.statusCode,
        response: apiResponse.raw,
      );
    } on SocketException {
      throw const ApiException('لا يوجد اتصال بالإنترنت.');
    } on TimeoutException {
      throw const ApiException('انتهت مهلة الطلب.');
    } on http.ClientException {
      throw const ApiException('خطأ في الاتصال بالخادم.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Map<String, dynamic> _decodeResponse(String responseBody) {
    if (responseBody.trim().isEmpty) {
      return <String, dynamic>{
        'status': false,
        'message': 'Empty response',
        'data': <dynamic>[],
        'code': 500,
      };
    }

    final decoded = jsonDecode(responseBody);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }

    throw const ApiException('استجابة غير صالحة من الخادم.');
  }
}
