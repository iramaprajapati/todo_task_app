import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String? id;
  String userId;
  String title;
  String description;
  DateTime deadline;
  int duration;
  bool isCompleted;

  Task({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.deadline,
    required this.duration,
    required this.isCompleted,
  });

  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Task(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      deadline: (data['deadline'] as Timestamp).toDate(),
      duration: data['duration'] ?? 0,
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'deadline': deadline,
      'duration': duration,
      'isCompleted': isCompleted,
    };
  }
}
