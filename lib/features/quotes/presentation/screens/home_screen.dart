import 'package:dailyboost/core/utils/constants.dart';
import 'package:dailyboost/features/quotes/logic/bloc/home/home_bloc.dart';
import 'package:dailyboost/features/quotes/logic/bloc/home/home_event.dart';
import 'package:dailyboost/features/quotes/logic/bloc/home/home_state.dart';
import 'package:dailyboost/features/quotes/presentation/widgets/error_view.dart';
import 'package:dailyboost/features/quotes/presentation/widgets/loading.dart';
import 'package:dailyboost/features/quotes/presentation/widgets/quote_batch_view.dart';
import 'package:dailyboost/features/quotes/presentation/widgets/welcome_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dailyboost/features/quotes/data/models/mood_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

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

  void _selectMood(String mood, BuildContext context) {
    Navigator.of(context).pop();
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
    context.read<HomeBloc>().add(GetQuoteByMoodEvent(mood));
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(mood.icon, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 12),
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

  void _showMoodSelector(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isLargeScreen = MediaQuery.of(context).size.width > 600;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: isDarkMode ? AppConstants.cardColorDark : Colors.white,
      isScrollControlled: true,
      builder: (context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final maxHeight = MediaQuery.of(context).size.height * 0.8;
            return ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'How are you feeling today?',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select a mood to discover quotes that match how you feel',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color:
                              isDarkMode
                                  ? AppConstants.textColorDark.withOpacity(0.7)
                                  : AppConstants.textColor.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isLargeScreen ? 4 : 2,
                          childAspectRatio: isLargeScreen ? 1.2 : 1.0,
                          crossAxisSpacing: 12.0,
                          mainAxisSpacing: 12.0,
                        ),
                        itemCount: moods.length,
                        itemBuilder: (context, index) {
                          final mood = moods[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                              _selectMood(mood.name, this.context);
                            },
                            child: _buildMoodCard(context, mood),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();

    // Set up animations
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.standardAnimation,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    // Automatically load quotes batch when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeBloc>().add(const FetchQuoteBatchEvent());
      _animationController.forward();
    });
  }

  void _loadSettings() {
    setState(() {});
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showTip() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          'Tip: Swipe left or right to browse quotes!',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.baseRadius),
        ),
      ),
    );
  }

  void _loadMoreQuotes() {
    context.read<HomeBloc>().add(const LoadMoreQuotesEvent());
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Text(
                'DailyBoost',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : AppConstants.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.emoji_emotions_rounded,
              color: isDarkMode ? Colors.white : AppConstants.primaryColor,
            ),
            tooltip: 'Filter by mood',
            onPressed: () => _showMoodSelector(context),
          ),
          IconButton(
            icon: Icon(
              Icons.lightbulb_outline,
              color: isDarkMode ? Colors.white : AppConstants.primaryColor,
            ),
            onPressed: _showTip,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isDarkMode
                    ? AppConstants.darkGradient
                    : [
                      AppConstants.lightScaffoldBg,
                      Color.alphaBlend(
                        AppConstants.primaryColor.withOpacity(0.05),
                        AppConstants.lightScaffoldBg,
                      ),
                    ],
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return const Center(child: LoadingIndicator());
              } else if (state is QuoteBatchLoaded) {
                return QuoteBatchView(
                  quotes: state.quotes,
                  isDarkMode: isDarkMode,
                  onLoadMore: _loadMoreQuotes,
                );
              } else if (state is HomeError) {
                return ErrorView(
                  message: state.message,
                  onRetry: () {
                    context.read<HomeBloc>().add(const FetchQuoteBatchEvent());
                  },
                );
              } else {
                return WelcomeView(
                  isDarkMode: isDarkMode,
                  animationController: _animationController,
                  scaleAnimation: _scaleAnimation,
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
