import 'package:equatable/equatable.dart';
import '../../../data/models/quote_model.dart';

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

  QuoteBatchLoaded(this.quotes, {this.hasReachedMax = false});

  QuoteBatchLoaded copyWith({List<QuoteModel>? quotes, bool? hasReachedMax}) {
    return QuoteBatchLoaded(
      quotes ?? this.quotes,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [quotes, hasReachedMax];
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
  @override
  List<Object?> get props => [message];
}
