import 'package:equatable/equatable.dart';
import '../../../data/models/quote_model.dart';

abstract class FavoritesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<QuoteModel> favoriteQuotes;
  FavoritesLoaded(this.favoriteQuotes);

  @override
  List<Object?> get props => [favoriteQuotes];
}

class FavoritesError extends FavoritesState {
  final String message;
  FavoritesError(this.message);

  @override
  List<Object?> get props => [message];
}
