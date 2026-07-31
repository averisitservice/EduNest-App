class FeeDetailModel {
  final int studentId;
  final String studentName;
  final String displayClass;
  final String rollNo;
  final String academicYearName;
  final double totalFee;
  final double paidAmount;
  final double pendingAmount;
  final List<FeePaymentItem> payments;

  const FeeDetailModel({
    required this.studentId,
    required this.studentName,
    required this.displayClass,
    required this.rollNo,
    required this.academicYearName,
    required this.totalFee,
    required this.paidAmount,
    required this.pendingAmount,
    required this.payments,
  });

  factory FeeDetailModel.fromJson(Map<String, dynamic> json) {
    final rawPayments = json['payments'] as List? ?? [];
    return FeeDetailModel(
      studentId: json['studentId'] ?? 0,
      studentName: json['studentName'] ?? '',
      displayClass: json['displayClass'] ?? '',
      rollNo: json['rollNo'] ?? '',
      academicYearName: json['academicYearName'] ?? '',
      totalFee: (json['totalFee'] as num?)?.toDouble() ?? 0,
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0,
      pendingAmount: (json['pendingAmount'] as num?)?.toDouble() ?? 0,
      payments: rawPayments.map((e) => FeePaymentItem.fromJson(e)).toList(),
    );
  }
}

class FeePaymentItem {
  final int feePaymentId;
  final double amount;
  final String paymentDate;
  final String paymentMode;
  final String receiptNo;
  final String? remarks;
  final String? collectedBy;

  const FeePaymentItem({
    required this.feePaymentId,
    required this.amount,
    required this.paymentDate,
    required this.paymentMode,
    required this.receiptNo,
    required this.remarks,
    required this.collectedBy,
  });

  factory FeePaymentItem.fromJson(Map<String, dynamic> json) {
    return FeePaymentItem(
      feePaymentId: json['feePaymentId'] ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      paymentDate: json['paymentDate'] ?? '',
      paymentMode: json['paymentMode'] ?? '',
      receiptNo: json['receiptNo'] ?? '',
      remarks: json['remarks'],
      collectedBy: json['collectedBy'],
    );
  }
}
