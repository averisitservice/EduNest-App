class TenantModel {
  final int tenantId;
  final String schoolCode;
  final String tenantName;
  final String schoolBannerUrl;
  final String logoUrl;
  final String singleLogoUrl;
  final String primaryColor;
  final String faviconUrl;
  final String city;
  final String state;
  final bool isHostel;

  const TenantModel({
    required this.tenantId,
    required this.schoolCode,
    required this.tenantName,
    required this.schoolBannerUrl,
    required this.logoUrl,
    required this.singleLogoUrl,
    required this.primaryColor,
    required this.faviconUrl,
    required this.city,
    required this.state,
    required this.isHostel,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      tenantId: json['tenantId'] ?? 0,
      schoolCode: json['schoolCode'] ?? "",
      tenantName: json['tenantName'] ?? "",
      schoolBannerUrl: json['schoolBannerUrl'] ?? "",
      logoUrl: json['logoUrl'] ?? "",
      singleLogoUrl: json['singleLogoUrl'] ?? "",
      primaryColor: json['primaryColor'] ?? "",
      faviconUrl: json['faviconUrl'] ?? "",
      city: json['city'] ?? "",
      state: json['state'] ?? "",
      isHostel: json['isHostel'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tenantId': tenantId,
      'schoolCode': schoolCode,
      'tenantName': tenantName,
      'schoolBannerUrl': schoolBannerUrl,
      'logoUrl': logoUrl,
      'singleLogoUrl': singleLogoUrl,
      'primaryColor': primaryColor,
      'faviconUrl': faviconUrl,
      'city': city,
      'state': state,
      'isHostel': isHostel,
    };
  }
}
