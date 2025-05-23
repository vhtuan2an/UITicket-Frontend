import 'package:dio/dio.dart';
import 'package:uiticket_fe/constants/api.dart';
import 'package:uiticket_fe/models/user.dart';
import 'package:uiticket_fe/services/http_services.dart';

class UserRequest extends HttpServices {
  Future<User> getUserById(String userId) async {
    try {
      print('Fetching user with ID: $userId');
      print('Request URL: ${Api.baseUrl}${Api.users}/$userId');
      
      final response = await get(url: "${Api.users}/$userId");
      
      print('User response status: ${response.statusCode}');
      print('User response data: ${response.data}');
      print('User response type: ${response.data.runtimeType}');
      
      if (response.statusCode == 200) {
        // Kiểm tra cấu trúc response từ API
        if (response.data is Map<String, dynamic>) {
          final responseData = response.data as Map<String, dynamic>;
          
          // Nếu có wrapper 'data'
          if (responseData.containsKey('data') && responseData['data'] != null) {
            print('User data found in wrapper: ${responseData['data']}');
            return User.fromJson(responseData['data']);
          } 
          // Nếu data trực tiếp
          else if (responseData.containsKey('_id') || responseData.containsKey('id')) {
            print('Direct user data: $responseData');
            return User.fromJson(responseData);
          }
          else {
            throw Exception('Invalid user data structure: $responseData');
          }
        } else {
          throw Exception('Unexpected response format: ${response.data}');
        }
      } else {
        throw Exception('Failed to load user details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user details: $e');
      if (e is DioException) {
        print('DioException type: ${e.type}');
        print('DioException response: ${e.response?.data}');
        print('DioException status code: ${e.response?.statusCode}');
        print('DioException message: ${e.message}');
      }
      rethrow;
    }
  }
}