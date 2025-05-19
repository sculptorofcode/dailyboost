import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dailyboost/core/utils/constants.dart';
import 'package:dailyboost/features/auth/data/models/user_profile_model.dart';
import 'package:dailyboost/features/auth/logic/providers/auth_provider.dart';
import 'package:dailyboost/features/auth/presentation/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isUpdatingLocation = false;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();

    // Refresh profile data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<UserAuthProvider>(
        context,
        listen: false,
      );
      authProvider.refreshProfile();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Format Timestamp to readable date
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    return DateFormat('MMM d, yyyy - h:mm a').format(timestamp.toDate());
  }

  // Update user location
  Future<void> _updateLocation() async {
    setState(() {
      _isUpdatingLocation = true;
    });

    try {
      final authProvider = Provider.of<UserAuthProvider>(
        context,
        listen: false,
      );
      await authProvider.updateLocation();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Location updated successfully'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.baseRadius),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to update location'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.baseRadius),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingLocation = false;
        });
      }
    }
  }

  // Show logout confirmation dialog
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Logout',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Are you sure you want to logout from your account?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed:
                    _isLoggingOut
                        ? null
                        : () async {
                          setState(() {
                            _isLoggingOut = true;
                          });
                          Navigator.of(context).pop();
                          // Perform logout
                          final authProvider = Provider.of<UserAuthProvider>(
                            context,
                            listen: false,
                          );
                          await authProvider.logout();
                          if (mounted) {
                            // Navigate to login using MaterialPageRoute to prevent auto-pop issues
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Theme.of(context).colorScheme.secondary,
                  ),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                child:
                    _isLoggingOut
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Text('Logout'),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.baseRadius),
            ),
            backgroundColor: Theme.of(context).cardColor,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              centerTitle: true,
              title: FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Profile',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Consumer<UserAuthProvider>(
                  builder: (context, authProvider, _) {
                    final user = authProvider.user;
                    final profile = authProvider.userProfile;
                    final isLoading = authProvider.isProfileLoading;

                    if (isLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 100.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (user == null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 100.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Please sign in to view your profile',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed:
                                    () => {
                                      // Use Navigator directly to prevent auto-pop issues
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => const LoginScreen(),
                                        ),
                                      ),
                                    },
                                icon: Icon(
                                  Icons.login_rounded,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  'Login',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                    isDarkMode
                                        ? AppConstants.primaryColorDark
                                        : AppConstants.primaryColor,
                                  ),
                                  padding: MaterialStateProperty.all(
                                    const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 12,
                                    ),
                                  ),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppConstants.baseRadius,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User profile card
                          _buildProfileCard(context, user, profile, isDarkMode),
                          const SizedBox(height: 20),

                          // Device information section
                          Text(
                            'Device Information',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(context, [
                            {
                              'title': 'Device ID',
                              'value': profile?.deviceId ?? 'Unknown',
                            },
                            {
                              'title': 'Model',
                              'value': profile?.deviceModel ?? 'Unknown',
                            },
                            {
                              'title': 'Operating System',
                              'value': profile?.deviceOS ?? 'Unknown',
                            },
                          ], isDarkMode),
                          const SizedBox(height: 20),

                          // Location section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Location',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton.icon(
                                onPressed:
                                    _isUpdatingLocation
                                        ? null
                                        : _updateLocation,
                                icon:
                                    _isUpdatingLocation
                                        ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : const Icon(Icons.refresh),
                                label: Text(
                                  _isUpdatingLocation
                                      ? 'Updating...'
                                      : 'Update',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildLocationCard(context, profile, isDarkMode),
                          const SizedBox(height: 20),

                          // Activity section
                          Text(
                            'Activity',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(context, [
                            {
                              'title': 'Last Active',
                              'value': _formatTimestamp(profile?.lastActive),
                            },
                            {
                              'title': 'Account Created',
                              'value': _formatTimestamp(profile?.createdAt),
                            },
                          ], isDarkMode),

                          // Logout button
                          const SizedBox(height: 20),

                          // Logout button
                          Center(
                            child: OutlinedButton.icon(
                              onPressed: () => _showLogoutConfirmation(context),
                              icon: Icon(
                                Icons.logout_rounded,
                                color:
                                    isDarkMode
                                        ? AppConstants.accentColorDark
                                        : AppConstants.accentColor,
                              ),
                              label: Text(
                                'Logout',
                                style: TextStyle(
                                  color:
                                      isDarkMode
                                          ? AppConstants.accentColorDark
                                          : AppConstants.accentColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 24,
                                ),
                                side: BorderSide(
                                  color:
                                      isDarkMode
                                          ? AppConstants.accentColorDark
                                          : AppConstants.accentColor,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.baseRadius,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Add extra bottom padding for navigation bar
                          const SizedBox(height: 80),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    User user,
    UserProfileModel? profile,
    bool isDarkMode,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.baseRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile image and name
            Row(
              children: [
                if (user.photoURL != null)
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(user.photoURL!),
                  )
                else
                  CircleAvatar(
                    radius: 30,
                    backgroundColor:
                        isDarkMode
                            ? AppConstants.accentColorDark
                            : AppConstants.accentColor,
                    child: Text(
                      user.displayName?.isNotEmpty == true
                          ? user.displayName![0].toUpperCase()
                          : (user.email?.isNotEmpty == true
                              ? user.email![0].toUpperCase()
                              : 'U'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName?.isNotEmpty == true
                            ? user.displayName!
                            : 'User',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email ?? 'No email',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onBackground.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (user.emailVerified)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified_user,
                      size: 16,
                      color: Colors.green[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Email verified',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.green[600]),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    List<Map<String, String>> items,
    bool isDarkMode,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.baseRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children:
              items.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['title'] ?? '',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          item['value'] ?? 'Unknown',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onBackground.withOpacity(0.7),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildLocationCard(
    BuildContext context,
    UserProfileModel? profile,
    bool isDarkMode,
  ) {
    final hasLocation = profile?.location != null;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.baseRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasLocation ? Icons.location_on : Icons.location_off,
                  color:
                      hasLocation
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  hasLocation ? 'Location stored' : 'Location not available',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color:
                        hasLocation
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
            if (hasLocation) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Latitude',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    profile!.location!.latitude.toStringAsFixed(6),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Longitude',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    profile.location!.longitude.toStringAsFixed(6),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ] else
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Tap "Update" to get your current location',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
