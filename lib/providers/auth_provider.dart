import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uiticket_fe/services/http_services.dart';
import 'package:uiticket_fe/requests/auth_request.dart';
import 'package:uiticket_fe/services/auth_services.dart';

final authServiceProvider = Provider((ref) => HttpServices());
final authRequestProvider = Provider((ref) => AuthRequest());

final userNameProvider = FutureProvider<String>((ref) async {
  final userName = await AuthServices.getUserName();
  return userName ?? 'User'; // Giá trị mặc định nếu không có tên
});