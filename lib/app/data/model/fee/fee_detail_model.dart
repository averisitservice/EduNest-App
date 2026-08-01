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
  final double amount;
  final String paymentDate;
  final String paymentMode;
  final String receiptNo;

  const FeePaymentItem({
    required this.amount,
    required this.paymentDate,
    required this.paymentMode,
    required this.receiptNo,
  });

  factory FeePaymentItem.fromJson(Map<String, dynamic> json) {
    return FeePaymentItem(
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      paymentDate: json['paymentDate'] ?? '',
      paymentMode: json['paymentMode'] ?? '',
      receiptNo: json['receiptNo'] ?? '',
    );
  }
}
