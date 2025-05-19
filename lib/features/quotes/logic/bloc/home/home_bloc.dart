import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/quote_model.dart';
import '../../../data/repositories/quote_repository.dart';
import '../home/home_event_stream.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final QuoteRepository _repository = QuoteRepository();
  static const int _quoteBatchSize = 20;

  // Subscriptions for event streams
  late final StreamSubscription<QuoteModel> _likeSubscription;
  late final StreamSubscription<String> _unlikeSubscription;

  HomeBloc() : super(HomeInitial()) {
    // Initialize repository when HomeBloc is created
    _initializeRepository();

    // Subscribe to the event streams
    _likeSubscription = HomeEventStreamController().onLikeStream.listen((quote) {
      add(LikeQuoteEvent(quote));
    });

    _unlikeSubscription = HomeEventStreamController().onUnlikeStream.listen((id) {
      add(UnlikeQuoteEvent(id));
    });

    // Clean up subscriptions when bloc is closed
    on<HomeEvent>((event, emit) {
      // This just ensures the event handler is registered
    });

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
          final randomIndex =
              DateTime.now().millisecondsSinceEpoch % quotes.length;
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
        final res = await _repository.fetchQuotes(limit: _quoteBatchSize);
        final quotes = res['quotes'] as List<QuoteModel>;
        final totalCount = res['totalCount'] as int;
        final likedQuoteIds = await _repository.getLikedQuoteIds();
        if (quotes.isNotEmpty) {
          emit(
            QuoteBatchLoaded(
              quotes,
              totalCount,
              hasReachedMax: quotes.length < _quoteBatchSize,
              likedQuoteIds: likedQuoteIds,
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

        final res = await _repository.fetchQuotes(limit: _quoteBatchSize);

        final quotes = res['quotes'] as List<QuoteModel>;
        final totalCount = res['totalCount'] as int;

        if (quotes.isNotEmpty) {
          final likedQuoteIds = await _repository.getLikedQuoteIds();
          emit(
            QuoteBatchLoaded(
              quotes,
              totalCount,
              hasReachedMax: quotes.length < _quoteBatchSize,
              likedQuoteIds: likedQuoteIds,
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
    }); // Load more quotes when the user reaches the end
    on<LoadMoreQuotesEvent>((event, emit) async {
      // First, if we're not in a QuoteBatchLoaded state, we need to handle that
      if (state is! QuoteBatchLoaded) {
        // Try to fetch a batch first
        try {
          debugPrint('Fetching initial batch of quotes');
          final res = await _repository.fetchQuotes(limit: _quoteBatchSize);

          final quotes = res['quotes'] as List<QuoteModel>;
          final totalCount = res['totalCount'] as int;

          if (quotes.isNotEmpty) {
            final likedQuoteIds = await _repository.getLikedQuoteIds();
            emit(
              QuoteBatchLoaded(
                quotes,
                totalCount,
                hasReachedMax: quotes.length < _quoteBatchSize,
                likedQuoteIds: likedQuoteIds,
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

      // Check if we've already reached max quotes
      if (!currentState.hasReachedMax) {
        try {
          List<QuoteModel> moreQuotes = [];
          final mood = event.mood ?? currentState.currentMood;

          // If we have a mood, fetch quotes for that mood
          if (mood != null) {
            debugPrint('Loading more quotes for mood: $mood');
            // For mood-based queries, we'll defer to the repository implementation
            // which should handle pagination for mood-based queries
            final res = await _repository.fetchQuoteByMood(
              mood,
              startAfter: currentState.quotes.length,
            );

            moreQuotes = res['quotes'] as List<QuoteModel>;
          } else {
            // Otherwise fetch general quotes with pagination
            final res = await _repository.fetchMoreQuotes(
              limit: _quoteBatchSize,
            );
            moreQuotes = res['quotes'] as List<QuoteModel>;
          }

          if (moreQuotes.isEmpty) {
            // No more quotes to load, mark as reached max
            debugPrint('No more quotes available, marking as reached max');
            emit(currentState.copyWith(hasReachedMax: true));
          } else {
            // Append new quotes to existing ones
            final updatedQuotes = List<QuoteModel>.from(currentState.quotes)
              ..addAll(moreQuotes);

            // Emit updated state with the combined list
            final likedQuoteIds = await _repository.getLikedQuoteIds();
            emit(
              QuoteBatchLoaded(
                updatedQuotes,
                currentState.totalCount,
                hasReachedMax: moreQuotes.length < _quoteBatchSize,
                currentMood: mood,
                likedQuoteIds: likedQuoteIds,
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

        final res = await _repository.fetchQuoteByMood(event.mood);
        final quotes = res['quotes'] as List<QuoteModel>;
        final totalCount = res['totalCount'] as int;
        if (quotes.isNotEmpty) {
          final likedQuoteIds = await _repository.getLikedQuoteIds();
          emit(
            QuoteBatchLoaded(
              quotes,
              totalCount,
              currentMood: event.mood,
              hasReachedMax: quotes.length < _quoteBatchSize,
              likedQuoteIds: likedQuoteIds,
            ),
          );
        } else {
          emit(HomeError('No quotes found for this mood.'));
        }
      } catch (e) {
        debugPrint('HomeBloc: Error fetching quotes by mood: $e');
        emit(HomeError('Failed to fetch quotes by mood.'));
      }
    });

    on<AddToFavoritesEvent>((event, emit) async {
      try{
        await _repository.addFavorite(event.quote);
      } catch (e) {
        debugPrint('Failed to add to favorites: $e');
      }
      // No need to change state when adding to favorites
    });

    on<RemoveFromFavoritesEvent>((event, emit) async {
      await _repository.removeFavorite(event.id);
      // No need to change state when removing from favorites
    });

    on<LikeQuoteEvent>((event, emit) async {
      // Store like in backend (e.g., Firestore)
      try {
        await _repository.addLike(
          event.quote,
        ); // Implement this in your repository
      } catch (e) {
        debugPrint('Failed to store like: $e');
      }
      if (state is QuoteBatchLoaded) {
        final currentState = state as QuoteBatchLoaded;
        final likedQuoteIds = List<String>.from(currentState.likedQuoteIds);
        if (!likedQuoteIds.contains(event.quote.id)) {
          likedQuoteIds.add(event.quote.id);
          emit(currentState.copyWith(likedQuoteIds: likedQuoteIds));
        }
      }
    });

    on<UnlikeQuoteEvent>((event, emit) async {
      // Remove like from backend (e.g., Firestore)
      try {
        await _repository.removeLike(
          event.id,
        ); // Implement this in your repository
      } catch (e) {
        debugPrint('Failed to remove like: $e');
      }
      if (state is QuoteBatchLoaded) {
        final currentState = state as QuoteBatchLoaded;
        final likedQuoteIds = List<String>.from(currentState.likedQuoteIds);
        if (likedQuoteIds.contains(event.id)) {
          likedQuoteIds.remove(event.id);
          emit(currentState.copyWith(likedQuoteIds: likedQuoteIds));
        }
      }
    });

    // Add a new event for viewing a quote (per-user tracking)
    on<ViewQuoteEvent>((event, emit) async {
      if (event.quoteId.isEmpty) return;
      await _repository.trackUserView(event.quoteId);
      int newCount = await _repository.fetchViewCount(event.quoteId);
      List<String> viewedQuoteIds = await _repository.getViewedQuoteIds();
      if (state is QuoteBatchLoaded) {
        final currentState = state as QuoteBatchLoaded;
        final updatedViewCounts = Map<String, int>.from(
          currentState.viewCounts,
        );
        updatedViewCounts[event.quoteId] = newCount;
        emit(
          currentState.copyWith(
            viewCounts: updatedViewCounts,
            viewedQuoteIds: viewedQuoteIds,
          ),
        );
      }
    });

    // Handle filter selection (all/unread)
    on<SelectQuoteFilterEvent>((event, emit) async {
      if (state is QuoteBatchLoaded) {
        final currentState = state as QuoteBatchLoaded;
        if (event.filter == QuoteFilter.all) {
          emit(currentState.copyWith(filter: QuoteFilter.all));
        } else if (event.filter == QuoteFilter.unread) {
          final unreadQuotes = await _repository.filterUnreadQuotes(
            currentState.quotes,
          );
          emit(
            currentState.copyWith(
              quotes: unreadQuotes,
              filter: QuoteFilter.unread,
            ),
          );
        }
      }
    });

    // Load unread quotes (fetch all, then filter)
    on<LoadUnreadQuotesEvent>((event, emit) async {
      emit(HomeLoading());
      try {
        _repository.resetPagination();
        final res = await _repository.fetchQuotes(limit: _quoteBatchSize);
        final quotes = res['quotes'] as List<QuoteModel>;
        final totalCount = res['totalCount'] as int;
        final likedQuoteIds = await _repository.getLikedQuoteIds();
        final viewedQuoteIds = await _repository.getViewedQuoteIds();
        final unreadQuotes =
            quotes.where((q) => !viewedQuoteIds.contains(q.id)).toList();
        emit(
          QuoteBatchLoaded(
            unreadQuotes,
            totalCount,
            hasReachedMax: unreadQuotes.length < _quoteBatchSize,
            likedQuoteIds: likedQuoteIds,
            viewedQuoteIds: viewedQuoteIds,
            filter: QuoteFilter.unread,
          ),
        );
      } catch (e) {
        emit(HomeError('Failed to load unread quotes.'));
      }
    });
  }

  Future<void> _initializeRepository() async {
    try {
      await _repository.initialize();
    } catch (e) {
      debugPrint('Error initializing quote repository: $e');
    }
  }

  // Close method to clean up resources
  @override
  Future<void> close() {
    _likeSubscription.cancel();
    _unlikeSubscription.cancel();
    return super.close();
  }
}
