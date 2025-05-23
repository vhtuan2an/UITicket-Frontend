import 'package:dio/dio.dart';
import 'package:uiticket_fe/constants/api.dart';
import 'package:uiticket_fe/services/auth_services.dart';

class HttpServices {
  late Dio _dio;

  HttpServices() {
    _dio = Dio();
    _dio.options.baseUrl = Api.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  Future<Response> post({
    required String url,
    Map<String, dynamic>? body,
    bool includeHeader = true,
    Map<String, dynamic>? headers,
  }) async {
    Response response;
    try {
      print('Making request to: ${Api.baseUrl}$url');
      print('Request body: $body');
      response = await _dio.post(
        url,
        data: body,
        options: Options(
          headers: includeHeader ? await getHeaders() : headers,
        ),
      );
      print('Response data: ${response.data}');
    } on DioException catch (e) {
      response = _handleError(e);
    }
    return response;
  }

  Future<Response> get({
    required String url,
    Map<String, dynamic>? body,
    bool includeHeader = true,
    Map<String, dynamic>? customHeaders, // Đổi tên từ headers thành customHeaders
  }) async {
    Response response;
    try {
      final token = await AuthServices.getAuthBearerToken();
      print('Making GET request to: ${_dio.options.baseUrl}$url');
      print('User token: $token');

      final headers = <String, dynamic>{ // Biến local này sẽ không bị conflict
        'Content-Type': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      response = await _dio.get(
        url,
        queryParameters: body,
        options: Options(headers: includeHeader ? headers : customHeaders),
      );

      return response;
    } catch (e) {
      print('HTTP GET error: $e');
      rethrow;
    }
  }

  // Get headers
  Future<Map<String, String>> getHeaders({
    contentType = 'application/json',
  }) async {
    final userToken = await AuthServices.getAuthBearerToken();
    print('User token: $userToken');
    return {
      'Authorization': 'Bearer $userToken',
      'Content-Type': contentType,
    };
  }

  Response _handleError(DioException e) {
    // Create a response object with error details
    return Response(
      requestOptions: e.requestOptions,
      statusCode: e.response?.statusCode,
      statusMessage: e.message,
      data: e.response?.data,
    );
  }
}