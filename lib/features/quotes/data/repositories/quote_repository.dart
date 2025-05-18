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
  Box<List<dynamic>> _favoritesBox = Hive.box<List<dynamic>>('favorites');
  
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
  Future<QuoteModel?> fetchQuoteByMood(String mood) async {
    try {
      // Try to fetch from Firestore first
      final snapshot = await _firestore
          .collection('quotes')
          .where('mood', isEqualTo: mood)
          .limit(10)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        // Pick a random quote from the results
        final random = Random();
        final randomIndex = random.nextInt(snapshot.docs.length);
        final doc = snapshot.docs[randomIndex];
        
        final data = doc.data();
        data['id'] = doc.id;
        return QuoteModel.fromJson(data);
      } else {
        // Try to find a local quote with matching mood
        final matchingQuotes = _allQuotes
            .where((quote) => quote.mood.toLowerCase() == mood.toLowerCase())
            .toList();
            
        if (matchingQuotes.isNotEmpty) {
          final random = Random();
          return matchingQuotes[random.nextInt(matchingQuotes.length)];
        }
        
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching quote by mood: $e');
      
      // Fallback to local quotes
      final matchingQuotes = _allQuotes
          .where((quote) => quote.mood.toLowerCase() == mood.toLowerCase())
          .toList();
          
      if (matchingQuotes.isNotEmpty) {
        final random = Random();
        return matchingQuotes[random.nextInt(matchingQuotes.length)];
      }
      
      return null;
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
      // Get from Hive box
      final favorites = _favoritesBox.get('favorites', defaultValue: <dynamic>[])?.cast<String>() ?? [];
      return favorites;
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
      await _favoritesBox.put('favorites', favoriteIds);
    } catch (e) {
      debugPrint('Error syncing favorites: $e');
    }
  }
}
