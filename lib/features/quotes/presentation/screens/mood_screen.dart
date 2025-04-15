import 'package:dailyboost/core/utils/constants.dart';
import 'package:dailyboost/features/quotes/data/models/mood_model.dart';
import 'package:dailyboost/features/quotes/logic/bloc/home/home_bloc.dart';
import 'package:dailyboost/features/quotes/logic/bloc/home/home_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  // Mood data with colors, icons, and descriptions
  static final List<MoodItem> moods = [
    MoodItem(
      name: 'Happy',
      description: 'Feeling joyful and content',
      color: const Color(0xFFFFC107),
      icon: Icons.sentiment_very_satisfied_rounded,
    ),
    MoodItem(
      name: 'Sad',
      description: 'Feeling down or blue',
      color: const Color(0xFF5C6BC0),
      icon: Icons.sentiment_dissatisfied_rounded,
    ),
    MoodItem(
      name: 'Motivated',
      description: 'Ready to conquer goals',
      color: const Color(0xFF4CAF50),
      icon: Icons.flag_rounded,
    ),
    MoodItem(
      name: 'Calm',
      description: 'Feeling peaceful and centered',
      color: const Color(0xFF26A69A),
      icon: Icons.spa_rounded,
    ),
    MoodItem(
      name: 'Excited',
      description: 'Full of energy and enthusiasm',
      color: const Color(0xFFFF5722),
      icon: Icons.celebration_rounded,
    ),
    MoodItem(
      name: 'Reflective',
      description: 'In a thoughtful state of mind',
      color: const Color(0xFF7986CB),
      icon: Icons.psychology_rounded,
    ),
    MoodItem(
      name: 'Romantic',
      description: 'Feeling love in the air',
      color: const Color(0xFFEC407A),
      icon: Icons.favorite_rounded,
    ),
    MoodItem(
      name: 'Angry',
      description: 'Feeling frustrated or upset',
      color: const Color(0xFFEF5350),
      icon: Icons.upcoming_rounded,
    ),
    MoodItem(
      name: 'Hopeful',
      description: 'Optimistic about the future',
      color: const Color(0xFF42A5F5),
      icon: Icons.lightbulb_rounded,
    ),
    MoodItem(
      name: 'Grateful',
      description: 'Appreciative of life\'s blessings',
      color: const Color(0xFF9575CD),
      icon: Icons.volunteer_activism_rounded,
    ),
    MoodItem(
      name: 'Anxious',
      description: 'Feeling worried or uneasy',
      color: const Color(0xFFFF9800),
      icon: Icons.work_outline_rounded,
    ),
    MoodItem(
      name: 'Inspired',
      description: 'Feeling creative and motivated',
      color: const Color(0xFF66BB6A),
      icon: Icons.auto_awesome_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.standardAnimation,
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectMood(String mood, BuildContext context) {
    // Show feedback that mood was selected
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Finding quotes for when you feel $mood'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.baseRadius),
        ),
      ),
    );

    // Trigger the quote search
    context.read<HomeBloc>().add(GetQuoteByMoodEvent(mood));
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              pinned: true,
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              title: Text(
                'How are you feeling today?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Description Text
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 24.0),
                child: Text(
                  'Select a mood to discover quotes that match how you feel',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color:
                        isDarkMode
                            ? AppConstants.textColorDark.withOpacity(0.7)
                            : AppConstants.textColor.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Grid of mood cards
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isLargeScreen ? 4 : 2,
                  childAspectRatio: isLargeScreen ? 1.2 : 1.0,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final mood = moods[index];

                  // Staggered animation delay based on index
                  final animationDelay = index * 0.05;
                  final itemAnimation = Tween<double>(
                    begin: 0.0,
                    end: 1.0,
                  ).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(
                        animationDelay.clamp(0.0, 0.9),
                        (animationDelay + 0.4).clamp(0.0, 1.0),
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                  );

                  return AnimatedBuilder(
                    animation: itemAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 0.6 + (itemAnimation.value * 0.4),
                        child: Opacity(
                          opacity: itemAnimation.value,
                          child: child,
                        ),
                      );
                    },
                    child: _buildMoodCard(context, mood),
                  );
                }, childCount: moods.length),
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodCard(BuildContext context, MoodItem mood) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectMood(mood.name, context),
        borderRadius: BorderRadius.circular(AppConstants.baseRadius),
        splashColor: mood.color.withOpacity(0.4),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                mood.color.withOpacity(isDarkMode ? 0.2 : 0.7),
                mood.color.withOpacity(isDarkMode ? 0.4 : 1.0),
              ],
            ),
            borderRadius: BorderRadius.circular(AppConstants.baseRadius),
            boxShadow: [
              BoxShadow(
                color: mood.color.withOpacity(isDarkMode ? 0.3 : 0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with background
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(mood.icon, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 12),

              // Mood name
              Text(
                mood.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 4),

              // Mood description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  mood.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
