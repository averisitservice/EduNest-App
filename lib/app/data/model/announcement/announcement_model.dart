class AnnouncementItem {
  final int announcementId;
  final String title;
  final String message;
  final String? publishDate;

  const AnnouncementItem({
    required this.announcementId,
    required this.title,
    required this.message,
    required this.publishDate,
  });

  factory AnnouncementItem.fromJson(Map<String, dynamic> json) {
    return AnnouncementItem(
      announcementId: json['announcementId'] ?? 0,
      title: json['title'] ?? "",
      message: json['message'] ?? "",
      publishDate: json['publishDate'],
    );
  }
}
