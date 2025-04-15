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
  final VoidCallback onNewQuote;
  final VoidCallback onSaveToFavorites;
  final VoidCallback onShareQuote;
  final bool isFavorite;
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
    required this.onNewQuote,
    required this.onSaveToFavorites,
    required this.onShareQuote,
    this.isFavorite = false,
    required this.quoteKey,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Choose the right quote style based on settings
    switch (quoteStyle) {
      case 'Minimal':
        return MinimalQuote(
          quote: quote,
          isDarkMode: isDarkMode,
          fontSize: fontSize,
          animationController: animationController,
          opacityAnimation: opacityAnimation,
          scaleAnimation: scaleAnimation,
          onNewQuote: onNewQuote,
          onSaveToFavorites: onSaveToFavorites,
          onShareQuote: onShareQuote,
          isFavorite: isFavorite,
          quoteKey: quoteKey,
        );
      case 'Gradient':
        return GradientQuote(
          quote: quote,
          isDarkMode: isDarkMode,
          fontSize: fontSize,
          animationController: animationController,
          opacityAnimation: opacityAnimation,
          scaleAnimation: scaleAnimation,
          onNewQuote: onNewQuote,
          onSaveToFavorites: onSaveToFavorites,
          onShareQuote: onShareQuote,
          isFavorite: isFavorite,
          quoteKey: quoteKey,
        );
      case 'Classic':
        return ClassicQuote(
          quote: quote,
          isDarkMode: isDarkMode,
          fontSize: fontSize,
          animationController: animationController,
          opacityAnimation: opacityAnimation,
          scaleAnimation: scaleAnimation,
          rotateAnimation: rotateAnimation,
          onNewQuote: onNewQuote,
          onSaveToFavorites: onSaveToFavorites,
          onShareQuote: onShareQuote,
          isFavorite: isFavorite,
          quoteKey: quoteKey,
        );
      case 'Card':
      default:
        return CardQuote(
          quote: quote,
          isDarkMode: isDarkMode,
          fontSize: fontSize,
          animationController: animationController,
          opacityAnimation: opacityAnimation,
          scaleAnimation: scaleAnimation,
          rotateAnimation: rotateAnimation,
          onNewQuote: onNewQuote,
          onSaveToFavorites: onSaveToFavorites,
          onShareQuote: onShareQuote,
          isFavorite: isFavorite,
          quoteKey: quoteKey,
        );
    }
  }
}
