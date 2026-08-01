class SchoolContactModel {
  final String schoolName;
  final String logoUrl;
  final String contactName;
  final String contactEmail;
  final String contactPhone;
  final String website;
  final String address;

  const SchoolContactModel({
    required this.schoolName,
    required this.logoUrl,
    required this.contactName,
    required this.contactEmail,
    required this.contactPhone,
    required this.website,
    required this.address,
  });

  factory SchoolContactModel.fromJson(Map<String, dynamic> json) {
    return SchoolContactModel(
      schoolName: json['schoolName'] ?? "",
      logoUrl: json['logoUrl'] ?? "",
      contactName: json['contactName'] ?? "",
      contactEmail: json['contactEmail'] ?? "",
      contactPhone: json['contactPhone'] ?? "",
      website: json['website'] ?? "",
      address: json['address'] ?? "",
    );
  }
}
