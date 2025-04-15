import 'package:equatable/equatable.dart';
import '../../../data/models/quote_model.dart';

abstract class QuoteEvent extends Equatable {
  const QuoteEvent();

  @override
  List<Object?> get props => [];
}

class GetRandomQuoteEvent extends QuoteEvent {
  const GetRandomQuoteEvent();
}

class GetQuoteByMoodEvent extends QuoteEvent {
  final String mood;
  const GetQuoteByMoodEvent(this.mood);
  @override
  List<Object?> get props => [mood];
}

class AddToFavoritesEvent extends QuoteEvent {
  final QuoteModel quote;
  const AddToFavoritesEvent(this.quote);
  @override
  List<Object?> get props => [quote];
}

class RemoveFromFavoritesEvent extends QuoteEvent {
  final String id;
  const RemoveFromFavoritesEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class LoadFavoritesEvent extends QuoteEvent {}
