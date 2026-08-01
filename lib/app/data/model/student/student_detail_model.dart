class StudentDetailModel {
  final int studentId;
  final String admissionNo;
  final String studentName;
  final String photoUrl;

  final String dateOfBirth;
  final String gender;
  final String aadharNo;
  final String email;
  final String mobileNo;

  final String displayClass;
  final String rollNo;
  final String classTeacherName;

  final String fatherName;
  final String motherName;
  final String parentMobile;
  final String parentEmail;
  final String parentAadhar;

  final String address;

  const StudentDetailModel({
    required this.studentId,
    required this.admissionNo,
    required this.studentName,
    required this.photoUrl,
    required this.dateOfBirth,
    required this.gender,
    required this.aadharNo,
    required this.email,
    required this.mobileNo,
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
      studentName: json['studentName'] ?? "",
      photoUrl: json['photoUrl'] ?? "",
      dateOfBirth: json['dateOfBirth'] ?? "",
      gender: json['gender'] ?? "",
      aadharNo: json['aadharNo'] ?? "",
      email: json['email'] ?? "",
      mobileNo: json['mobileNo'] ?? "",
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
