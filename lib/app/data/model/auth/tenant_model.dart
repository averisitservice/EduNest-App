class TenantModel {
  final String tenantName;
  final String schoolBannerUrl;
  final String mobileLogoUrl;
  final String logoUrl;

  const TenantModel({
    required this.tenantName,
    required this.schoolBannerUrl,
    required this.mobileLogoUrl,
    required this.logoUrl,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      tenantName: json['tenantName'] ?? "",
      schoolBannerUrl: json['schoolBannerUrl'] ?? "",
      mobileLogoUrl: json['mobileLogoUrl'] ?? "",
      logoUrl: json['logoUrl'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tenantName': tenantName,
      'schoolBannerUrl': schoolBannerUrl,
      'mobileLogoUrl': mobileLogoUrl,
      'logoUrl': logoUrl,
    };
  }
}
