class HomeworkModelItem {
  final int id;
  final String subjectName;
  final String title;
  final String description;
  final String dueDate;
  final String? attachmentUrl;
  final String updatedDate;

  const HomeworkModelItem({
    required this.id,
    required this.subjectName,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.attachmentUrl,
    required this.updatedDate,
  });

  factory HomeworkModelItem.fromJson(Map<String, dynamic> json) {
    return HomeworkModelItem(
      id: json['homeworkId'] ?? json['noteId'] ?? 0,
      subjectName: json['subjectName'] ?? 'General',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dueDate: json['dueDate'] ?? '',
      attachmentUrl: json['attachmentUrl'],
      updatedDate: json['updatedDate'] ?? '',
    );
  }
}

class HomeworkDetailModel {
  final int id;
  final String subjectName;
  final String title;
  final String description;
  final String dueDate;
  final String? attachmentUrl;
  final String teacherName;
  final String updatedDate;

  const HomeworkDetailModel({
    required this.id,
    required this.subjectName,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.attachmentUrl,
    required this.teacherName,
    required this.updatedDate,
  });

  factory HomeworkDetailModel.fromJson(Map<String, dynamic> json) {
    return HomeworkDetailModel(
      id: json['homeworkId'] ?? json['noteId'] ?? 0,
      subjectName: json['subjectName'] ?? 'General',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dueDate: json['dueDate'] ?? '',
      attachmentUrl: json['attachmentUrl'],
      teacherName: json['teacherName'] ?? 'Subject Teacher',
      updatedDate: json['updatedDate'] ?? '',
    );
  }
}
