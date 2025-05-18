import 'package:equatable/equatable.dart';
import '../../../data/models/custom_quote_model.dart';

abstract class CustomQuotesEvent extends Equatable {
  const CustomQuotesEvent();

  @override
  List<Object?> get props => [];
}

// Load user's custom quotes
class LoadUserCustomQuotesEvent extends CustomQuotesEvent {
  final int limit;
  final CustomQuoteModel? lastQuote;
  final bool refresh;

  const LoadUserCustomQuotesEvent({
    this.limit = 10,
    this.lastQuote,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [limit, lastQuote, refresh];
}

// Load public custom quotes from all users
class LoadPublicCustomQuotesEvent extends CustomQuotesEvent {
  final int limit;
  final CustomQuoteModel? lastQuote;
  final bool refresh;

  const LoadPublicCustomQuotesEvent({
    this.limit = 10,
    this.lastQuote,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [limit, lastQuote, refresh];
}

// Create a new custom quote
class CreateCustomQuoteEvent extends CustomQuotesEvent {
  final String content;
  final String author;
  final String mood;
  final bool isPublic;

  const CreateCustomQuoteEvent({
    required this.content,
    required this.author,
    required this.mood,
    this.isPublic = false,
  });

  @override
  List<Object?> get props => [content, author, mood, isPublic];
}

// Get a specific custom quote by ID
class GetCustomQuoteByIdEvent extends CustomQuotesEvent {
  final String quoteId;

  const GetCustomQuoteByIdEvent(this.quoteId);

  @override
  List<Object?> get props => [quoteId];
}

// Update an existing custom quote
class UpdateCustomQuoteEvent extends CustomQuotesEvent {
  final CustomQuoteModel quote;

  const UpdateCustomQuoteEvent(this.quote);

  @override
  List<Object?> get props => [quote];
}

// Delete a custom quote
class DeleteCustomQuoteEvent extends CustomQuotesEvent {
  final String quoteId;

  const DeleteCustomQuoteEvent(this.quoteId);

  @override
  List<Object?> get props => [quoteId];
}

// Toggle public/private status of a quote
class ToggleQuotePublicStatusEvent extends CustomQuotesEvent {
  final String quoteId;

  const ToggleQuotePublicStatusEvent(this.quoteId);

  @override
  List<Object?> get props => [quoteId];
}

// Reset the state (e.g., after creating or updating)
class ResetCustomQuotesStateEvent extends CustomQuotesEvent {}