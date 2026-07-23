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

  static Future<void> setTenant(TenantModel tenant) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('tenant', jsonEncode(tenant.toJson()));
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
