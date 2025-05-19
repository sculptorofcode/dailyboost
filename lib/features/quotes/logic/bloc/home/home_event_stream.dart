import 'dart:async';

import '../../../data/models/quote_model.dart';

class HomeEventStreamController {
  static final HomeEventStreamController _instance = HomeEventStreamController._internal();
  
  factory HomeEventStreamController() {
    return _instance;
  }
  
  HomeEventStreamController._internal();
  
  // Stream controllers for like/unlike events
  final _likeController = StreamController<QuoteModel>.broadcast();
  final _unlikeController = StreamController<String>.broadcast();
  
  // Expose streams
  Stream<QuoteModel> get onLikeStream => _likeController.stream;
  Stream<String> get onUnlikeStream => _unlikeController.stream;
  
  // Methods to add events to the streams
  void addLike(QuoteModel quote) {
    _likeController.add(quote);
  }
  
  void addUnlike(String id) {
    _unlikeController.add(id);
  }
  
  // Clean up resources
  void dispose() {
    _likeController.close();
    _unlikeController.close();
  }
}
