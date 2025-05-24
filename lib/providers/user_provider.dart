import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uiticket_fe/models/user.dart';
import 'package:uiticket_fe/requests/user_request.dart';

final userRequestProvider = Provider((ref) => UserRequest());

final userInfoProvider = FutureProvider.family<User, String>((ref, userId) async {
  final userRequest = ref.read(userRequestProvider);
  return await userRequest.getUserById(userId);
});