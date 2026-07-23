class StudentModel {
  final int studentId;
  final String admissionNo;
  final String username;
  final String studentName;
  final String email;
  final String mobileNo;
  final String photoUrl;
  final bool isHostel;

  const StudentModel({
    required this.studentId,
    required this.admissionNo,
    required this.username,
    required this.studentName,
    required this.email,
    required this.mobileNo,
    required this.photoUrl,
    required this.isHostel,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      studentId: json['studentId'] ?? 0,
      admissionNo: json['admissionNo'] ?? "",
      username: json['username'] ?? "",
      studentName: json['studentName'] ?? "",
      email: json['email'] ?? "",
      mobileNo: json['mobileNo'] ?? "",
      photoUrl: json['photoUrl'] ?? "",
      isHostel: json['isHostel'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'admissionNo': admissionNo,
      'username': username,
      'studentName': studentName,
      'email': email,
      'mobileNo': mobileNo,
      'photoUrl': photoUrl,
      'isHostel': isHostel,
    };
  }
}
