import 'dart:convert';
import 'package:dailyboost/features/quotes/data/models/quote_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

class QuoteRepository {
  static const String _favoritesKey = 'favorite_quotes';
  static const String _localJsonPath = 'assets/quotes.json';
  // Replace with your own API key if you have one or use this public one
  static const String _apiKey = '3c8649fc551e873cb01617e6d66dbef6';
  
  // Cache to store all fetched quotes
  List<QuoteModel> _cachedQuotes = [];

  Future<List<QuoteModel>> fetchQuotes() async {
    try {
      final dio = Dio();
      dio.options.headers = {
        'Authorization': 'Token token=$_apiKey',
        'Content-Type': 'application/json',
      };

      // Using FavQs API
      final response = await dio.get(
        'https://favqs.com/api/quotes',
        queryParameters: {'filter': 'inspirational'},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List quotes = data['quotes'] ?? [];

        return quotes
            .map(
              (q) => QuoteModel(
                id: q['id']?.toString() ?? '',
                content: q['body'] ?? '',
                author: q['author'] ?? 'Unknown',
                mood: _mapTagsToMood(q['tags'] ?? []),
              ),
            )
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching quotes from FavQs API: $e');
    }

    // Final fallback to local JSON
    final localData = await rootBundle.loadString(_localJsonPath);
    final List quotes = json.decode(localData);
    return quotes.map((q) => QuoteModel.fromJson(q)).toList();
  }

  // Fetch a batch of quotes and cache them
  Future<List<QuoteModel>> fetchQuoteBatch({int batchSize = 20}) async {
    if (_cachedQuotes.isEmpty) {
      _cachedQuotes = await fetchQuotes();
      _cachedQuotes.shuffle(); // Shuffle once when initially loaded
    }
    
    // Take a batch of quotes from the cached list
    final batchToReturn = _cachedQuotes.take(batchSize).toList();
    
    return batchToReturn;
  }
  
  // Load more quotes when the user needs them
  Future<List<QuoteModel>> loadMoreQuotes({int batchSize = 20}) async {
    // If cache is empty or running low, refetch quotes
    if (_cachedQuotes.length < batchSize) {
      final newQuotes = await fetchQuotes();
      newQuotes.shuffle();
      _cachedQuotes.addAll(newQuotes);
    }
    
    // Return a batch of quotes
    final batchToReturn = _cachedQuotes.take(batchSize).toList();
    
    // Remove the returned quotes from the cache
    _cachedQuotes = _cachedQuotes.sublist(
      batchToReturn.length < _cachedQuotes.length ? batchToReturn.length : 0);
    
    return batchToReturn;
  }

  // Map FavQs API tags to moods
  String _mapTagsToMood(List<dynamic> tags) {
    final List<String> tagStrings =
        tags.map((tag) => tag.toString().toLowerCase()).toList();

    if (tagStrings.any(
      (tag) => ['happy', 'joy', 'happiness', 'laugh'].contains(tag),
    )) {
      return 'Happy';
    } else if (tagStrings.any(
      (tag) => ['sad', 'sorrow', 'grief'].contains(tag),
    )) {
      return 'Sad';
    } else if (tagStrings.any(
      (tag) =>
          ['motivational', 'inspiration', 'success', 'goals'].contains(tag),
    )) {
      return 'Motivated';
    } else if (tagStrings.any(
      (tag) => ['calm', 'peace', 'tranquil', 'serenity', 'zen'].contains(tag),
    )) {
      return 'Calm';
    } else if (tagStrings.any(
      (tag) => ['excitement', 'excited', 'thrill'].contains(tag),
    )) {
      return 'Excited';
    } else if (tagStrings.any(
      (tag) => [
        'reflection',
        'philosophy',
        'wisdom',
        'deep',
        'thought',
      ].contains(tag),
    )) {
      return 'Reflective';
    } else if (tagStrings.any(
      (tag) => ['love', 'romance', 'passion', 'heart'].contains(tag),
    )) {
      return 'Romantic';
    } else if (tagStrings.any(
      (tag) => ['anger', 'frustration', 'rage'].contains(tag),
    )) {
      return 'Angry';
    } else if (tagStrings.any(
      (tag) => ['hope', 'future', 'optimism'].contains(tag),
    )) {
      return 'Hopeful';
    } else if (tagStrings.any(
      (tag) => ['gratitude', 'thankful', 'appreciation'].contains(tag),
    )) {
      return 'Grateful';
    } else {
      return 'Reflective'; // Default mood
    }
  }

  Future<void> addFavorite(QuoteModel quote) async {
    final box = Hive.box<String>(_favoritesKey);
    if (!box.values.contains(quote.id)) {
      await box.add(quote.id);
    }
  }

  Future<void> removeFavorite(String quoteId) async {
    final box = Hive.box<String>(_favoritesKey);
    final key = box.keys.firstWhere(
      (k) => box.get(k) == quoteId,
      orElse: () => null,
    );
    if (key != null) {
      await box.delete(key);
    }
  }

  Future<List<String>> getFavorites() async {
    final box = Hive.box<String>(_favoritesKey);
    return box.values.toList();
  }

  Future<List<QuoteModel>> filterByMood(
    List<QuoteModel> quotes,
    String mood,
  ) async {
    return quotes
        .where((q) => q.mood.toLowerCase() == mood.toLowerCase())
        .toList();
  }
}
