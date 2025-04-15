import 'package:dailyboost/features/quotes/logic/bloc/home/home_bloc.dart';
import 'package:dailyboost/features/quotes/logic/bloc/home/home_event.dart';
import 'package:dailyboost/features/quotes/logic/bloc/home/home_state.dart';
import 'package:dailyboost/features/quotes/presentation/widgets/error_view.dart';
import 'package:dailyboost/features/quotes/presentation/widgets/loading.dart';
import 'package:dailyboost/features/quotes/presentation/widgets/quote_batch_view.dart';
import 'package:dailyboost/features/quotes/presentation/widgets/welcome_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/constants.dart';

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
                // Use the new batch quote view with PageView
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
                // Default state - welcome screen
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
