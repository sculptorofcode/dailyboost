import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/constants.dart';
import '../../data/models/quote_model.dart';
import '../../logic/bloc/favorites/favorites_bloc.dart';
import '../../logic/bloc/favorites/favorites_event.dart';
import '../../logic/bloc/favorites/favorites_state.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final GlobalKey _quoteKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.standardAnimation,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Remove from Favorites',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Are you sure you want to remove this quote from your favorites?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
                child: const Text('Remove'),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.baseRadius),
            ),
            backgroundColor: Theme.of(context).cardColor,
          ),
    );

    return result ?? false;
  }

  Future<void> _shareQuote(QuoteModel quote) async {
    try {
      RenderRepaintBoundary boundary =
          _quoteKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/quote.png').create();
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: '"${quote.content}" - ${quote.author}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to share quote'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.baseRadius),
          ),
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _animationController,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                size: 60,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No favorites yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'When you find a quote that inspires you, tap the heart icon to add it to your favorites.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? AppConstants.textColorDark.withOpacity(0.7)
                          : AppConstants.textColor.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.explore),
              label: const Text('Explore Quotes'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              centerTitle: true,
              title: Text(
                'Your Favorites',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.sort_rounded,
                    color:
                        isDarkMode
                            ? AppConstants.primaryColorDark
                            : AppConstants.primaryColor,
                  ),
                  onPressed: () {
                    // TODO: Implement sorting options
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Sorting options coming soon'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.baseRadius,
                          ),
                        ),
                      ),
                    );
                  },
                  tooltip: 'Sort quotes',
                ),
              ],
            ),
            BlocBuilder<FavoritesBloc, FavoritesState>(
              builder: (context, state) {
                if (state is FavoritesLoaded) {
                  final favorites = state.favoriteQuotes;
                  if (favorites.isEmpty) {
                    return SliverFillRemaining(child: _buildEmptyState());
                  }

                  // Populate list with favorites
                  return SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final quote = favorites[index];

                        // Create staggered animation based on index
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
                            return Transform.translate(
                              offset: Offset(0, 20 * (1 - itemAnimation.value)),
                              child: Opacity(
                                opacity: itemAnimation.value,
                                child: child,
                              ),
                            );
                          },
                          child: _buildFavoriteCard(
                            context,
                            quote,
                            isDarkMode,
                            index,
                          ),
                        );
                      }, childCount: favorites.length),
                    ),
                  );
                } else if (state is FavoritesLoading) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is FavoritesInitial) {
                  // Only trigger loading if we're in the initial state
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.read<FavoritesBloc>().add(LoadFavoritesEvent());
                  });
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Something went wrong',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<FavoritesBloc>().add(
                                LoadFavoritesEvent(),
                              );
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
            // Add extra bottom padding to account for the navigation bar
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(
    BuildContext context,
    QuoteModel quote,
    bool isDarkMode,
    int index,
  ) {
    // Create a slightly different background color for every other item
    final isEvenIndex = index % 2 == 0;
    final cardColor =
        isDarkMode
            ? Color.alphaBlend(
              Theme.of(
                context,
              ).colorScheme.primary.withOpacity(isEvenIndex ? 0.05 : 0.03),
              Theme.of(context).colorScheme.surface,
            )
            : Color.alphaBlend(
              Theme.of(
                context,
              ).colorScheme.primary.withOpacity(isEvenIndex ? 0.03 : 0.01),
              Theme.of(context).colorScheme.surface,
            );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        elevation: 4,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.baseRadius),
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quote icon
                  Row(
                    children: [
                      Icon(
                        Icons.format_quote,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.5),
                        size: 24,
                      ),
                      const Spacer(),
                      // Mood tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          quote.mood,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Quote content
                  RepaintBoundary(
                    key: _quoteKey,
                    child: Text(
                      '"${quote.content}"',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color:
                            isDarkMode
                                ? AppConstants.textColorDark
                                : AppConstants.textColor,
                        height: 1.5,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Author with accent line
                  Row(
                    children: [
                      Container(
                        width: 3,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          quote.author,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => _shareQuote(quote),
                    icon: Icon(
                      Icons.share_outlined,
                      color:
                          isDarkMode
                              ? AppConstants.tertiaryColorDark
                              : AppConstants.tertiaryColor,
                    ),
                    tooltip: 'Share this quote',
                  ),
                  IconButton(
                    onPressed: () async {
                      final confirmed = await _confirmDelete(context);
                      if (confirmed) {
                        context.read<FavoritesBloc>().add(
                          RemoveFromFavoritesEvent(quote.id),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Quote removed from favorites'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.baseRadius,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    icon: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    tooltip: 'Remove from favorites',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
