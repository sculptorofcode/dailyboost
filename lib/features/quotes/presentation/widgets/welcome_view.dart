import 'package:dailyboost/core/utils/constants.dart';
import 'package:dailyboost/features/quotes/logic/bloc/home/home_bloc.dart';
import 'package:dailyboost/features/quotes/logic/bloc/home/home_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WelcomeView extends StatelessWidget {
  final bool isDarkMode;
  final AnimationController animationController;
  final Animation<double> scaleAnimation;
  const WelcomeView({
    super.key,
    required this.isDarkMode,
    required this.animationController,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Decorative background shape
            Opacity(
              opacity: 0.1,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors:
                        isDarkMode
                            ? AppConstants.darkAccentGradient
                            : AppConstants.accentGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),

            // Main icon with pulse animation
            AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: scaleAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color:
                              isDarkMode
                                  ? AppConstants.shadowColorDark
                                  : AppConstants.shadowColor,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.format_quote_rounded,
                      size: 60,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Welcome text
            Text(
              'Welcome to DailyBoost',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Your daily dose of inspiration and motivation',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color:
                      isDarkMode
                          ? AppConstants.textColorDark.withOpacity(0.8)
                          : AppConstants.textColor.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 48),

            // Action button with animation
            AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: scaleAnimation.value,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<HomeBloc>().add(
                        const FetchQuoteBatchEvent(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      'Inspire Me',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
