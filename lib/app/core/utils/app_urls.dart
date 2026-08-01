class AppUrls {
  static late String baseUrl;

  // tenant
  static String getTenantBySchoolCode(String schoolCode) =>
      "$baseUrl/auth/tenant/$schoolCode";

  // auth
  static String login() => "$baseUrl/api/auth/login";

  static String forgotPassword() => "$baseUrl/api/auth/forgot-password";

  static String changePassword() => "$baseUrl/api/auth/change-password";

  static String getSchoolContact() => "$baseUrl/api/auth/school/contact";

  // student
  static String getStudentHome() => "$baseUrl/api/student/home";

  static String getStudentTimetable() => "$baseUrl/api/student/timetable";

  static String getStudentExams() => "$baseUrl/api/student/exams";

  static String getStudentHomework() => "$baseUrl/api/student/homework";

  static String getStudentHomeworkDetail(int homeworkId) =>
      "$baseUrl/api/student/homework/$homeworkId";

  static String getStudentNotes() => "$baseUrl/api/student/notes";

  static String getStudentNoteDetail(int noteId) =>
      "$baseUrl/api/student/notes/$noteId";

  static String getStudentDetailsById(int studentId) =>
      "$baseUrl/api/student/$studentId";

  // fee
  static String getFeeDetail() => "$baseUrl/api/student/fee/detail";

  static String createFeeOrder() => "$baseUrl/api/student/fee/create-order";

  static String verifyFeePayment() => "$baseUrl/api/student/fee/verify-payment";
}
