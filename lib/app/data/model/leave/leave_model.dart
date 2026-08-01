class LeaveModel {
  final int leaveId;
  final String leaveDate;
  final String reason;
  final String status;
  final String createdDate;

  const LeaveModel({
    required this.leaveId,
    required this.leaveDate,
    required this.reason,
    required this.status,
    required this.createdDate,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      leaveId: json['leaveId'] ?? 0,
      leaveDate: json['leaveDate'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? '',
      createdDate: json['createdDate'] ?? '',
    );
  }
}
