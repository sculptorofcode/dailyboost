import 'package:dailyboost/features/quotes/logic/bloc/favorites/favorites_bloc.dart';
import 'package:dailyboost/features/quotes/logic/bloc/favorites/favorites_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'features/quotes/logic/bloc/quote/quote_bloc.dart';
import 'features/quotes/logic/bloc/home/home_bloc.dart';
import 'features/quotes/presentation/screens/home_screen.dart';
import 'features/quotes/presentation/screens/mood_screen.dart';
import 'features/quotes/presentation/screens/favorites_screen.dart';
import 'features/quotes/presentation/screens/settings_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/utils/constants.dart';
import 'core/utils/notification_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  await Hive.initFlutter();
  await Hive.openBox<String>('favorite_quotes');
  await Hive.openBox<String>('app_settings');

  // Initialize notifications only for mobile platforms
  if (!kIsWeb) {
    final notificationService = NotificationService();
    await notificationService.init();
    await notificationService.requestNotificationPermission();

    // Schedule daily notifications at multiple times
    await notificationService.scheduleDailyQuoteNotification(
      hour: 9,
      minute: 0,
      quote: 'Start your day with inspiration!',
    );

    await notificationService.scheduleDailyQuoteNotification(
      hour: 14,
      minute: 30,
      quote: 'Midday motivation boost!',
    );

    await notificationService.scheduleDailyQuoteNotification(
      hour: 16,
      minute: 25,
      quote: 'Evening inspiration to end your day well!',
    );

    await notificationService.scheduleDailyQuoteNotification(
      hour: 17,
      minute: 0,
      quote: 'Evening inspiration to end your day well!',
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        BlocProvider<QuoteBloc>(create: (_) => QuoteBloc()),
        BlocProvider<HomeBloc>(create: (_) => HomeBloc()),
        BlocProvider<FavoritesBloc>(create: (_) => FavoritesBloc()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: AppConstants.appName,
            theme: AppTheme.getTheme(false),
            darkTheme: AppTheme.getTheme(true),
            themeMode: themeProvider.themeMode,
            routerConfig: _router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // Home branch
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          ],
        ),
        // Mood branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/mood',
              builder: (context, state) => const MoodScreen(),
            ),
          ],
        ),
        // Favorites branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/favorites',
              builder: (context, state) => const FavoritesScreen(),
            ),
          ],
        ),
        // Settings branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: AppConstants.standardAnimation,
        child: navigationShell,
      ),
      extendBody: true, // Makes content flow under the navigation bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color:
                  isDarkMode
                      ? AppConstants.shadowColorDark
                      : AppConstants.shadowColor,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) {
              // Load favorites when navigating to Favorites tab
              if (index == 2) {
                context.read<FavoritesBloc>().add(LoadFavoritesEvent());
              }

              // Navigate to the selected tab
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            backgroundColor:
                isDarkMode
                    ? AppConstants.cardColorDark
                    : AppConstants.cardColor,
            elevation: 0,
            height: isLargeScreen ? 70 : 65,
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            animationDuration: AppConstants.standardAnimation,
            destinations: [
              NavigationDestination(
                icon: Icon(
                  Icons.home_outlined,
                  color:
                      isDarkMode
                          ? AppConstants.textColorDark.withOpacity(0.7)
                          : AppConstants.textColor.withOpacity(0.7),
                ),
                selectedIcon: Icon(
                  Icons.home_rounded,
                  color:
                      isDarkMode
                          ? AppConstants.primaryColorDark
                          : AppConstants.primaryColor,
                ),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.psychology_outlined,
                  color:
                      isDarkMode
                          ? AppConstants.textColorDark.withOpacity(0.7)
                          : AppConstants.textColor.withOpacity(0.7),
                ),
                selectedIcon: Icon(
                  Icons.psychology_rounded,
                  color:
                      isDarkMode
                          ? AppConstants.primaryColorDark
                          : AppConstants.primaryColor,
                ),
                label: 'Mood',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.favorite_outline_rounded,
                  color:
                      isDarkMode
                          ? AppConstants.textColorDark.withOpacity(0.7)
                          : AppConstants.textColor.withOpacity(0.7),
                ),
                selectedIcon: Icon(
                  Icons.favorite_rounded,
                  color:
                      isDarkMode
                          ? AppConstants.accentColorDark
                          : AppConstants.accentColor,
                ),
                label: 'Favorites',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.settings_outlined,
                  color:
                      isDarkMode
                          ? AppConstants.textColorDark.withOpacity(0.7)
                          : AppConstants.textColor.withOpacity(0.7),
                ),
                selectedIcon: Icon(
                  Icons.settings_rounded,
                  color:
                      isDarkMode
                          ? AppConstants.tertiaryColorDark
                          : AppConstants.tertiaryColor,
                ),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
