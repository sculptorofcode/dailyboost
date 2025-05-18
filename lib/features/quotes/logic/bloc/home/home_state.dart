import 'package:equatable/equatable.dart';
import '../../../data/models/quote_model.dart';
import 'home_event.dart';

abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final QuoteModel quote;
  HomeLoaded(this.quote);
  @override
  List<Object?> get props => [quote];
}

class QuoteBatchLoaded extends HomeState {
  final List<QuoteModel> quotes;
  final bool hasReachedMax;
  final String? currentMood;
  final List<String> likedQuoteIds;
  final Map<String, int> viewCounts;
  final List<String> viewedQuoteIds;
  final QuoteFilter filter;

  QuoteBatchLoaded(
    this.quotes, {
    this.hasReachedMax = false,
    this.currentMood,
    this.likedQuoteIds = const [],
    this.viewCounts = const {},
    this.viewedQuoteIds = const [],
    this.filter = QuoteFilter.all,
  });

  QuoteBatchLoaded copyWith({
    List<QuoteModel>? quotes,
    bool? hasReachedMax,
    String? currentMood,
    List<String>? likedQuoteIds,
    Map<String, int>? viewCounts,
    List<String>? viewedQuoteIds,
    QuoteFilter? filter,
  }) {
    return QuoteBatchLoaded(
      quotes ?? this.quotes,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentMood: currentMood ?? this.currentMood,
      likedQuoteIds: likedQuoteIds ?? this.likedQuoteIds,
      viewCounts: viewCounts ?? this.viewCounts,
      viewedQuoteIds: viewedQuoteIds ?? this.viewedQuoteIds,
      filter: filter ?? this.filter,
    );
  }

  bool isQuoteLiked(String quoteId) {
    return likedQuoteIds.contains(quoteId);
  }

  int getViewCount(String quoteId) {
    return viewCounts[quoteId] ?? 0;
  }

  bool isQuoteViewed(String quoteId) {
    return viewedQuoteIds.contains(quoteId);
  }

  @override
  List<Object?> get props => [quotes, hasReachedMax, currentMood, likedQuoteIds, viewCounts, viewedQuoteIds, filter];
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
  @override
  List<Object?> get props => [message];
}
