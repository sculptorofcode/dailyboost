import 'package:dailyboost/features/quotes/data/models/custom_quote_model.dart';
import 'package:dailyboost/features/quotes/data/repositories/custom_quote_repository.dart';
import 'package:dailyboost/features/quotes/logic/bloc/custom_quotes/custom_quotes_event.dart';
import 'package:dailyboost/features/quotes/logic/bloc/custom_quotes/custom_quotes_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

class CustomQuotesBloc extends Bloc<CustomQuotesEvent, CustomQuotesState> {
  final CustomQuoteRepository _repository = CustomQuoteRepository();

  CustomQuotesBloc() : super(CustomQuotesInitial()) {
    on<LoadUserCustomQuotesEvent>(_onLoadUserQuotes);
    on<LoadPublicCustomQuotesEvent>(_onLoadPublicQuotes);
    on<CreateCustomQuoteEvent>(_onCreateQuote);
    on<GetCustomQuoteByIdEvent>(_onGetQuoteById);
    on<UpdateCustomQuoteEvent>(_onUpdateQuote);
    on<DeleteCustomQuoteEvent>(_onDeleteQuote);
    on<ToggleQuotePublicStatusEvent>(_onTogglePublicStatus);
    on<ResetCustomQuotesStateEvent>(_onResetState);
  }

  Future<void> _onLoadUserQuotes(
    LoadUserCustomQuotesEvent event,
    Emitter<CustomQuotesState> emit,
  ) async {
    // Don't show loading indicator if it's pagination or refresh
    if (!event.refresh && event.lastQuote == null) {
      emit(CustomQuotesLoading());
    }

    try {
      final quotes = await _repository.getUserCustomQuotes(
        limit: event.limit,
        lastDoc: event.lastQuote,
      );

      // Determine if we've reached the end (less quotes than requested)
      final hasReachedEnd = quotes.length < event.limit;

      // Get current quotes if we're paginating
      List<CustomQuoteModel> currentQuotes = [];

      if (state is CustomQuotesLoaded && !event.refresh && event.lastQuote != null) {
        currentQuotes = [...(state as CustomQuotesLoaded).quotes];
        // Add new quotes to the existing list
        currentQuotes.addAll(quotes);
      } else {
        // If it's a fresh load or refresh, just use the new quotes
        currentQuotes = quotes;
      }

      emit(CustomQuotesLoaded(
        currentQuotes,
        hasReachedEnd: hasReachedEnd,
        isUserQuotes: true,
      ));
    } catch (e) {
      debugPrint('Error loading user quotes: $e');
      emit(CustomQuotesError(e.toString()));
    }
  }

  Future<void> _onLoadPublicQuotes(
    LoadPublicCustomQuotesEvent event,
    Emitter<CustomQuotesState> emit,
  ) async {
    // Don't show loading indicator if it's pagination or refresh
    if (!event.refresh && event.lastQuote == null) {
      emit(CustomQuotesLoading());
    }

    try {
      final quotes = await _repository.getPublicCustomQuotes(
        limit: event.limit,
        lastDoc: event.lastQuote,
      );

      // Determine if we've reached the end (less quotes than requested)
      final hasReachedEnd = quotes.length < event.limit;

      // Get current quotes if we're paginating
      List<CustomQuoteModel> currentQuotes = [];

      if (state is CustomQuotesLoaded && !event.refresh && event.lastQuote != null) {
        currentQuotes = [...(state as CustomQuotesLoaded).quotes];
        // Add new quotes to the existing list
        currentQuotes.addAll(quotes);
      } else {
        // If it's a fresh load or refresh, just use the new quotes
        currentQuotes = quotes;
      }

      emit(CustomQuotesLoaded(
        currentQuotes,
        hasReachedEnd: hasReachedEnd,
        isUserQuotes: false,
      ));
    } catch (e) {
      debugPrint('Error loading public quotes: $e');
      emit(CustomQuotesError(e.toString()));
    }
  }

  Future<void> _onCreateQuote(
    CreateCustomQuoteEvent event,
    Emitter<CustomQuotesState> emit,
  ) async {
    emit(CustomQuotesLoading());
    try {
      final quote = await _repository.createCustomQuote(
        content: event.content,
        author: event.author,
        mood: event.mood,
        isPublic: event.isPublic,
      );

      emit(CustomQuoteCreated(quote));
    } catch (e) {
      debugPrint('Error creating quote: $e');
      emit(CustomQuotesError(e.toString()));
    }
  }

  Future<void> _onGetQuoteById(
    GetCustomQuoteByIdEvent event,
    Emitter<CustomQuotesState> emit,
  ) async {
    emit(CustomQuotesLoading());
    try {
      final quote = await _repository.getCustomQuoteById(event.quoteId);
      if (quote != null) {
        emit(CustomQuoteDetailState(quote));
      } else {
        emit(const CustomQuotesError('Quote not found'));
      }
    } catch (e) {
      debugPrint('Error getting quote by ID: $e');
      emit(CustomQuotesError(e.toString()));
    }
  }

  Future<void> _onUpdateQuote(
    UpdateCustomQuoteEvent event,
    Emitter<CustomQuotesState> emit,
  ) async {
    emit(CustomQuotesLoading());
    try {
      await _repository.updateCustomQuote(event.quote);
      emit(CustomQuoteUpdated(event.quote));
    } catch (e) {
      debugPrint('Error updating quote: $e');
      emit(CustomQuotesError(e.toString()));
    }
  }

  Future<void> _onDeleteQuote(
    DeleteCustomQuoteEvent event,
    Emitter<CustomQuotesState> emit,
  ) async {
    try {
      await _repository.deleteCustomQuote(event.quoteId);
      emit(CustomQuoteDeleted(event.quoteId));
    } catch (e) {
      debugPrint('Error deleting quote: $e');
      emit(CustomQuotesError(e.toString()));
    }
  }

  Future<void> _onTogglePublicStatus(
    ToggleQuotePublicStatusEvent event,
    Emitter<CustomQuotesState> emit,
  ) async {
    try {
      final updatedQuote = await _repository.toggleQuotePublicStatus(event.quoteId);
      emit(CustomQuoteUpdated(updatedQuote));
    } catch (e) {
      debugPrint('Error toggling quote public status: $e');
      emit(CustomQuotesError(e.toString()));
    }
  }

  void _onResetState(
    ResetCustomQuotesStateEvent event,
    Emitter<CustomQuotesState> emit,
  ) {
    emit(CustomQuotesInitial());
  }
}