class QuoteModel {
  final String id;
  final String content;
  final String author;
  final String mood;

  QuoteModel({
    required this.id,
    required this.content,
    required this.author,
    required this.mood,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      id: json['id'] as String,
      content: json['content'] as String,
      author: json['author'] as String,
      mood: json['mood'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'content': content, 'author': author, 'mood': mood};
  }
}
