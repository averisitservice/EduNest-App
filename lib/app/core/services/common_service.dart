import 'dart:convert';
import 'package:edunest/app/data/model/student_model.dart';
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

  static Future<String?> getRefreshToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken');
  }

  static Future<void> setStudent(StudentModel student) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('student', jsonEncode(student.toJson()));
  }

  static Future<StudentModel?> getStudent() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString('student');
    if (raw == null) return null;
    return StudentModel.fromJson(jsonDecode(raw));
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
