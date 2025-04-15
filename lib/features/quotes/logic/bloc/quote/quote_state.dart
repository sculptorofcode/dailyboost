import 'package:equatable/equatable.dart';
import '../../../data/models/quote_model.dart';

abstract class QuoteState extends Equatable {
  @override
  List<Object?> get props => [];
}

class QuoteInitial extends QuoteState {}

class QuoteLoading extends QuoteState {}

class QuoteLoaded extends QuoteState {
  final QuoteModel quote;
  QuoteLoaded(this.quote);
  @override
  List<Object?> get props => [quote];
}

class FavoritesLoaded extends QuoteState {
  final List<QuoteModel> favoriteQuotes;
  FavoritesLoaded(this.favoriteQuotes);
  @override
  List<Object?> get props => [favoriteQuotes];
}

class QuoteError extends QuoteState {
  final String message;
  QuoteError(this.message);
  @override
  List<Object?> get props => [message];
}
