import 'package:flutter/material.dart';
import 'package:dailyboost/features/quotes/data/models/quote_model.dart';
import 'package:dailyboost/core/utils/constants.dart';

class CardQuote extends StatelessWidget {
  final QuoteModel quote;
  final bool isDarkMode;
  final double fontSize;
  final AnimationController animationController;
  final Animation<double> opacityAnimation;
  final Animation<double> scaleAnimation;
  final Animation<double> rotateAnimation;
  final VoidCallback onNewQuote;
  final VoidCallback onSaveToFavorites;
  final VoidCallback onShareQuote;
  final bool isFavorite;

  const CardQuote({
    required this.quote,
    required this.isDarkMode,
    required this.fontSize,
    required this.animationController,
    required this.opacityAnimation,
    required this.scaleAnimation,
    required this.rotateAnimation,
    required this.onNewQuote,
    required this.onSaveToFavorites,
    required this.onShareQuote,
    this.isFavorite = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          return Opacity(
            opacity: opacityAnimation.value,
            child: Transform.scale(
              scale: scaleAnimation.value,
              child: Transform.rotate(
                angle: rotateAnimation.value,
                child: child,
              ),
            ),
          );
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.baseRadius,
                    ),
                  ),
                  elevation: 8,
                  child: Container(
                    padding: const EdgeInsets.all(32.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        AppConstants.baseRadius,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              isDarkMode
                                  ? AppConstants.shadowColorDark
                                  : AppConstants.shadowColor,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.format_quote,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          quote.content,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                            letterSpacing: 0.4,
                            fontSize: fontSize,
                            color:
                                isDarkMode
                                    ? AppConstants.textColorDark
                                    : AppConstants.textColor,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    quote.author,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Mood: ${quote.mood}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.copyWith(
                                      color:
                                          isDarkMode
                                              ? AppConstants.textColorDark
                                                  .withOpacity(0.7)
                                              : AppConstants.textColor
                                                  .withOpacity(0.7),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: onNewQuote,
                      icon: Icon(Icons.refresh_rounded),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    IconButton(
                      onPressed: onSaveToFavorites,
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border_rounded,
                      ),
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    IconButton(
                      onPressed: onShareQuote,
                      icon: Icon(Icons.share_rounded),
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
