import 'package:edunest/app/data/model/student_model.dart';
import 'package:edunest/app/data/model/tenant_model.dart';

class LoginResponseModel {
  final String session;
  final String refresh;
  final StudentModel student;
  final TenantModel tenant;

  const LoginResponseModel({
    required this.session,
    required this.refresh,
    required this.student,
    required this.tenant,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      session: json['session'] ?? "",
      refresh: json['refresh'] ?? "",
      student: StudentModel.fromJson(json['student'] ?? {}),
      tenant: TenantModel.fromJson(json['tenant'] ?? {}),
    );
  }
}
