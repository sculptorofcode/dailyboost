import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dailyboost/features/quotes/data/models/quote_model.dart';
import 'package:dailyboost/features/quotes/data/repositories/quote_repository.dart';
import 'package:dailyboost/features/quotes/logic/bloc/favorites/favorites_event.dart';
import 'package:dailyboost/features/quotes/logic/bloc/favorites/favorites_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final QuoteRepository _quoteRepository = QuoteRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper to get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  FavoritesBloc() : super(FavoritesInitial()) {
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<RemoveFromFavoritesEvent>(_onRemoveFromFavorites);
  }
  Future<void> _onLoadFavorites(
    LoadFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoritesLoading());
    try {
      final List<String> favoriteIds;
      
      if (_currentUserId == null) {
        // If user is not logged in, use local favorites only
        favoriteIds = await _quoteRepository.getFavorites();
      } else {
        // User is logged in, get favorite IDs from Firestore
        final snapshot = await _firestore
            .collection('user_favorites')
            .doc(_currentUserId)
            .collection('quotes')
            .orderBy('timestamp', descending: true)
            .get();
            
        favoriteIds = snapshot.docs.map((doc) => doc.id).toList();
          // If online sync works, also update local cache
        if (favoriteIds.isNotEmpty) {
          await _quoteRepository.syncFavoritesToLocal(favoriteIds);
        }
      }
      
      // Fetch the actual quote data using the IDs
      final quotes = <QuoteModel>[];
      for (final id in favoriteIds) {
        final quote = await _quoteRepository.fetchQuoteById(id);
        if (quote != null) {
          quotes.add(quote);
        }
      }
      
      emit(FavoritesLoaded(quotes));
    } catch (e) {
      debugPrint('Error loading favorites: $e');
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> _onRemoveFromFavorites(
    RemoveFromFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await _quoteRepository.removeFavorite(event.id);
      add(LoadFavoritesEvent()); // Reload favorites after removal
    } catch (e) {
      debugPrint('Error removing favorite: $e');
      emit(FavoritesError(e.toString()));
    }
  }
}
