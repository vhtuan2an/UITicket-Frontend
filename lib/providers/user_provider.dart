import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uiticket_fe/models/user.dart';
import 'package:uiticket_fe/requests/user_request.dart';

final userRequestProvider = Provider((ref) => UserRequest());

final userInfoProvider = FutureProvider.family<User, String>((ref, userId) async {
  print('UserInfoProvider - Fetching user info for ID: $userId');
  
  if (userId.isEmpty) {
    print('UserInfoProvider - UserId is empty, throwing error');
    throw Exception('User ID is empty');
  }
  
  final userRequest = ref.read(userRequestProvider);
  final user = await userRequest.getUserById(userId);
  
  print('UserInfoProvider - Successfully fetched user: ${user.name}');
  return user;
});