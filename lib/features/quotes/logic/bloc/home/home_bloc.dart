import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/quote_model.dart';
import '../../../data/repositories/quote_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final QuoteRepository _repository = QuoteRepository();
  List<QuoteModel> _allQuotes = [];
  static const int _quoteBatchSize = 20;

  HomeBloc() : super(HomeInitial()) {
    // Single quote fetch for backward compatibility
    on<GetRandomQuoteEvent>((event, emit) async {
      emit(HomeLoading());
      try {
        _allQuotes = await _repository.fetchQuotes();
        if (_allQuotes.isNotEmpty) {
          _allQuotes.shuffle();
          emit(HomeLoaded(_allQuotes.first));
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
        final quotes = await _repository.fetchQuoteBatch(
          batchSize: _quoteBatchSize,
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

    // Load more quotes when the user reaches the end
    on<LoadMoreQuotesEvent>((event, emit) async {
      final currentState = state;
      if (currentState is QuoteBatchLoaded && !currentState.hasReachedMax) {
        try {
          final moreQuotes = await _repository.loadMoreQuotes(
            batchSize: _quoteBatchSize,
          );
          if (moreQuotes.isEmpty) {
            emit(currentState.copyWith(hasReachedMax: true));
          } else {
            emit(
              QuoteBatchLoaded(
                List.of(currentState.quotes)..addAll(moreQuotes),
                hasReachedMax: moreQuotes.length < _quoteBatchSize,
              ),
            );
          }
        } catch (e) {
          emit(HomeError('Failed to load more quotes.'));
        }
      }
    });

    on<GetQuoteByMoodEvent>((event, emit) async {
      emit(HomeLoading());
      try {
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
}
