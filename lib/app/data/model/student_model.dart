class StudentModel {
  final int studentId;
  final String admissionNo;
  final String username;
  final String studentName;
  final String email;
  final String mobileNo;
  final String photoUrl;
  final bool isHostel;

  // Current class placement
  final int classId;
  final String className;
  final int sectionId;
  final String sectionName;
  final String displayClass;
  final String rollNo;

  const StudentModel({
    required this.studentId,
    required this.admissionNo,
    required this.username,
    required this.studentName,
    required this.email,
    required this.mobileNo,
    required this.photoUrl,
    required this.isHostel,
    required this.classId,
    required this.className,
    required this.sectionId,
    required this.sectionName,
    required this.displayClass,
    required this.rollNo,
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
      classId: json['classId'] ?? 0,
      className: json['className'] ?? "",
      sectionId: json['sectionId'] ?? 0,
      sectionName: json['sectionName'] ?? "",
      displayClass: json['displayClass'] ?? "",
      rollNo: json['rollNo'] ?? "",
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
      'classId': classId,
      'className': className,
      'sectionId': sectionId,
      'sectionName': sectionName,
      'displayClass': displayClass,
      'rollNo': rollNo,
    };
  }
}
