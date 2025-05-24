import 'package:dio/dio.dart';
import 'package:uiticket_fe/constants/api.dart';
import 'package:uiticket_fe/models/user.dart';
import 'package:uiticket_fe/services/http_services.dart';

class UserRequest extends HttpServices {
  Future<User> getUserById(String userId) async {
    try {
      final response = await get(url: "${Api.users}/$userId");

      if (response.statusCode == 200) {
        return User.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load user details');
      }
    } catch (e) {
      print('Error fetching user details: $e');
      rethrow;
    }
  }
}