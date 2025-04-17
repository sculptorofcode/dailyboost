import 'package:dailyboost/features/quotes/data/models/quote_model.dart';
import 'package:dailyboost/features/quotes/data/repositories/quote_repository.dart';
import 'package:flutter/material.dart';

/// Widget that checks if a quote is a favorite and displays the appropriate icon
class FavoriteCheck extends StatefulWidget {
  final QuoteModel quote;
  final Widget Function(bool isFavorite, VoidCallback toggleFavorite) builder;

  const FavoriteCheck({required this.quote, required this.builder, super.key});

  @override
  State<FavoriteCheck> createState() => _FavoriteCheckState();
}

class _FavoriteCheckState extends State<FavoriteCheck> {
  final QuoteRepository _repository = QuoteRepository();
  bool _isFavorite = false;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  @override
  void didUpdateWidget(FavoriteCheck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quote.id != widget.quote.id) {
      _checkIfFavorite();
    }
  }

  Future<void> _checkIfFavorite() async {
    final favoriteIds = await _repository.getFavorites();
    if (mounted) {
      setState(() {
        _isFavorite = favoriteIds.contains(widget.quote.id);
        _isLoaded = true;
      });
    }
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoaded
        ? widget.builder(_isFavorite, _toggleFavorite)
        : widget.builder(false, _toggleFavorite);
  }
}
