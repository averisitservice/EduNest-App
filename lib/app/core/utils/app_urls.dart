class AppUrls {
  static late String baseUrl;

  static String getTenantBySchoolCode(String schoolCode) =>
      "$baseUrl/auth/tenant/$schoolCode";

  static String login() => "$baseUrl/api/auth/login";

  static String forgotPassword() => "$baseUrl/api/auth/forgot-password";

  // STUDENT
  static String getStudentDetailsById(int studentId) =>
      "$baseUrl/api/student/$studentId";

  // SCHOOL
  static String getSchoolContact() => "$baseUrl/api/school/contact";
}
