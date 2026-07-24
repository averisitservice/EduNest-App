class StudentDetailModel {
  final int studentId;
  final String admissionNo;
  final String username;
  final String studentName;
  final String photoUrl;

  // Personal
  final String dateOfBirth;
  final String gender;
  final String aadharNo;
  final String email;
  final String mobileNo;
  final bool isHostel;

  // Class placement
  final int classId;
  final String className;
  final int sectionId;
  final String sectionName;
  final String displayClass;
  final String rollNo;
  final String classTeacherName;

  // Parents
  final String fatherName;
  final String motherName;
  final String parentMobile;
  final String parentEmail;
  final String parentAadhar;

  // Full address on one line, e.g. "Block A, Pune, Maharashtra - 411001"
  final String address;

  const StudentDetailModel({
    required this.studentId,
    required this.admissionNo,
    required this.username,
    required this.studentName,
    required this.photoUrl,
    required this.dateOfBirth,
    required this.gender,
    required this.aadharNo,
    required this.email,
    required this.mobileNo,
    required this.isHostel,
    required this.classId,
    required this.className,
    required this.sectionId,
    required this.sectionName,
    required this.displayClass,
    required this.rollNo,
    required this.classTeacherName,
    required this.fatherName,
    required this.motherName,
    required this.parentMobile,
    required this.parentEmail,
    required this.parentAadhar,
    required this.address,
  });

  factory StudentDetailModel.fromJson(Map<String, dynamic> json) {
    return StudentDetailModel(
      studentId: json['studentId'] ?? 0,
      admissionNo: json['admissionNo'] ?? "",
      username: json['username'] ?? "",
      studentName: json['studentName'] ?? "",
      photoUrl: json['photoUrl'] ?? "",
      dateOfBirth: json['dateOfBirth'] ?? "",
      gender: json['gender'] ?? "",
      aadharNo: json['aadharNo'] ?? "",
      email: json['email'] ?? "",
      mobileNo: json['mobileNo'] ?? "",
      isHostel: json['isHostel'] ?? false,
      classId: json['classId'] ?? 0,
      className: json['className'] ?? "",
      sectionId: json['sectionId'] ?? 0,
      sectionName: json['sectionName'] ?? "",
      displayClass: json['displayClass'] ?? "",
      rollNo: json['rollNo'] ?? "",
      classTeacherName: json['classTeacherName'] ?? "",
      fatherName: json['fatherName'] ?? "",
      motherName: json['motherName'] ?? "",
      parentMobile: json['parentMobile'] ?? "",
      parentEmail: json['parentEmail'] ?? "",
      parentAadhar: json['parentAadhar'] ?? "",
      address: json['address'] ?? "",
    );
  }
}
