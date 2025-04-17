import 'dart:convert';
import 'package:dailyboost/features/quotes/data/models/quote_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../../../core/utils/api_client.dart';

class QuoteRepository {
  static const String _favoritesKey = 'favorite_quotes';
  static const String _localJsonPath = 'assets/quotes.json';

  // Cache to store all fetched quotes
  List<QuoteModel> _cachedQuotes = [];

  final ApiClient _apiClient = ApiClient();

  Future<List<QuoteModel>> fetchQuotes() async {
    try {
      final response = await _apiClient.get(path: 'quotes');
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
      batchToReturn.length < _cachedQuotes.length ? batchToReturn.length : 0,
    );

    return batchToReturn;
  }

  Future<QuoteModel?> fetchQuoteById(String quoteId) async {
    try {
      final response = await _apiClient.get(path: 'quotes/$quoteId');
      if (response.statusCode == 200) {
        // debugPrint('Response: ${response.data}');
        final q = response.data;
        return QuoteModel(
          id: q['id']?.toString() ?? '',
          content: q['body'] ?? '',
          author: q['author'] ?? 'Unknown',
          mood: _mapTagsToMood(q['tags'] ?? []),
        );
      }
    } catch (e) {
      debugPrint('Error fetching quote by id: $e');
    }
    return null;
  }

  Future<QuoteModel?> fetchQuoteByMood(String mood) async {
    try {
      final response = await _apiClient.get(
        path: 'quotes',
        queryParameters: {'filter': mood},
      );
      if (response.statusCode == 200) {
        final data = response.data;
        final List quotes = data['quotes'] ?? [];
        if (quotes.isNotEmpty) {
          final q = quotes.first;
          return QuoteModel(
            id: q['id']?.toString() ?? '',
            content: q['body'] ?? '',
            author: q['author'] ?? 'Unknown',
            mood: _mapTagsToMood(q['tags'] ?? []),
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching quote by mood from FavQs API: $e');
    }
    // Fallback: try to find a quote by mood in local JSON
    final localData = await rootBundle.loadString(_localJsonPath);
    final List quotes = json.decode(localData);
    final filtered =
        quotes
            .where((q) => (q['mood'] ?? '').toLowerCase() == mood.toLowerCase())
            .toList();
    if (filtered.isNotEmpty) {
      return QuoteModel.fromJson(filtered.first);
    }
    return null;
  }

  // Map FavQs API tags to moods
  String _mapTagsToMood(List<dynamic> tags) {
    // debugPrint('Tags: $tags');
    final List<String> tagStrings =
        tags
            .map(
              (tag) => tag
                  .toString()
                  .replaceAll('_', ' ')
                  .replaceFirstMapped(
                    RegExp(r'^\w'),
                    (match) => match.group(0)!.toUpperCase(),
                  ),
            )
            .toList();

    if (tagStrings.isNotEmpty) {
      return tagStrings.join(', ');
    } else {
      return 'Unknown';
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
