import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/screens/profile/profile_screen.dart';
import '../../features/quotes/logic/bloc/favorites/favorites_bloc.dart';
import '../../features/quotes/logic/bloc/favorites/favorites_event.dart';
import '../../features/quotes/presentation/screens/favorites_screen.dart';
import '../../features/quotes/presentation/screens/home_screen.dart';
import '../../features/quotes/presentation/screens/settings_screen.dart';
import '../utils/constants.dart';

/// A scaffold with bottom navigation that uses standard Navigator
class BottomNavScaffold extends StatefulWidget {
  final int initialIndex;

  const BottomNavScaffold({super.key, required this.initialIndex});

  @override
  State<BottomNavScaffold> createState() => _BottomNavScaffoldState();
}

class _BottomNavScaffoldState extends State<BottomNavScaffold> {
  late int _currentIndex;
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;

        // Try to pop the current tab's navigator
        final navigatorForCurrentTab =
            _navigatorKeys[_currentIndex].currentState;

        if (navigatorForCurrentTab != null && navigatorForCurrentTab.canPop()) {
          // If current tab has navigation history, pop to previous page in this tab
          navigatorForCurrentTab.pop();
        } else if (_currentIndex != 0) {
          // If we're not on the home tab, switch to home tab
          setState(() {
            _currentIndex = 0;
          });
        } else {
          // If we're on home tab with no history, bubble up to app-level navigator
          // This will trigger the ExitConfirmationWrapper
          Navigator.of(context, rootNavigator: true).maybePop();
        }
      },
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: AppConstants.standardAnimation,
          child: IndexedStack(
            index: _currentIndex,
            children: [
              _buildNavigator(0, const HomeScreen()),
              _buildNavigator(1, const FavoritesScreen()),
              _buildNavigator(2, const ProfileScreen()),
              _buildNavigator(3, const SettingsScreen()),
            ],
          ),
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
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                // Load favorites when navigating to Favorites tab
                if (index == 1) {
                  context.read<FavoritesBloc>().add(LoadFavoritesEvent());
                }

                setState(() {
                  _currentIndex = index;
                });
              },
              backgroundColor:
                  isDarkMode
                      ? AppConstants.cardColorDark
                      : AppConstants.cardColor,
              elevation: 0,
              height: isLargeScreen ? 70 : 65,
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
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
                    Icons.person_outline_rounded,
                    color:
                        isDarkMode
                            ? AppConstants.textColorDark.withOpacity(0.7)
                            : AppConstants.textColor.withOpacity(0.7),
                  ),
                  selectedIcon: Icon(
                    Icons.person_rounded,
                    color:
                        isDarkMode
                            ? AppConstants.secondaryColorDark
                            : AppConstants.secondaryColor,
                  ),
                  label: 'Profile',
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
                            ? AppConstants.tertiaryColorDark.withOpacity(0.8)
                            : AppConstants.tertiaryColor.withOpacity(0.8),
                  ),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigator(int index, Widget child) {
    return Navigator(
      key: _navigatorKeys[index],
      // This ensures each tab maintains its own navigation history
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => child,
          );
        }

        // Handle deeper navigation within each tab
        // You can add additional routes specific to each tab here
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => child,
        );
      },
    );
  }
}
