import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/quote_model.dart';
import '../../../data/repositories/quote_repository.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final QuoteRepository _repository = QuoteRepository();

  FavoritesBloc() : super(FavoritesInitial()) {
    on<LoadFavoritesEvent>((event, emit) async {
      emit(FavoritesLoading());
      try {
        // Get favorite IDs
        final favoriteIds = await _repository.getFavorites();

        // Fetch each favorite quote by ID using the API
        final favoriteQuotes = <QuoteModel>[];
        // print('Favorite IDs: $favoriteIds');
        for (final id in favoriteIds) {
          // debugPrint('Fetching quote with ID: $id');
          final quote = await _repository.fetchQuoteById(id);
          // debugPrint('Fetched quote: $quote');
          if (quote != null) {
            favoriteQuotes.add(quote);
          }
        }

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
