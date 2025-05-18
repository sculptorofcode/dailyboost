import 'package:flutter/material.dart';
import 'package:dailyboost/features/quotes/data/models/quote_model.dart';
import 'package:dailyboost/core/utils/constants.dart';

class ClassicQuote extends StatelessWidget {  final QuoteModel quote;
  final bool isDarkMode;
  final double fontSize;
  final bool isFavorite;
  final bool isLiked;
  final AnimationController animationController;
  final Animation<double> opacityAnimation;
  final Animation<double> scaleAnimation;
  final Animation<double> rotateAnimation;
  final VoidCallback onLike;
  final VoidCallback onSaveToFavorites;
  final VoidCallback onShareQuote;
  final GlobalKey quoteKey;

  const ClassicQuote({
    required this.quote,
    required this.isDarkMode,
    required this.fontSize,
    this.isFavorite = false,
    this.isLiked = false,
    required this.animationController,
    required this.opacityAnimation,
    required this.scaleAnimation,
    required this.rotateAnimation,
    required this.onLike,
    required this.onSaveToFavorites,
    required this.onShareQuote,
    required this.quoteKey,
    super.key,
  });

  Widget _buildClassicButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.baseRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  isDarkMode
                      ? AppConstants.textColorDark.withOpacity(0.3)
                      : AppConstants.textColor.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(AppConstants.baseRadius),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color:
                    isDarkMode
                        ? AppConstants.primaryColorDark
                        : AppConstants.primaryColor,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 12,
                  color:
                      isDarkMode
                          ? AppConstants.textColorDark
                          : AppConstants.textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                // Classic book-like quote styling
                RepaintBoundary(
                  key: quoteKey,
                  child: Container(
                    padding: const EdgeInsets.all(32.0),
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? AppConstants.cardColorDark
                              : Colors.white,
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
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color:
                            isDarkMode
                                ? Colors.grey.shade800
                                : Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Decorative divider
                        Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Theme.of(context).colorScheme.primary,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Main quote text
                        Text(
                          '"${quote.content}"',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: fontSize,
                            height: 1.6,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            color:
                                isDarkMode
                                    ? AppConstants.textColorDark
                                    : AppConstants.textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 30),

                        // Decorative divider
                        Container(
                          height: 1,
                          width: 100,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.5),
                        ),

                        const SizedBox(height: 20),

                        // Author text with classic styling
                        Text(
                          quote.author,
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        // Mood text
                        Text(
                          quote.mood,
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color:
                                isDarkMode
                                    ? AppConstants.textColorDark.withOpacity(
                                      0.7,
                                    )
                                    : AppConstants.textColor.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 20),

                        // Decorative divider
                        Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Theme.of(context).colorScheme.primary,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Classic styled action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [                    _buildClassicButton(
                      label: isLiked ? 'Liked' : 'Like',
                      icon: isLiked 
                          ? Icons.thumb_up 
                          : Icons.thumb_up_alt_outlined,
                      onTap: onLike,
                    ),
                    const SizedBox(width: 20),
                    _buildClassicButton(
                      label: 'Favorite',
                      icon:
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                      onTap: onSaveToFavorites,
                    ),
                    const SizedBox(width: 20),
                    _buildClassicButton(
                      label: 'Share',
                      icon: Icons.share_rounded,
                      onTap: onShareQuote,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Swipe hint
                Text(
                  'Swipe to discover more wisdom',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontStyle: FontStyle.italic,
                    color:
                        isDarkMode
                            ? AppConstants.textColorDark.withOpacity(0.6)
                            : AppConstants.textColor.withOpacity(0.6),
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
