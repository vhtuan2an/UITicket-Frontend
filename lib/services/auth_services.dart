import 'package:uiticket_fe/enum.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthServices {
  static Future<SharedPreferences> getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  static Future<bool> setAuthBearerToken(String token) async {
    final prefs = await getPrefs();
    return prefs.setString('token', token);
  }

  static Future<String?> getAuthBearerToken() async {
    final prefs = await getPrefs();
    return prefs.getString('token');
  }

  static Future<bool> setUserName(String name) async {
    final prefs = await getPrefs();
    return prefs.setString('user_name', name);
  }

  static Future<String?> getUserName() async {
    final prefs = await getPrefs();
    return prefs.getString('user_name');
  }
}
