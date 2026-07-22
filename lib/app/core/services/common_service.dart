import 'package:shared_preferences/shared_preferences.dart';

class CommonService {
  static const String _sessionTokenStorageKey = 'sessionToken';

  static Future<String?> getSessionToken() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    return sharedPreferences.getString(_sessionTokenStorageKey);
  }

  static Future<void> clearSharedPreferences() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    await sharedPreferences.clear();
  }
}
