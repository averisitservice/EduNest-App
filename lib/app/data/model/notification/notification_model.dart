class StudentNotificationItem {
  final int notificationId;
  final String type;
  final int? referenceId;
  final String title;
  final String body;
  final bool isRead;
  final String? createdDate;

  const StudentNotificationItem({
    required this.notificationId,
    required this.type,
    required this.referenceId,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdDate,
  });

  factory StudentNotificationItem.fromJson(Map<String, dynamic> json) {
    return StudentNotificationItem(
      notificationId: json['notificationId'] ?? 0,
      type: json['type'] ?? "",
      referenceId: json['referenceId'],
      title: json['title'] ?? "",
      body: json['body'] ?? "",
      isRead: json['isRead'] ?? false,
      createdDate: json['createdDate'],
    );
  }
}

class StudentNotificationPage {
  final List<StudentNotificationItem> content;
  final int totalElements;
  final int totalPages;
  final int page;
  final int size;

  const StudentNotificationPage({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.page,
    required this.size,
  });

  bool get hasMore => page + 1 < totalPages;

  factory StudentNotificationPage.fromJson(Map<String, dynamic> json) {
    final rawContent = json['content'] as List? ?? [];
    return StudentNotificationPage(
      content: rawContent.map((e) => StudentNotificationItem.fromJson(e)).toList(),
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      page: json['page'] ?? 0,
      size: json['size'] ?? 10,
    );
  }
}
