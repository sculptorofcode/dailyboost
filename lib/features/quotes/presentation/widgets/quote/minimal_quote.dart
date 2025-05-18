import 'package:flutter/material.dart';
import 'package:dailyboost/features/quotes/data/models/quote_model.dart';
import 'package:dailyboost/core/utils/constants.dart';

class MinimalQuote extends StatelessWidget {
  final QuoteModel quote;
  final bool isDarkMode;
  final double fontSize;
  final bool isFavorite;
  final bool isLiked;
  final AnimationController animationController;
  final Animation<double> opacityAnimation;
  final Animation<double> scaleAnimation;
  final VoidCallback onLike;
  final VoidCallback onSaveToFavorites;
  final VoidCallback onShareQuote;
  final GlobalKey quoteKey;

  const MinimalQuote({
    required this.quote,
    required this.isDarkMode,
    required this.fontSize,
    this.isFavorite = false,
    this.isLiked = false,
    required this.animationController,
    required this.opacityAnimation,
    required this.scaleAnimation,
    required this.onLike,
    required this.onSaveToFavorites,
    required this.onShareQuote,
    required this.quoteKey,
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
            child: Transform.scale(scale: scaleAnimation.value, child: child),
          );
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 24.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RepaintBoundary(
                  key: quoteKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 32),

                      // Main quote text with minimal styling
                      Text(
                        '"${quote.content}"',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                          letterSpacing: 0.5,
                          fontSize: fontSize,
                          color:
                              isDarkMode
                                  ? AppConstants.textColorDark
                                  : AppConstants.textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),

                      // Minimal author styling
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40.0),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color:
                                  isDarkMode
                                      ? AppConstants.textColorDark.withOpacity(
                                        0.2,
                                      )
                                      : AppConstants.textColor.withOpacity(0.2),
                              width: 1.0,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              quote.author.toUpperCase(),
                              style: Theme.of(
                                context,
                              ).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              quote.mood,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color:
                                    isDarkMode
                                        ? AppConstants.textColorDark
                                            .withOpacity(0.7)
                                        : AppConstants.textColor.withOpacity(
                                          0.7,
                                        ),
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),
                    ],
                  ),
                ),

                // Minimal action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: onLike,
                      icon: Icon(
                        isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                        size: 28,
                      ),
                      color: isLiked
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      tooltip: isLiked ? 'Unlike' : 'Like',
                    ),
                    const SizedBox(width: 40),
                    IconButton(
                      onPressed: onSaveToFavorites,
                      icon: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_outlined,
                        size: 28,
                      ),
                      color: Theme.of(context).colorScheme.secondary,
                      tooltip: 'Add to Favorites',
                    ),
                    const SizedBox(width: 40),
                    IconButton(
                      onPressed: onShareQuote,
                      icon: const Icon(Icons.share_rounded, size: 28),
                      color: Theme.of(context).colorScheme.tertiary,
                      tooltip: 'Share',
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Swipe hint text
                Text(
                  'Swipe for more quotes',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color:
                        isDarkMode
                            ? AppConstants.textColorDark.withOpacity(0.5)
                            : AppConstants.textColor.withOpacity(0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
