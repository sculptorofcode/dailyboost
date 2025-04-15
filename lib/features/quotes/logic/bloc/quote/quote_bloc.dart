import 'package:dailyboost/features/quotes/data/models/quote_model.dart';
import 'package:dailyboost/features/quotes/data/repositories/quote_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'quote_event.dart';
import 'quote_state.dart';

class QuoteBloc extends Bloc<QuoteEvent, QuoteState> {
  final QuoteRepository _repository = QuoteRepository();
  List<QuoteModel> _allQuotes = [];

  QuoteBloc() : super(QuoteInitial()) {
    on<GetRandomQuoteEvent>((event, emit) async {
      emit(QuoteLoading());
      try {
        _allQuotes = await _repository.fetchQuotes();
        if (_allQuotes.isNotEmpty) {
          _allQuotes.shuffle();
          emit(QuoteLoaded(_allQuotes.first));
        } else {
          emit(QuoteError('No quotes found.'));
        }
      } catch (e) {
        emit(QuoteError('Failed to fetch quotes.'));
      }
    });

    on<GetQuoteByMoodEvent>((event, emit) async {
      emit(QuoteLoading());
      try {
        if (_allQuotes.isEmpty) {
          _allQuotes = await _repository.fetchQuotes();
        }
        final filtered = await _repository.filterByMood(_allQuotes, event.mood);
        if (filtered.isNotEmpty) {
          filtered.shuffle();
          emit(QuoteLoaded(filtered.first));
        } else {
          emit(QuoteError('No quotes found for this mood.'));
        }
      } catch (e) {
        emit(QuoteError('Failed to fetch quotes by mood.'));
      }
    });

    on<AddToFavoritesEvent>((event, emit) async {
      await _repository.addFavorite(event.quote);
      add(LoadFavoritesEvent());
    });

    on<RemoveFromFavoritesEvent>((event, emit) async {
      await _repository.removeFavorite(event.id);
      add(LoadFavoritesEvent());
    });

    on<LoadFavoritesEvent>((event, emit) async {
      final favoriteIds = await _repository.getFavorites();
      // Optionally, you can fetch the full QuoteModel objects for favorites
      final favoriteQuotes =
          _allQuotes.where((q) => favoriteIds.contains(q.id)).toList();
      emit(FavoritesLoaded(favoriteQuotes));
    });
  }
}
