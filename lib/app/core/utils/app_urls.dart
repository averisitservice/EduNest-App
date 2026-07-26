class AppUrls {
  static late String baseUrl;

  static String getTenantBySchoolCode(String schoolCode) =>
      "$baseUrl/auth/tenant/$schoolCode";

  static String login() => "$baseUrl/api/auth/login";

  static String forgotPassword() => "$baseUrl/api/auth/forgot-password";

  static String changePassword() => "$baseUrl/api/auth/change-password";

  static String getStudentDetailsById(int studentId) =>
      "$baseUrl/api/student/$studentId";

  static String getSchoolContact() => "$baseUrl/api/school/contact";
}
