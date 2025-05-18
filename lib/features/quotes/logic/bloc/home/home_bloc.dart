import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart'; // Add this import for debugPrint
import '../../../data/models/quote_model.dart';
import '../../../data/repositories/quote_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final QuoteRepository _repository = QuoteRepository();
  static const int _quoteBatchSize = 20;  
  HomeBloc() : super(HomeInitial()) {
    // Initialize repository when HomeBloc is created
    _initializeRepository();
    
    // Single quote fetch for backward compatibility
    on<GetRandomQuoteEvent>((event, emit) async {
      emit(HomeLoading());
      try {
        // Reset pagination state to ensure fresh quotes
        _repository.resetPagination();
        
        // Fetch a small batch of quotes to choose from
        final quotes = await _repository.fetchQuotes(limit: 10);
        if (quotes.isNotEmpty) {
          // Pick a random quote from the batch
          final randomIndex = DateTime.now().millisecondsSinceEpoch % quotes.length;
          emit(HomeLoaded(quotes[randomIndex]));
        } else {
          emit(HomeError('No quotes found.'));
        }
      } catch (e) {
        emit(HomeError('Failed to fetch quotes.'));
      }
    });

    // Fetch a batch of quotes
    on<FetchQuoteBatchEvent>((event, emit) async {
      emit(HomeLoading());
      try {
        // Reset pagination state before fetching new batch
        _repository.resetPagination();

        debugPrint('Fetching new batch of quotes');
        
        final quotes = await _repository.fetchQuotes(
          limit: _quoteBatchSize,
        );
        if (quotes.isNotEmpty) {
          emit(
            QuoteBatchLoaded(
              quotes,
              hasReachedMax: quotes.length < _quoteBatchSize,
            ),
          );
        } else {
          emit(HomeError('No quotes found.'));
        }
      } catch (e) {
        emit(HomeError('Failed to fetch quotes.'));
      }
    });
    
    // Handle refresh requests
    on<RefreshQuotesEvent>((event, emit) async {
      // Save current state to return to if refresh fails
      final currentState = state;
      
      try {
        // Reset pagination to fetch fresh quotes
        _repository.resetPagination();
        
        final quotes = await _repository.fetchQuotes(
          limit: _quoteBatchSize,
        );
        
        if (quotes.isNotEmpty) {
          emit(
            QuoteBatchLoaded(
              quotes,
              hasReachedMax: quotes.length < _quoteBatchSize,
            ),
          );
        } else if (currentState is QuoteBatchLoaded) {
          // If no new quotes but we had quotes before, keep old state
          emit(currentState);
        } else {
          emit(HomeError('No quotes found during refresh.'));
        }
      } catch (e) {
        // If refresh fails, restore previous state if it was valid
        if (currentState is QuoteBatchLoaded) {
          emit(currentState);
        } else {
          emit(HomeError('Failed to refresh quotes.'));
        }
      }
    });

    // Load more quotes when the user reaches the end
    on<LoadMoreQuotesEvent>((event, emit) async {
      // First, if we're not in a QuoteBatchLoaded state, we need to handle that
      if (state is! QuoteBatchLoaded) {
        // Try to fetch a batch first
        try {
          debugPrint('Fetching initial batch of quotes');
          final quotes = await _repository.fetchQuotes(
            limit: _quoteBatchSize,
          );
          if (quotes.isNotEmpty) {
            emit(
              QuoteBatchLoaded(
                quotes,
                hasReachedMax: quotes.length < _quoteBatchSize,
              ),
            );
          } else {
            emit(HomeError('No quotes found.'));
          }
          return; // Exit after handling this case
        } catch (e) {
          emit(HomeError('Failed to fetch quotes.'));
          return; // Exit after handling error
        }
      }
        // Now handle the normal case where we're in a QuoteBatchLoaded state
      final currentState = state as QuoteBatchLoaded;
      if (!currentState.hasReachedMax) {
        try {
          final moreQuotes = await _repository.fetchMoreQuotes(
            limit: _quoteBatchSize,
          );
          
          if (moreQuotes.isEmpty) {
            // No more quotes to load, mark as reached max
            debugPrint('No more quotes available, marking as reached max');
            emit(currentState.copyWith(hasReachedMax: true));
          } else {
            // Append new quotes to existing ones
            final updatedQuotes = List<QuoteModel>.from(currentState.quotes)..addAll(moreQuotes);
            
            // Emit updated state with the combined list
            debugPrint('Loaded ${moreQuotes.length} more quotes, now have ${updatedQuotes.length} total');
            emit(
              QuoteBatchLoaded(
                updatedQuotes,
                hasReachedMax: moreQuotes.length < _quoteBatchSize,
              ),
            );
          }
        } catch (e) {
          debugPrint('Error when loading more quotes: $e');
          // Only emit error if no quotes were previously loaded
          if (currentState.quotes.isEmpty) {
            emit(HomeError('Failed to load more quotes. Please try again.'));
          } else {
            // If we already have quotes, just mark as reached max to avoid loading more
            emit(currentState.copyWith(hasReachedMax: true));
          }
        }
      } else {
        // Already reached max, just keep current state
        emit(currentState);
      }
    });

    on<GetQuoteByMoodEvent>((event, emit) async {
      emit(HomeLoading());
      try {
        // Reset pagination state to ensure fresh quotes on mood change
        _repository.resetPagination();
        
        final quote = await _repository.fetchQuoteByMood(event.mood);
        if (quote != null) {
          emit(HomeLoaded(quote));
        } else {
          emit(HomeError('No quotes found for this mood.'));
        }
      } catch (e) {
        emit(HomeError('Failed to fetch quotes by mood.'));
      }
    });

    on<AddToFavoritesEvent>((event, emit) async {
      await _repository.addFavorite(event.quote);
      // No need to change state when adding to favorites
    });

    on<RemoveFromFavoritesEvent>((event, emit) async {
      await _repository.removeFavorite(event.id);
      // No need to change state when removing from favorites
    });
  }
  
  Future<void> _initializeRepository() async {
    try {
      await _repository.initialize();
    } catch (e) {
      debugPrint('Error initializing quote repository: $e');
    }
  }
}
