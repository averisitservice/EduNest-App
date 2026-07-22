import 'dart:convert';
import 'package:edunest/app/data/model/tenant_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommonService {
  static Future<void> setSessionToken(String sessionToken) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('sessionToken', sessionToken);
  }

  static Future<String?> getSessionToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('sessionToken');
  }

  static Future<void> setRefreshToken(String refreshToken) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('refreshToken', refreshToken);
  }

  static Future<void> setSchoolCode(String schoolCode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('schoolCode', schoolCode);
  }

  static Future<String?> getSchoolCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('schoolCode');
  }

  static Future<void> setTenant(TenantModel tenant) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('tenant', jsonEncode(tenant.toJson()));
    await prefs.setString('schoolCode', tenant.schoolCode);
  }

  static Future<TenantModel?> getTenant() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString('tenant');
    return TenantModel.fromJson(jsonDecode(raw!));
  }

  static Future<void> clearSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
