import 'package:equatable/equatable.dart';
import '../../../data/models/custom_quote_model.dart';

abstract class CustomQuotesState extends Equatable {
  const CustomQuotesState();

  @override
  List<Object?> get props => [];
}

class CustomQuotesInitial extends CustomQuotesState {}

class CustomQuotesLoading extends CustomQuotesState {}

class CustomQuotesLoaded extends CustomQuotesState {
  final List<CustomQuoteModel> quotes;
  final bool hasReachedEnd;
  final bool isUserQuotes;

  const CustomQuotesLoaded(
    this.quotes, {
    this.hasReachedEnd = false,
    this.isUserQuotes = true,
  });

  @override
  List<Object?> get props => [quotes, hasReachedEnd, isUserQuotes];
}

class CustomQuoteDetailState extends CustomQuotesState {
  final CustomQuoteModel quote;

  const CustomQuoteDetailState(this.quote);

  @override
  List<Object?> get props => [quote];
}

class CustomQuotesError extends CustomQuotesState {
  final String message;

  const CustomQuotesError(this.message);

  @override
  List<Object?> get props => [message];
}

class CustomQuoteCreated extends CustomQuotesState {
  final CustomQuoteModel quote;

  const CustomQuoteCreated(this.quote);

  @override
  List<Object?> get props => [quote];
}

class CustomQuoteUpdated extends CustomQuotesState {
  final CustomQuoteModel quote;

  const CustomQuoteUpdated(this.quote);

  @override
  List<Object?> get props => [quote];
}

class CustomQuoteDeleted extends CustomQuotesState {
  final String quoteId;

  const CustomQuoteDeleted(this.quoteId);

  @override
  List<Object?> get props => [quoteId];
}