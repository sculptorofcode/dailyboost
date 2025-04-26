import 'package:dailyboost/features/quotes/logic/bloc/favorites/favorites_bloc.dart';
import 'package:dailyboost/features/quotes/logic/bloc/favorites/favorites_event.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/utils/constants.dart';
import 'features/auth/logic/providers/auth_provider.dart';
import 'features/auth/presentation/screens/auth_wrapper.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/signup_screen.dart';
import 'features/quotes/logic/bloc/home/home_bloc.dart';
import 'features/quotes/logic/bloc/quote/quote_bloc.dart';
import 'features/quotes/presentation/screens/favorites_screen.dart';
import 'features/quotes/presentation/screens/home_screen.dart';
import 'features/quotes/presentation/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserAuthProvider()),
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

// Router configuration with authentication
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    // Auth routes
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // Main app shell with bottom navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        // Wrap the scaffold with AuthWrapper to handle auth state
        return AuthWrapper(
          child: ScaffoldWithNavBar(navigationShell: navigationShell),
        );
      },
      branches: [
        // Home branch
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
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
  redirect: (context, state) {
    final authProvider = Provider.of<UserAuthProvider>(context, listen: false);
    final isLoggedIn = authProvider.isAuthenticated;

    final isGoingToAuthScreen =
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/signup' ||
        state.matchedLocation == '/forgot-password';

    // If not logged in and not going to auth screen, redirect to login
    if (!isLoggedIn && !isGoingToAuthScreen) {
      return '/login';
    }

    // If logged in and going to auth screen, redirect to home
    if (isLoggedIn && isGoingToAuthScreen) {
      return '/';
    }

    // Allow the navigation to proceed
    return null;
  },
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
              if (index == 1) {
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
