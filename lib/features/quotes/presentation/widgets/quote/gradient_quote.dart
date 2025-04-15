import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dailyboost/features/quotes/data/models/quote_model.dart';
import 'package:dailyboost/core/utils/constants.dart';

class GradientQuote extends StatelessWidget {
  final QuoteModel quote;
  final bool isDarkMode;
  final double fontSize;
  final bool isFavorite;
  final AnimationController animationController;
  final Animation<double> opacityAnimation;
  final Animation<double> scaleAnimation;
  final VoidCallback onNewQuote;
  final VoidCallback onSaveToFavorites;
  final VoidCallback onShareQuote;

  const GradientQuote({
    required this.quote,
    required this.isDarkMode,
    required this.fontSize,
    this.isFavorite = false,
    required this.animationController,
    required this.opacityAnimation,
    required this.scaleAnimation,
    required this.onNewQuote,
    required this.onSaveToFavorites,
    required this.onShareQuote,
    super.key,
  });

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.baseRadius),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.2),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define gradients and colors based on mood
    List<Color> gradientColors;

    switch (quote.mood.toLowerCase()) {
      case 'happy':
        gradientColors = [const Color(0xFF42E695), const Color(0xFF3BB2B8)];
        break;
      case 'motivated':
        gradientColors = [const Color(0xFF4E55FD), const Color(0xFF9E20FB)];
        break;
      case 'calm':
        gradientColors = [const Color(0xFF2193b0), const Color(0xFF6dd5ed)];
        break;
      case 'sad':
        gradientColors = [const Color(0xFF606c88), const Color(0xFF3f4c6b)];
        break;
      default:
        gradientColors =
            isDarkMode ? AppConstants.darkGradient : AppConstants.lightGradient;
    }

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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Gradient quote card
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      AppConstants.baseRadius,
                    ),
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors.first.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.format_quote,
                        size: 40,
                        color: Colors.white70,
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
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(
                            AppConstants.baseRadius,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.35,
                              child: Text(
                                quote.author,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: Colors.white54,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              quote.mood,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Glass-morphic action buttons that match the gradient theme
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.baseRadius),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isDarkMode
                                ? Colors.white.withOpacity(0.1)
                                : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(
                          AppConstants.baseRadius,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildGlassButton(
                            icon: Icons.refresh_rounded,
                            onTap: onNewQuote,
                            color: gradientColors.first,
                          ),
                          const SizedBox(width: 24),
                          _buildGlassButton(
                            icon:
                                isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_outlined,
                            onTap: onSaveToFavorites,
                            color: const Color(0xFFFF6B6B),
                          ),
                          const SizedBox(width: 24),
                          _buildGlassButton(
                            icon: Icons.share_rounded,
                            onTap: onShareQuote,
                            color: gradientColors.last,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Swipe hint
                Text(
                  '< Swipe for more quotes >',
                  style: TextStyle(
                    color:
                        isDarkMode
                            ? Colors.white60
                            : AppConstants.textColor.withOpacity(0.6),
                    fontSize: 14,
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
