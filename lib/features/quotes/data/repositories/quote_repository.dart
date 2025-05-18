import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/quote_model.dart';

class QuoteRepository {
  // Firebase references
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Local storage
  late Box<List<dynamic>> _favoritesBox;
  
  // Cache of all quotes
  List<QuoteModel> _allQuotes = [];
  
  // Pagination parameters
  DocumentSnapshot? _lastDocument;
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
    _lastDocument = null;
    _hasMore = true;
  }
  
  // Load quotes from local JSON file
  Future<void> _loadLocalQuotes() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/quotes.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      
      _allQuotes = jsonList.map((json) => QuoteModel.fromJson(json)).toList();
    } catch (e) {
      // If loading fails, initialize with empty list
      _allQuotes = [];
      debugPrint('Error loading local quotes: $e');
    }
  }
  
  // Fetch quotes with optional pagination
  Future<List<QuoteModel>> fetchQuotes({int limit = 10}) async {
    try {
      // Try to fetch from Firestore first
      var query = _firestore
          .collection('custom_quotes')
          .orderBy('createdAt', descending: true)
          .limit(limit);
      
      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }
      
      final snapshot = await query.get();

      debugPrint('Fetched ${snapshot.docs.length} quotes from Firestore');
      
      // Update pagination state
      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        _hasMore = snapshot.docs.length >= limit;
        
        // Convert to QuoteModel objects
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id; // Ensure ID is included
          return QuoteModel.fromJson(data);
        }).toList();
      } else {
        // If no online quotes, return from local cache
        return _getRandomQuotesFromLocal(limit);
      }
    } catch (e) {
      debugPrint('Error fetching quotes: $e');
      // Fallback to local quotes on error
      return _getRandomQuotesFromLocal(limit);
    }
  }
  
  // Get more quotes (used for pagination)
  Future<List<QuoteModel>> fetchMoreQuotes({int limit = 20}) async {
    if (!_hasMore) {
      return [];
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
    final shuffled = List<QuoteModel>.from(_allQuotes)
      ..shuffle(random);
      
    return shuffled.take(min(count, shuffled.length)).toList();
  }
    // Fetch a quote by mood
  Future<List<QuoteModel>> fetchQuoteByMood(String mood, {int? startAfter}) async {
    try {
      // debugPrint('Fetching quote by mood: $mood ${startAfter != null ? ', starting after: $startAfter' : ''}');
      
      // If it's not paginated (no startAfter) or first request, reset pagination
      if (startAfter == null || startAfter == 0) {
        resetPagination();
      }
      
      // Try to fetch from Firestore first
      var query = _firestore
          .collection('custom_quotes')
          .where('mood', isEqualTo: mood)
          .orderBy('createdAt', descending: true)
          .limit(20);
      
      // Add pagination if we're loading more and have a lastDocument
      if (startAfter != null && startAfter > 0 && _lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final snapshot = await query.get();

      // debugPrint('Fetched ${snapshot.docs.length} quotes by mood from Firestore');
      
      if (snapshot.docs.isNotEmpty) {
        // Update pagination state
        _lastDocument = snapshot.docs.last;
        _hasMore = snapshot.docs.length >= 20;
        
        // Convert to QuoteModel objects
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id; // Ensure ID is included
          return QuoteModel.fromJson(data);
        }).toList();
      } else {
        // If no online quotes, return from local cache
        final matchingQuotes = _allQuotes
            .where((quote) => quote.mood.toLowerCase() == mood.toLowerCase())
            .toList();
            
        if (matchingQuotes.isNotEmpty) {
          // If we have a startAfter value, handle pagination for local quotes
          if (startAfter != null && startAfter > 0) {
            final end = min(startAfter + 20, matchingQuotes.length);
            if (startAfter < matchingQuotes.length) {
              return matchingQuotes.sublist(startAfter, end);
            } else {
              return []; // No more quotes
            }
          } else {
            return matchingQuotes.take(min(20, matchingQuotes.length)).toList();
          }
        }
        
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching quote by mood: $e');
      // Fallback to local quotes on error
      final matchingQuotes = _allQuotes
          .where((quote) => quote.mood.toLowerCase() == mood.toLowerCase())
          .toList();
          
      // Handle pagination for local quotes on error too
      if (startAfter != null && startAfter > 0) {
        final end = min(startAfter + 20, matchingQuotes.length);
        if (startAfter < matchingQuotes.length) {
          return matchingQuotes.sublist(startAfter, end);
        } else {
          return []; // No more quotes
        }
      } else {
        return matchingQuotes.take(min(20, matchingQuotes.length)).toList();
      }
    }
  }
  
  // Fetch a quote by ID
  Future<QuoteModel?> fetchQuoteById(String id) async {
    try {
      // Check local cache first for efficiency
      try {
        final localQuote = _allQuotes.firstWhere(
          (quote) => quote.id == id,
        );
        
        return localQuote;
      } catch (e) {
        // If not found in local cache, continue to fetch from Firestore
      }
      
      // Try to fetch from Firestore
      final doc = await _firestore.collection('quotes').doc(id).get();
      
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
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
      // If user is logged in, save to Firestore
      if (_currentUserId != null) {
        await _firestore
            .collection('user_favorites')
            .doc(_currentUserId)
            .collection('quotes')
            .doc(quote.id)
            .set({
              'timestamp': FieldValue.serverTimestamp(),
              ...quote.toJson(),
            });
      }
      
      // Also save to local storage for offline access
      final List<String> favorites = await getFavorites();
      if (!favorites.contains(quote.id)) {
        favorites.add(quote.id);
        await _favoritesBox.put('favorites', favorites);
      }
    } catch (e) {
      debugPrint('Error adding favorite: $e');
      rethrow;
    }
  }
  
  // Remove a quote from favorites
  Future<void> removeFavorite(String id) async {
    try {
      // If user is logged in, remove from Firestore
      if (_currentUserId != null) {
        await _firestore
            .collection('user_favorites')
            .doc(_currentUserId)
            .collection('quotes')
            .doc(id)
            .delete();
      }
      
      // Also remove from local storage
      final List<String> favorites = await getFavorites();
      favorites.remove(id);
      await _favoritesBox.put('favorites', favorites);
    } catch (e) {
      debugPrint('Error removing favorite: $e');
      rethrow;
    }
  }
  
  // Get all favorite quote IDs
  Future<List<String>> getFavorites() async {
    try {
      // Check if box is initialized
      _favoritesBox = await Hive.openBox<List<dynamic>>('favorites');
      if (Hive.isBoxOpen('favorites')) {
        final favorites = _favoritesBox.get('favorites', defaultValue: <dynamic>[])?.cast<String>() ?? [];
        return favorites;
      } else {
        final favorites = _favoritesBox.get('favorites', defaultValue: <dynamic>[])?.cast<String>() ?? [];
        return favorites;
      }
    } catch (e) {
      debugPrint('Error getting favorites: $e');
      return [];
    }
  }
  
  // Check if a quote is in favorites
  Future<bool> isFavorite(String id) async {
    final favorites = await getFavorites();
    return favorites.contains(id);
  }
  
  // Sync favorites between Firestore and local storage
  Future<void> syncFavoritesToLocal(List<String> favoriteIds) async {
    try {
      _favoritesBox = await Hive.openBox<List<dynamic>>('favorites');
      await _favoritesBox.put('favorites', favoriteIds);
    } catch (e) {
      debugPrint('Error syncing favorites: $e');
    }
  }
  
  // LIKE MANAGEMENT
  Future<void> addLike(QuoteModel quote) async {
    try {
      debugPrint('Adding like for quote ID: ${quote.id}');
      if (_currentUserId != null) {
        await _firestore
            .collection('user_likes')
            .doc(_currentUserId)
            .collection('quotes')
            .doc(quote.id)
            .set({
              'timestamp': FieldValue.serverTimestamp(),
              ...quote.toJson(),
            });
        debugPrint('Like added for quote ID: ${quote.id}');
      }
      // Optionally, you can add local storage for likes if needed
    } catch (e) {
      debugPrint('Error adding like: $e');
      rethrow;
    }
  }

  Future<void> removeLike(String id) async {
    try {
      if (_currentUserId != null) {
        await _firestore
            .collection('user_likes')
            .doc(_currentUserId)
            .collection('quotes')
            .doc(id)
            .delete();
      }
      // Optionally, remove from local storage if you implement it
    } catch (e) {
      debugPrint('Error removing like: $e');
      rethrow;
    }
  }

  // Fetch all liked quote IDs for the current user
  Future<List<String>> getLikedQuoteIds() async {
    // debugPrint('Fetching liked quote IDs for user ID: $_currentUserId');
    if (_currentUserId == null) return [];
    try {
      final snapshot = await _firestore
          .collection('user_likes')
          .doc(_currentUserId)
          .collection('quotes')
          .get();
      // debugPrint('Fetched ${snapshot.docs.length} liked quote IDs');
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      debugPrint('Error fetching liked quote IDs: $e');
      return [];
    }
  }

  // Increment view count for a quote
  Future<void> incrementViewCount(String quoteId) async {
    try {
      await _firestore.collection('quotes').doc(quoteId).update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error incrementing view count: $e');
    }
  }

  // Fetch view count for a quote
  Future<int> fetchViewCount(String quoteId) async {
    try {
      final doc = await _firestore.collection('quotes').doc(quoteId).get();
      if (doc.exists && doc.data() != null && doc.data()!.containsKey('viewCount')) {
        return (doc.data()!['viewCount'] as int?) ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Error fetching view count: $e');
      return 0;
    }
  }

  // Track a user's view of a quote and increment global view count only if not already viewed
  Future<void> trackUserView(String quoteId) async {
    if (_currentUserId == null) return;
    final userViewRef = _firestore
        .collection('user_views')
        .doc(_currentUserId)
        .collection('quotes')
        .doc(quoteId);
    final alreadyViewed = (await userViewRef.get()).exists;
    if (!alreadyViewed) {
      // Mark as viewed
      await userViewRef.set({'timestamp': FieldValue.serverTimestamp()});
      // Increment global view count
      await incrementViewCount(quoteId);
    }
  }

  // Fetch all viewed quote IDs for the current user
  Future<List<String>> getViewedQuoteIds() async {
    if (_currentUserId == null) return [];
    try {
      final snapshot = await _firestore
          .collection('user_views')
          .doc(_currentUserId)
          .collection('quotes')
          .get();
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      debugPrint('Error fetching viewed quote IDs: $e');
      return [];
    }
  }

  // Filter unread quotes from a list of quotes
  Future<List<QuoteModel>> filterUnreadQuotes(List<QuoteModel> allQuotes) async {
    final viewedIds = await getViewedQuoteIds();
    return allQuotes.where((q) => !viewedIds.contains(q.id)).toList();
  }
}
