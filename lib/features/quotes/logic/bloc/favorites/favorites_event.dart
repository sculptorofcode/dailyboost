import 'package:equatable/equatable.dart';

import '../../../data/models/quote_model.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class LoadFavoritesEvent extends FavoritesEvent {}

class AddToFavoritesEvent extends FavoritesEvent {
  final QuoteModel quote;
  const AddToFavoritesEvent(this.quote);

  @override
  List<Object?> get props => [quote];
}

class RemoveFromFavoritesEvent extends FavoritesEvent {
  final String id;
  const RemoveFromFavoritesEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class LikeQuoteEvent extends FavoritesEvent {
  final QuoteModel quote;
  const LikeQuoteEvent(this.quote);
  
  @override
  List<Object?> get props => [quote];
}

class UnlikeQuoteEvent extends FavoritesEvent {
  final String id;
  const UnlikeQuoteEvent(this.id);
  
  @override
  List<Object?> get props => [id];
}
