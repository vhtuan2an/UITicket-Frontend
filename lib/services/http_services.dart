import 'package:uiticket_fe/constants/api.dart';
import 'package:uiticket_fe/services/auth_services.dart';
import 'package:dio/dio.dart';

class HttpServices {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Api.baseUrl,
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  HttpServices() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Do something before request is sent
          return handler.next(options); //continue
        },
        onResponse: (response, handler) {
          // Do something with response data
          return handler.next(response); // continue
        },
        onError: (DioException e, handler) {
          // Do something with response error
          return handler.next(e); //continue
        },
      ),
    );
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
    Map<String, dynamic>? headers,
  }) async {
    Response response;
    try {
      print('Making request to: ${Api.baseUrl}$url');
      print('Request body: $body');
      response = await _dio.get(
        url,
        queryParameters: body,
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