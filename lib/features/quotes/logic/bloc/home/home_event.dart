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
  final String? mood;
  const LoadMoreQuotesEvent({this.mood});
  
  @override
  List<Object?> get props => [mood];
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

class LikeQuoteEvent extends HomeEvent {
  final QuoteModel quote;
  const LikeQuoteEvent(this.quote);
  @override
  List<Object?> get props => [quote];
}

class UnlikeQuoteEvent extends HomeEvent {
  final String id;
  const UnlikeQuoteEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class ViewQuoteEvent extends HomeEvent {
  final String quoteId;
  const ViewQuoteEvent(this.quoteId);
  @override
  List<Object?> get props => [quoteId];
}

class SelectQuoteFilterEvent extends HomeEvent {
  final QuoteFilter filter;
  const SelectQuoteFilterEvent(this.filter);
  @override
  List<Object?> get props => [filter];
}

class LoadUnreadQuotesEvent extends HomeEvent {
  const LoadUnreadQuotesEvent();
}

// Enum for quote filter
enum QuoteFilter { all, unread }
