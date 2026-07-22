class AppUrls {
  static late String baseUrl;

  static String getTenantBySchoolCode(String schoolCode) =>
      "$baseUrl/auth/tenant/$schoolCode";
}
