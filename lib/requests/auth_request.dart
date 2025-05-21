import 'package:uiticket_fe/constants/api.dart';
import 'package:dio/dio.dart';
import 'package:uiticket_fe/services/http_services.dart';

class AuthRequest extends HttpServices {

  Future<Response> login({required String email, required String password}) async {
    try {
      print('Attempting login with: $email');
      final response = await post(
        url: Api.login,
        body: {
          'email': email,
          'password': password,
        },
      );
      
      if (response.statusCode == null) {
        throw Exception('No response from server');
      }
      
      print('Login response status: ${response.statusCode}');
      print('Login response data: ${response.data}');
      
      return response;
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  Future<Response> register({
    required String name,
    required String email, 
    required String password,
    required String confirmPassword,
    required String role,
    }) async {
    try {
      final response = await post(
        url: Api.register,
        body: {
          'name': name,
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
          'role': role,
        },
      );
      
      if (response.statusCode == null) {
        throw Exception('No response from server');
      }
      
      print('Login response status: ${response.statusCode}');
      print('Login response data: ${response.data}');
      
      return response;
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }
}