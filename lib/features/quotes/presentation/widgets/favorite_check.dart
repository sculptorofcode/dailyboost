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
  // Use a static repository instance shared across all widgets
  static final QuoteRepository _repository = QuoteRepository();
  bool _isFavorite = false;
  bool _isLoaded = false;
  // Cache the last check time
  DateTime? _lastCheckTime;
  
  // How often to refresh the favorite status
  static const Duration _refreshInterval = Duration(seconds: 30);

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
    // Check if we need to refresh
    final now = DateTime.now();
    if (_lastCheckTime != null && 
        now.difference(_lastCheckTime!) < _refreshInterval &&
        _isLoaded) {
      return; // Skip check if recently checked
    }
    
    try {
      final isFav = await _repository.isFavorite(widget.quote.id);
      if (mounted) {
        setState(() {
          _isFavorite = isFav;
          _isLoaded = true;
          _lastCheckTime = now;
        });
      }
    } catch (e) {
      debugPrint('Error checking favorite status: $e');
      if (mounted) {
        setState(() {
          _isFavorite = false;
          _isLoaded = true;
        });
      }
    }
  }
  void _toggleFavorite() async {
    // First update UI for instant feedback
    setState(() {
      _isFavorite = !_isFavorite;
      _lastCheckTime = DateTime.now(); // Update check time
    });
    
    // Then update backend
    try {
      if (_isFavorite) {
        await _repository.addFavorite(widget.quote);
      } else {
        await _repository.removeFavorite(widget.quote.id);
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      // Revert UI if the operation failed
      if (mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoaded
        ? widget.builder(_isFavorite, _toggleFavorite)
        : widget.builder(false, _toggleFavorite);
  }
}
