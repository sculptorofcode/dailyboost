import 'package:flutter/material.dart';
import 'package:dailyboost/features/quotes/data/models/quote_model.dart';
import 'package:dailyboost/features/quotes/presentation/widgets/quote/card_quote.dart';
import 'package:dailyboost/features/quotes/presentation/widgets/quote/classic_quote.dart';
import 'package:dailyboost/features/quotes/presentation/widgets/quote/gradient_quote.dart';
import 'package:dailyboost/features/quotes/presentation/widgets/quote/minimal_quote.dart';

class QuoteView extends StatelessWidget {
  final QuoteModel quote;
  final bool isDarkMode;
  final double fontSize;
  final String quoteStyle;
  final AnimationController animationController;
  final Animation<double> opacityAnimation;
  final Animation<double> scaleAnimation;
  final Animation<double> rotateAnimation;
  final VoidCallback onLike;
  final VoidCallback onSaveToFavorites;
  final VoidCallback onShareQuote;
  final bool isFavorite;
  final bool isLiked;
  final GlobalKey quoteKey;

  const QuoteView({
    required this.quote,
    required this.isDarkMode,
    required this.fontSize,
    required this.quoteStyle,
    required this.animationController,
    required this.opacityAnimation,
    required this.scaleAnimation,
    required this.rotateAnimation,
    required this.onLike,
    required this.onSaveToFavorites,
    required this.onShareQuote,
    this.isFavorite = false,
    this.isLiked = false,
    required this.quoteKey,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    // Choose the right quote style based on settings
    Widget quoteWidget;
    
    switch (quoteStyle) {
      case 'Minimal':
        quoteWidget = MinimalQuote(
          quote: quote,
          isDarkMode: isDarkMode,
          fontSize: fontSize,
          animationController: animationController,
          opacityAnimation: opacityAnimation,
          scaleAnimation: scaleAnimation,
          onLike: onLike,
          onSaveToFavorites: onSaveToFavorites,
          onShareQuote: onShareQuote,
          isFavorite: isFavorite,
          isLiked: isLiked,
          quoteKey: quoteKey,
        );
        break;
      case 'Gradient':
        quoteWidget = GradientQuote(
          quote: quote,
          isDarkMode: isDarkMode,
          fontSize: fontSize,
          animationController: animationController,
          opacityAnimation: opacityAnimation,
          scaleAnimation: scaleAnimation,
          onLike: onLike,
          onSaveToFavorites: onSaveToFavorites,
          onShareQuote: onShareQuote,
          isFavorite: isFavorite,
          isLiked: isLiked,
          quoteKey: quoteKey,
        );
        break;
      case 'Classic':
        quoteWidget = ClassicQuote(
          quote: quote,
          isDarkMode: isDarkMode,
          fontSize: fontSize,
          animationController: animationController,
          opacityAnimation: opacityAnimation,
          scaleAnimation: scaleAnimation,
          rotateAnimation: rotateAnimation,          
          onLike: onLike,
          onSaveToFavorites: onSaveToFavorites,
          onShareQuote: onShareQuote,
          isFavorite: isFavorite,
          quoteKey: quoteKey,
          isLiked: isLiked,
        );
        break;
      case 'Card':
      default:
        quoteWidget = CardQuote(
          quote: quote,
          isDarkMode: isDarkMode,
          fontSize: fontSize,
          animationController: animationController,
          opacityAnimation: opacityAnimation,
          scaleAnimation: scaleAnimation,
          rotateAnimation: rotateAnimation,
          onLike: onLike,
          onSaveToFavorites: onSaveToFavorites,
          onShareQuote: onShareQuote,
          isFavorite: isFavorite,
          quoteKey: quoteKey,
          isLiked: isLiked,
        );
        break;
    }

    // Wrap with gesture detector for double tap to like
    return GestureDetector(
      onDoubleTap: !isLiked ? onLike : null,
      child: quoteWidget,
    );
  }
}
