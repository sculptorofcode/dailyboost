import 'package:equatable/equatable.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class LoadFavoritesEvent extends FavoritesEvent {}

class RemoveFromFavoritesEvent extends FavoritesEvent {
  final String id;
  const RemoveFromFavoritesEvent(this.id);

  @override
  List<Object?> get props => [id];
}
