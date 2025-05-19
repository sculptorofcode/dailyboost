class QuoteModel {
  final String id;
  final String content;
  final String author;
  final String mood;
  final int viewCount;

  QuoteModel({
    required this.id,
    required this.content,
    required this.author,
    required this.mood,
    this.viewCount = 0,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      id: json['id'].toString(),
      content: json['content'] as String,
      author: json['author'] as String,
      mood: json['mood'] as String,
      viewCount: json['viewCount'] is int ? json['viewCount'] as int : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'author': author,
      'mood': mood,
      'viewCount': viewCount,
    };
  }
}
