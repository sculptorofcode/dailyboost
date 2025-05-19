import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/theme_provider.dart';
import '../../../../core/utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  final _settingsBox = Hive.box<String>('app_settings');

  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  double _fontSize = 16.0;
  String _quoteDisplayStyle = 'Card';

  @override
  void initState() {
    super.initState();
    _loadSettings();

    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.standardAnimation,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadSettings() {
    setState(() {
      _notificationsEnabled =
          _settingsBox.get('notifications_enabled', defaultValue: 'true') ==
          'true';
      _darkModeEnabled =
          _settingsBox.get('dark_mode', defaultValue: 'system') == 'dark';
      _fontSize = double.parse(
        _settingsBox.get('font_size', defaultValue: '16.0')!,
      );
      _quoteDisplayStyle =
          _settingsBox.get('quote_style', defaultValue: 'Card')!;
    });
  }

  void _saveSettings() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    // Save notification settings
    _settingsBox.put('notifications_enabled', _notificationsEnabled.toString());

    // Save theme settings through the provider
    themeProvider.setDarkMode(_darkModeEnabled);
    themeProvider.setFontSize(_fontSize);
    themeProvider.setQuoteStyle(_quoteDisplayStyle);

    // Update UI
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  'Settings',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appearance',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSettingsCard(
                        child: Column(
                          children: [
                            _buildSwitchTile(
                              title: 'Dark Mode',
                              subtitle: 'Switch between light and dark theme',
                              icon: Icons.dark_mode_rounded,
                              value: _darkModeEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _darkModeEnabled = value;
                                  _saveSettings();
                                });
                              },
                            ),
                            const Divider(),
                            _buildSliderTile(
                              title: 'Font Size',
                              subtitle: 'Adjust quote text size',
                              icon: Icons.format_size_rounded,
                              value: _fontSize,
                              min: 12.0,
                              max: 24.0,
                              onChanged: (value) {
                                setState(() {
                                  _fontSize = value;
                                  _saveSettings();
                                });
                              },
                            ),
                            const Divider(),
                            _buildDropdownTile(
                              title: 'Quote Style',
                              subtitle: 'Change how quotes are displayed',
                              icon: Icons.style_rounded,
                              value: _quoteDisplayStyle,
                              items: const [
                                'Card',
                                'Minimal',
                                'Gradient',
                                'Classic',
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _quoteDisplayStyle = value;
                                    _saveSettings();
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      Text(
                        'Notifications',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSettingsCard(
                        child: _buildSwitchTile(
                          title: 'Daily Quotes',
                          subtitle:
                              'Receive inspirational quotes throughout the day',
                          icon: Icons.notifications_rounded,
                          value: _notificationsEnabled,
                          onChanged: (value) {
                            setState(() {
                              _notificationsEnabled = value;
                              _saveSettings();
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 24),
                      Text(
                        'About',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSettingsCard(
                        child: Column(
                          children: [
                            _buildInfoTile(
                              title: 'Version',
                              subtitle: '1.0.0',
                              icon: Icons.info_outline_rounded,
                            ),
                            const Divider(),
                            _buildTappableTile(
                              title: 'Privacy Policy',
                              subtitle: 'Read our privacy policy',
                              icon: Icons.privacy_tip_outlined,
                              onTap: () {
                                launchUrl(
                                  Uri.parse(
                                    'https://dailyboost-web.vercel.app/privacy',
                                  ),
                                  mode: LaunchMode.externalApplication,
                                );
                              },
                            ),
                            const Divider(),
                            _buildTappableTile(
                              title: 'Rate App',
                              subtitle:
                                  'If you enjoy using DailyBoost, please rate us!',
                              icon: Icons.star_outline_rounded,
                              onTap: () {
                                // TODO: Implement rating functionality
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Rating feature coming soon'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Add extra bottom padding for navigation bar
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required Widget child}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.baseRadius),
      ),
      child: Padding(padding: const EdgeInsets.all(4.0), child: child),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      secondary: Icon(icon, color: Theme.of(context).colorScheme.primary),
      value: value,
      onChanged: onChanged,
      activeColor: Theme.of(context).colorScheme.primary,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 4.0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.baseRadius),
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(title, style: Theme.of(context).textTheme.titleMedium),
            subtitle: Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
            contentPadding: EdgeInsets.zero,
          ),
          Row(
            children: [
              const SizedBox(width: 72),
              Expanded(
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: ((max - min) * 2).toInt(),
                  label: value.toStringAsFixed(1),
                  onChanged: onChanged,
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  value.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          DropdownButton<String>(
            value: value,
            items:
                items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
            onChanged: onChanged,
            underline: const SizedBox(),
            icon: Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return ListTile(
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 4.0,
      ),
    );
  }

  Widget _buildTappableTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).colorScheme.primary,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 4.0,
      ),
    );
  }
}
