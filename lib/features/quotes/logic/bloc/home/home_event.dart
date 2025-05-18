import 'package:equatable/equatable.dart';
import '../../../data/models/quote_model.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class GetRandomQuoteEvent extends HomeEvent {
  const GetRandomQuoteEvent();
}

class GetQuoteByMoodEvent extends HomeEvent {
  final String mood;
  const GetQuoteByMoodEvent(this.mood);
  @override
  List<Object?> get props => [mood];
}

class FetchQuoteBatchEvent extends HomeEvent {
  const FetchQuoteBatchEvent();
}

class RefreshQuotesEvent extends HomeEvent {
  const RefreshQuotesEvent();
}

class LoadMoreQuotesEvent extends HomeEvent {
  const LoadMoreQuotesEvent();
}

class AddToFavoritesEvent extends HomeEvent {
  final QuoteModel quote;
  const AddToFavoritesEvent(this.quote);
  @override
  List<Object?> get props => [quote];
}

class RemoveFromFavoritesEvent extends HomeEvent {
  final String id;
  const RemoveFromFavoritesEvent(this.id);
  @override
  List<Object?> get props => [id];
}
