// filepath: e:\Projects\Daily Boost\app\lib\features\quotes\logic\bloc\favorites\favorites_bloc.dart
import 'package:dailyboost/features/quotes/data/models/quote_model.dart';
import 'package:dailyboost/features/quotes/data/repositories/quote_repository.dart';
import 'package:dailyboost/features/quotes/logic/bloc/favorites/favorites_event.dart';
import 'package:dailyboost/features/quotes/logic/bloc/favorites/favorites_state.dart';
import 'package:dailyboost/features/quotes/logic/bloc/home/home_event_stream.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final QuoteRepository _quoteRepository = QuoteRepository();

  FavoritesBloc() : super(FavoritesInitial()) {
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<RemoveFromFavoritesEvent>(_onRemoveFromFavorites);
    on<AddToFavoritesEvent>(_onAddToFavorites);
    on<LikeQuoteEvent>(_onLikeQuote);
    on<UnlikeQuoteEvent>(_onUnlikeQuote);
  }
  
  Future<void> _onLoadFavorites(
    LoadFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoritesLoading());
    try {
      // Get favorites from repository (which now returns QuoteModel objects directly)
      List<QuoteModel> quotes = await _quoteRepository.getFavorites();

      emit(FavoritesLoaded(quotes));
    } catch (e) {
      debugPrint('Error loading favorites: $e');
      if (e.toString().contains('must be logged in')) {
        emit(FavoritesAuthError('You must be logged in to view favorites'));
      } else {
        emit(FavoritesError(e.toString()));
      }
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
      if (e.toString().contains('must be logged in')) {
        emit(FavoritesAuthError('You must be logged in to remove favorites'));
      } else {
        emit(FavoritesError(e.toString()));
      }
    }
  }

  Future<void> _onAddToFavorites(
    AddToFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await _quoteRepository.addFavorite(event.quote);

      // If we're already in a loaded state, add to the existing list
      if (state is FavoritesLoaded) {
        final currentState = state as FavoritesLoaded;
        final updatedList = List<QuoteModel>.from(currentState.favoriteQuotes);

        // Only add if not already in list
        if (!updatedList.any((quote) => quote.id == event.quote.id)) {
          updatedList.add(event.quote);
          emit(FavoritesLoaded(updatedList));
        }
      } else {
        // Otherwise load all favorites
        add(LoadFavoritesEvent());
      }
    } catch (e) {
      debugPrint('Error adding to favorites: $e');
      if (e.toString().contains('must be logged in')) {
        emit(FavoritesAuthError('You must be logged in to add favorites'));
      } else {
        emit(FavoritesError(e.toString()));
      }
    }
  }
  
  Future<void> _onLikeQuote(
    LikeQuoteEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      // Store like in backend
      await _quoteRepository.addLike(event.quote);
      
      // Notify HomeBloc through the event stream
      HomeEventStreamController().addLike(event.quote);
      
      // No need to modify state as this operation doesn't affect favorites list
    } catch (e) {
      debugPrint('Error liking quote: $e');
      // Emit an authentication error state that can be handled by the UI
      if (e.toString().contains('must be logged in')) {
        emit(FavoritesAuthError('You must be logged in to like quotes'));
      } else {
        emit(FavoritesError(e.toString()));
      }
    }
  }
  
  Future<void> _onUnlikeQuote(
    UnlikeQuoteEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      // Remove like from backend
      await _quoteRepository.removeLike(event.id);
      
      // Notify HomeBloc through the event stream
      HomeEventStreamController().addUnlike(event.id);
      
      // No need to modify state as this operation doesn't affect favorites list
    } catch (e) {
      debugPrint('Error unliking quote: $e');
      // Emit an authentication error state that can be handled by the UI
      if (e.toString().contains('must be logged in')) {
        emit(FavoritesAuthError('You must be logged in to unlike quotes'));
      } else {
        emit(FavoritesError(e.toString()));
      }
    }
  }
}
