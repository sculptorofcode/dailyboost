import 'package:dailyboost/features/quotes/data/repositories/quote_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'quote_event.dart';
import 'quote_state.dart';

class QuoteBloc extends Bloc<QuoteEvent, QuoteState> {
  final QuoteRepository _repository = QuoteRepository();

  QuoteBloc() : super(QuoteInitial()) {on<GetRandomQuoteEvent>((event, emit) async {
      emit(QuoteLoading());
      try {
        // Reset pagination for fresh quotes
        _repository.resetPagination();
        
        // Get first batch with pagination
        final quotes = await _repository.fetchQuotes(limit: 10);
        if (quotes.isNotEmpty) {
          // Take a random quote from the batch
          final randomIndex = DateTime.now().millisecondsSinceEpoch % quotes.length;
          emit(QuoteLoaded(quotes[randomIndex]));
        } else {
          emit(QuoteError('No quotes found.'));
        }
      } catch (e) {
        debugPrint('Error getting random quote: $e');
        emit(QuoteError('Failed to fetch quotes.'));
      }
    });    on<GetQuoteByMoodEvent>((event, emit) async {
      emit(QuoteLoading());
      try {
        // Reset pagination for fresh quotes
        _repository.resetPagination();
        
        // Try to fetch a quote by mood directly from Firestore with pagination
        final quoteByMood = await _repository.fetchQuoteByMood(event.mood);
        if (quoteByMood != null) {
          emit(QuoteLoaded(quoteByMood));
        } else {
          emit(QuoteError('No quotes found for this mood.'));
        }
      } catch (e) {
        debugPrint('Error getting quote by mood: $e');
        emit(QuoteError('Failed to fetch quotes by mood.'));
      }
    });

    on<AddToFavoritesEvent>((event, emit) async {
      try {
        // Save complete quote data to Firebase
        await _repository.addFavorite(event.quote);
        
        // If we're in a state with quote data, update it to reflect favorite status
        if (state is QuoteLoaded) {
          final currentQuote = (state as QuoteLoaded).quote;
          emit(QuoteLoaded(currentQuote));
        }
      } catch (e) {
        debugPrint('Error adding to favorites: $e');
        // Don't change state on error
      }
    });

    on<RemoveFromFavoritesEvent>((event, emit) async {
      try {
        // Remove from Firebase
        await _repository.removeFavorite(event.id); // Use event.id instead of event.quoteId
        
        // If we're in a state with quote data, update it to reflect favorite status
        if (state is QuoteLoaded) {
          final currentQuote = (state as QuoteLoaded).quote;
          emit(QuoteLoaded(currentQuote));
        }
      } catch (e) {
        debugPrint('Error removing from favorites: $e');
        // Don't change state on error
      }
    });
  }
}
