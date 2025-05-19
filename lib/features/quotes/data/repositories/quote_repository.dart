import 'dart:convert';
import 'dart:math';

import 'package:dailyboost/features/quotes/data/models/quote_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuoteRepository {
  // Supabase client
  final SupabaseClient _supabase = Supabase.instance.client;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Local storage
  late Box<List<dynamic>> _favoritesBox;

  // Cache of all quotes
  List<QuoteModel> _allQuotes = [];

  // Pagination parameters
  int? _lastQuoteId;
  bool _hasMore = true;

  // Helper to get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  // Initialize the repository
  Future<void> initialize() async {
    // Initialize Hive box
    _favoritesBox = await Hive.openBox<List<dynamic>>('favorites');

    // Load local quotes initially
    await _loadLocalQuotes();
  }

  // Reset pagination state for new queries
  void resetPagination() {
    _lastQuoteId = null;
    _hasMore = true;
  }

  // Load quotes from local JSON file
  Future<void> _loadLocalQuotes() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/quotes.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);

      _allQuotes = jsonList.map((json) => QuoteModel.fromJson(json)).toList();
    } catch (e) {
      // If loading fails, initialize with empty list
      _allQuotes = [];
      debugPrint('Error loading local quotes: $e');
    }
  }

  // Fetch quotes with optional pagination
  Future<Map<String,dynamic>> fetchQuotes({int limit = 10}) async {
    try {
      // Get total count first
      final countResponse = await _supabase
          .from('custom_quotes')
          .count();
      final int totalCount = countResponse;
      
      final data = await _supabase
          .from('custom_quotes')
          .select()
          .order('created_at', ascending: false)
          .range(_lastQuoteId == null ? 0 : 1, limit - 1);
      
      if (data.isNotEmpty) {
        _lastQuoteId = data.last['id'];
        _hasMore = _lastQuoteId != null && data.length >= limit;
        debugPrint('Fetched ${data.length} quotes. Total count: $totalCount');
        return {
          'quotes': data.map((json) => QuoteModel.fromJson(json)).toList(),
          'totalCount': totalCount,
        };
      } else {
        debugPrint('No online quotes found. Using local quotes. Total: ${_allQuotes.length}');
        final quotes = _getRandomQuotesFromLocal(limit);
        return {
          'quotes': quotes,
          'totalCount': _allQuotes.length,
        };
      }
    } catch (e) {
      debugPrint('Error fetching quotes: $e');
      final quotes = _getRandomQuotesFromLocal(limit);
      return {
        'quotes': quotes,
        'totalCount': _allQuotes.length,
      };
    }
  }

  // Get more quotes (used for pagination)
  Future<Map<String,dynamic>> fetchMoreQuotes({int limit = 20}) async {
    if (!_hasMore) {
      return {
        'quotes': [],
        'totalCount': _allQuotes.length,
      };
    }

    return fetchQuotes(limit: limit);
  }

  // Get random quotes from local cache
  List<QuoteModel> _getRandomQuotesFromLocal(int count) {
    if (_allQuotes.isEmpty) {
      return [];
    }

    // Shuffle and take a subset
    final random = Random();
    final shuffled = List<QuoteModel>.from(_allQuotes)..shuffle(random);

    return shuffled.take(min(count, shuffled.length)).toList();
  }

  // Fetch a quote by mood
  Future<Map<String, dynamic>> fetchQuoteByMood(
    String mood, {
    int? startAfter,
  }) async {
    try {
      if (startAfter == null || startAfter == 0) {
        resetPagination();
      }
      final countResponse = await _supabase
          .from('custom_quotes')
          .select()
          .eq('mood', mood)
          .count();
      final totalQuotes = countResponse.count;

      final data = await _supabase
          .from('custom_quotes')
          .select()
          .eq('mood', mood)
          .order('created_at', ascending: false)
          .range(startAfter ?? 0, (startAfter ?? 0) + 19);
      if (data.isNotEmpty) {
        _lastQuoteId = data.last['id'];
        _hasMore = data.length >= 20;
        return {
          'quotes': data.map((json) => QuoteModel.fromJson(json)).toList(),
          'totalCount': totalQuotes,
        };
      } else {
        // If no online quotes, return from local cache
        final matchingQuotes =
            _allQuotes
                .where(
                  (quote) => quote.mood.toLowerCase() == mood.toLowerCase(),
                )
                .toList();

        if (matchingQuotes.isNotEmpty) {
          // If we have a startAfter value, handle pagination for local quotes
          if (startAfter != null && startAfter > 0) {
            final end = min(startAfter + 20, matchingQuotes.length);
            if (startAfter < matchingQuotes.length) {
              return {
                'quotes': matchingQuotes.sublist(startAfter, end),
                'totalCount': matchingQuotes.length,
              };
            } else {
              return {
                'quotes': [],
                'totalCount': matchingQuotes.length,
              }; // No more quotes
            }
          } else {
            return {
              'quotes': matchingQuotes.take(min(20, matchingQuotes.length)).toList(),
              'totalCount': matchingQuotes.length,
            };
          }
        }

        return {
          'quotes': [],
          'totalCount': 0,
        };
      }
    } catch (e) {
      debugPrint('Error fetching quote by mood: $e');
      return {
        'quotes': [],
        'totalCount': 0,
      };
    }
  }

  // Fetch a quote by ID
  Future<QuoteModel?> fetchQuoteById(String id) async {
    try {
      try {
        final localQuote = _allQuotes.firstWhere((quote) => quote.id == id);
        return localQuote;
      } catch (e) {}
      final data =
          await _supabase
              .from('custom_quotes')
              .select()
              .eq('id', id)
              .maybeSingle();
      if (data != null) {
        return QuoteModel.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching quote by ID: $e');
      return null;
    }
  }

  // FAVORITES MANAGEMENT
  // Add a quote to favorites
  Future<void> addFavorite(QuoteModel quote) async {
    try {
      if (_currentUserId == null) {
        throw Exception('You must be logged in to add favorites');
      }
      
      await _supabase.from('user_favorites').insert({
        'user_id': _currentUserId!,
        'quote_id': quote.id,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      // Also save to local storage for offline access
      final favorites = await getFavorites();

      if (!favorites.any((fav) => fav.id == quote.id)) {
        final localFavorites =
            _favoritesBox.get('favorites', defaultValue: <dynamic>[])
                as List<dynamic>;
        localFavorites.add({
          'quote_id': quote.id,
          'timestamp': DateTime.now().toIso8601String(),
        });
        await _favoritesBox.put('favorites', localFavorites);
      }

      // Clear cache since favorites changed
      _clearFavoritesCache();
    } catch (e) {
      debugPrint('Error adding favorite: $e');
      rethrow;
    }
  }

  // Remove a quote from favorites
  Future<void> removeFavorite(String id) async {
    try {
      if (_currentUserId == null) {
        throw Exception('You must be logged in to remove favorites');
      }
      
      await _supabase
          .from('user_favorites')
          .delete()
          .eq('user_id', _currentUserId!)
          .eq('quote_id', id);

      // Also remove from local storage
      final localFavorites =
          _favoritesBox.get('favorites', defaultValue: <dynamic>[])
              as List<dynamic>;
      final updatedFavorites =
          localFavorites
              .whereType<Map<dynamic, dynamic>>()
              .where((favorite) => favorite['quote_id'] != id)
              .toList();

      await _favoritesBox.put('favorites', updatedFavorites);

      // Clear cache since favorites changed
      _clearFavoritesCache();
    } catch (e) {
      debugPrint('Error removing favorite: $e');
      rethrow;
    }
  } // Cache for favorites to avoid repeated database/network calls

  List<QuoteModel>? _favoritesCache;
  DateTime? _favoritesCacheTime;
  final Duration _favoritesCacheMaxAge = const Duration(minutes: 5);

  bool _isFavoritesCacheValid() {
    if (_favoritesCache == null || _favoritesCacheTime == null) {
      return false;
    }
    final now = DateTime.now();
    return now.difference(_favoritesCacheTime!) < _favoritesCacheMaxAge;
  }

  // Clear favorites cache when user adds or removes favorites
  void _clearFavoritesCache() {
    _favoritesCache = null;
    _favoritesCacheTime = null;
  }

  // Get all favorite quotes with complete data
  Future<List<QuoteModel>> getFavorites() async {
    // Check if we have a valid cache
    if (_isFavoritesCacheValid() && _favoritesCache != null) {
      debugPrint('Using cached favorites (${_favoritesCache!.length} items)');
      return _favoritesCache!;
    }

    final List<QuoteModel> favorites = [];

    try {
      // First check the local storage
      _favoritesBox = await Hive.openBox<List<dynamic>>('favorites');
      final localFavorites =
          _favoritesBox.get('favorites', defaultValue: <dynamic>[])
              as List<dynamic>;
      final localFavoriteIds =
          localFavorites
              .whereType<Map<dynamic, dynamic>>()
              .map((fav) => fav['quote_id'] as String)
              .toList();

      // Add local quotes from cache
      for (final id in localFavoriteIds) {
        try {
          final localQuote = _allQuotes.firstWhere(
            (quote) => quote.id == id,
            orElse: () => throw Exception('Not found in local cache'),
          );
          favorites.add(localQuote);
        } catch (e) {
          // Will try to get from online if not found locally
          debugPrint('Quote $id not found in local cache, will try online');
        }
      }

      // If user is logged in, get online favorites with joined quote data
      if (_currentUserId != null) {
        try {
          final data = await _supabase
              .from('user_favorites')
              .select('quote_id, custom_quotes!inner(*)')
              .eq('user_id', _currentUserId!);

          if (data.isNotEmpty) {
            for (final item in data) {
              final quoteData = item['custom_quotes'] as Map<String, dynamic>;
              final quote = QuoteModel.fromJson(quoteData);

              // Only add if not already added from local cache
              if (!favorites.any(
                (existingQuote) => existingQuote.id == quote.id,
              )) {
                favorites.add(quote);
              }
            }

            // Update local cache with the IDs for future offline access
            final onlineFavoriteIds =
                (data as List<dynamic>)
                    .map((item) => item['quote_id'].toString())
                    .toList();
            await syncFavoritesToLocal(onlineFavoriteIds);
          }
        } catch (e) {
          debugPrint('Error getting online favorites with join: $e');
          // Fall back to fetching quotes individually if the join fails
          try {
            final data = await _supabase
                .from('user_favorites')
                .select('quote_id')
                .eq('user_id', _currentUserId!);

            for (final item in data) {
              final id = item['quote_id'].toString();
              // Only fetch if not already added from local cache
              if (!favorites.any((existingQuote) => existingQuote.id == id)) {
                final quote = await fetchQuoteById(id);
                if (quote != null) {
                  favorites.add(quote);
                }
              }
            }
          } catch (e) {
            debugPrint('Error fetching online favorites fallback: $e');
          }
        }
      }

      // Update cache
      _favoritesCache = favorites;
      _favoritesCacheTime = DateTime.now();

      return favorites;
    } catch (e) {
      debugPrint('Error getting favorites: $e');
      return [];
    }
  }

  // Check if a quote is in favorites
  Future<bool> isFavorite(String id) async {
    if (_isFavoritesCacheValid() && _favoritesCache != null) {
      // Use cache if available
      return _favoritesCache!.any((quote) => quote.id == id);
    }

    final favorites = await getFavorites();
    return favorites.any((quote) => quote.id == id);
  }

  // Sync favorites between Supabase and local storage
  Future<void> syncFavoritesToLocal(List<String> favoriteIds) async {
    try {
      // Get current local favorites
      final localFavorites =
          _favoritesBox.get('favorites', defaultValue: <dynamic>[])
              as List<dynamic>;
      final localFavoriteIds =
          localFavorites
              .whereType<Map<dynamic, dynamic>>()
              .map((fav) => fav['quote_id'] as String)
              .toList();

      // Remove any IDs that are no longer favorites
      final updatedFavorites =
          localFavorites
              .whereType<Map<dynamic, dynamic>>()
              .where((favorite) => favoriteIds.contains(favorite['quote_id']))
              .toList();

      await _favoritesBox.put('favorites', updatedFavorites);

      // Add any new favorites that are not already in local storage
      for (final id in favoriteIds) {
        if (!localFavoriteIds.contains(id)) {
          updatedFavorites.add({
            'quote_id': id,
            'timestamp': DateTime.now().toIso8601String(),
          });
        }
      }

      await _favoritesBox.put('favorites', updatedFavorites);

      // Clear cache since favorites changed
      _clearFavoritesCache();
    } catch (e) {
      debugPrint('Error syncing favorites: $e');
    }
  }

  // LIKE MANAGEMENT
  Future<void> addLike(QuoteModel quote) async {
    try {
      if (_currentUserId == null) {
        throw Exception('You must be logged in to like quotes');
      }
      
      await _supabase.from('user_likes').insert({
        'user_id': _currentUserId!,
        'quote_id': quote.id,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error adding like: $e');
      rethrow;
    }
  }

  Future<void> removeLike(String id) async {
    try {
      if (_currentUserId == null) {
        throw Exception('You must be logged in to unlike quotes');
      }
      
      await _supabase
          .from('user_likes')
          .delete()
          .eq('user_id', _currentUserId!)
          .eq('quote_id', id);
    } catch (e) {
      debugPrint('Error removing like: $e');
      rethrow;
    }
  }

  // Fetch all liked quote IDs for the current user
  Future<List<String>> getLikedQuoteIds() async {
    if (_currentUserId == null) return [];
    try {
      final data = await _supabase
          .from('user_likes')
          .select('quote_id')
          .eq('user_id', _currentUserId!);
      if (data.isNotEmpty) {
        return (data as List<dynamic>)
            .map((item) => item['quote_id'].toString())
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching liked quote IDs: $e');
      return [];
    }
  }

  // VIEW MANAGEMENT
  Future<void> incrementViewCount(String quoteId) async {
    try {
      // Fetch current view count
      final row =
          await _supabase
              .from('custom_quotes')
              .select('viewCount')
              .eq('id', quoteId)
              .maybeSingle();
      final currentCount =
          (row != null && row['viewCount'] != null)
              ? row['viewCount'] as int
              : 0;
      await _supabase
          .from('custom_quotes')
          .update({'viewCount': currentCount + 1})
          .eq('id', quoteId);
    } catch (e) {
      debugPrint('Error incrementing view count: $e');
    }
  }

  Future<int> fetchViewCount(String quoteId) async {
    try {
      final row =
          await _supabase
              .from('custom_quotes')
              .select('viewCount')
              .eq('id', quoteId)
              .maybeSingle();
      if (row != null && row['viewCount'] != null) {
        return row['viewCount'] as int;
      }
      return 0;
    } catch (e) {
      debugPrint('Error fetching view count: $e');
      return 0;
    }
  }

  Future<void> trackUserView(String quoteId) async {
    if (_currentUserId == null) return;
    
    final row =
        await _supabase
            .from('user_views')
            .select('quote_id')
            .eq('user_id', _currentUserId!)
            .eq('quote_id', quoteId)
            .maybeSingle();
    final alreadyViewed = row != null;
    if (!alreadyViewed) {
      await _supabase.from('user_views').insert({
        'user_id': _currentUserId!,
        'quote_id': quoteId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      await incrementViewCount(quoteId);
    }
  }

  Future<List<String>> getViewedQuoteIds() async {
    if (_currentUserId == null) return [];
    try {
      final data = await _supabase
          .from('user_views')
          .select('quote_id')
          .eq('user_id', _currentUserId!);
      if (data.isNotEmpty) {
        return (data as List<dynamic>)
            .map((item) => item['quote_id'].toString())
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching viewed quote IDs: $e');
      return [];
    }
  }

  // Filter unread quotes from a list of quotes
  Future<List<QuoteModel>> filterUnreadQuotes(
    List<QuoteModel> allQuotes,
  ) async {
    final viewedIds = await getViewedQuoteIds();
    return allQuotes.where((q) => !viewedIds.contains(q.id)).toList();
  }
  
  // Check if user is logged in
  bool isUserLoggedIn() {
    return _currentUserId != null;
  }
}
