import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uiticket_fe/services/http_services.dart';
import 'package:uiticket_fe/requests/auth_request.dart';

final authServiceProvider = Provider((ref) => HttpServices());
final authRequestProvider = Provider((ref) => AuthRequest());