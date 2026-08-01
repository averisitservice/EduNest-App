class StudentModel {
  final int studentId;
  final String admissionNo;
  final String studentName;
  final String email;
  final String mobileNo;
  final String photoUrl;
  final String displayClass;
  final String rollNo;

  const StudentModel({
    required this.studentId,
    required this.admissionNo,
    required this.studentName,
    required this.email,
    required this.mobileNo,
    required this.photoUrl,
    required this.displayClass,
    required this.rollNo,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      studentId: json['studentId'] ?? 0,
      admissionNo: json['admissionNo'] ?? "",
      studentName: json['studentName'] ?? "",
      email: json['email'] ?? "",
      mobileNo: json['mobileNo'] ?? "",
      photoUrl: json['photoUrl'] ?? "",
      displayClass: json['displayClass'] ?? "",
      rollNo: json['rollNo'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'admissionNo': admissionNo,
      'studentName': studentName,
      'email': email,
      'mobileNo': mobileNo,
      'photoUrl': photoUrl,
      'displayClass': displayClass,
      'rollNo': rollNo,
    };
  }
}
