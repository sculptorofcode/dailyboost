import 'package:cloud_firestore/cloud_firestore.dart';

class CustomQuoteModel {
  final String id;
  final String content;
  final String author;
  final String mood;
  final String? userId;
  final Timestamp createdAt;
  final bool isPublic;

  CustomQuoteModel({
    required this.id,
    required this.content,
    required this.author,
    required this.mood,
    required this.userId,
    required this.createdAt,
    this.isPublic = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'author': author,
      'mood': mood,
      'userId': userId,
      'createdAt': createdAt,
      'isPublic': isPublic,
    };
  }

  factory CustomQuoteModel.fromMap(Map<String, dynamic> map, String docId) {
    return CustomQuoteModel(
      id: map['id'] ?? docId,
      content: map['content'] ?? '',
      author: map['author'] ?? 'Anonymous',
      mood: map['mood'] ?? 'General',
      userId: map['userId'],
      createdAt: map['createdAt'] ?? Timestamp.now(),
      isPublic: map['isPublic'] ?? false,
    );
  }

  // Create a copy of this quote with modified fields
  CustomQuoteModel copyWith({
    String? id,
    String? content,
    String? author,
    String? mood,
    String? userId,
    Timestamp? createdAt,
    bool? isPublic,
  }) {
    return CustomQuoteModel(
      id: id ?? this.id,
      content: content ?? this.content,
      author: author ?? this.author,
      mood: mood ?? this.mood,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      isPublic: isPublic ?? this.isPublic,
    );
  }
}