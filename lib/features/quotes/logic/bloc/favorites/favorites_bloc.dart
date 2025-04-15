import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/quote_model.dart';
import '../../../data/repositories/quote_repository.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final QuoteRepository _repository = QuoteRepository();
  List<QuoteModel> _allQuotes = [];

  FavoritesBloc() : super(FavoritesInitial()) {
    on<LoadFavoritesEvent>((event, emit) async {
      emit(FavoritesLoading());
      try {
        // Fetch all quotes if not loaded
        if (_allQuotes.isEmpty) {
          _allQuotes = await _repository.fetchQuotes();
        }

        // Get favorite IDs
        final favoriteIds = await _repository.getFavorites();

        // Get the full QuoteModel objects for favorites
        final favoriteQuotes =
            _allQuotes.where((q) => favoriteIds.contains(q.id)).toList();

        emit(FavoritesLoaded(favoriteQuotes));
      } catch (e) {
        emit(FavoritesError('Failed to load favorites'));
      }
    });

    on<RemoveFromFavoritesEvent>((event, emit) async {
      try {
        await _repository.removeFavorite(event.id);
        add(LoadFavoritesEvent());
      } catch (e) {
        emit(FavoritesError('Failed to remove from favorites'));
      }
    });
  }
}
