class FeeOrderModel {
  final int razorpayOrderId;
  final String razorpayOrderRef;
  final double amount;
  final String currency;
  final String keyId;

  const FeeOrderModel({
    required this.razorpayOrderId,
    required this.razorpayOrderRef,
    required this.amount,
    required this.currency,
    required this.keyId,
  });

  factory FeeOrderModel.fromJson(Map<String, dynamic> json) {
    return FeeOrderModel(
      razorpayOrderId: json['razorpayOrderId'] ?? 0,
      razorpayOrderRef: json['razorpayOrderRef'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] ?? 'INR',
      keyId: json['keyId'] ?? '',
    );
  }
}
