import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dailyboost/core/theme/theme_provider.dart';
import 'package:dailyboost/features/quotes/data/models/quote_model.dart';
import 'package:dailyboost/features/quotes/logic/bloc/favorites/favorites_bloc.dart';
import 'package:dailyboost/features/quotes/logic/bloc/favorites/favorites_event.dart'
    as fav_events;
import 'package:dailyboost/features/quotes/logic/bloc/favorites/favorites_state.dart';
import 'package:dailyboost/features/quotes/logic/bloc/home/home_bloc.dart';
import 'package:dailyboost/features/quotes/logic/bloc/home/home_event.dart';
import 'package:dailyboost/features/quotes/logic/bloc/home/home_state.dart';
import 'package:dailyboost/features/quotes/presentation/widgets/favorite_check.dart';
import 'package:dailyboost/features/quotes/presentation/widgets/loading.dart';
import 'package:dailyboost/features/quotes/presentation/widgets/quote_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class QuoteBatchView extends StatefulWidget {
  final List<QuoteModel> quotes;
  final int totalCount;
  final bool isDarkMode;
  final VoidCallback onLoadMore;

  const QuoteBatchView({
    required this.quotes,
    required this.totalCount,
    required this.isDarkMode,
    required this.onLoadMore,
    super.key,
  });

  @override
  State<QuoteBatchView> createState() => _QuoteBatchViewState();
}

class _QuoteBatchViewState extends State<QuoteBatchView>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  int _currentPage = 0;

  // Loading indicator state
  bool _isLoadingMore = false;
  // Flag to show the loading page
  bool _showLoadingPage = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Set up animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
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

    _rotateAnimation = Tween<double>(begin: 0.02, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    // Start the animation initially
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _shareQuoteImageWithKey(GlobalKey quoteKey) async {
    try {
      RenderRepaintBoundary boundary =
          quoteKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      // Capture image with higher resolution (3x pixel density)
      await boundary.toImage(pixelRatio: 10.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/quote.png').create();
      await file.writeAsBytes(pngBytes);

      // Using the correct method from share_plus
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Check out this quote!');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to share quote'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  // Function to load more quotes with loading indicator
  void _loadMoreQuotesWithIndicator() {
    if (!_isLoadingMore) {
      // Get current state to check if we've reached max
      final homeBloc = context.read<HomeBloc>();
      final currentState = homeBloc.state;

      // Only load more if we haven't reached the max
      if (currentState is QuoteBatchLoaded && !currentState.hasReachedMax) {
        setState(() {
          _isLoadingMore = true;
          _showLoadingPage = true;
        });

        widget.onLoadMore();

        // Listen for state changes to properly update UI
        final blocsub = homeBloc.stream.listen((state) {
          if (state is HomeError) {
            // Show error message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error loading more quotes: ${state.message}'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: 'Retry',
                    textColor: Colors.white,
                    onPressed: _loadMoreQuotesWithIndicator,
                  ),
                ),
              );

              if (mounted) {
                setState(() {
                  _isLoadingMore = false;
                  _showLoadingPage = false;
                });
              }
            }
          } else if (state is QuoteBatchLoaded) {
            // Successfully loaded
            if (mounted) {
              setState(() {
                _isLoadingMore = false;
                _showLoadingPage = false;
              });
            }
          }
        });

        // Auto-cancel subscription after a timeout
        Future.delayed(const Duration(seconds: 5), () {
          blocsub.cancel();
          if (mounted && _isLoadingMore) {
            setState(() {
              _isLoadingMore = false;
              _showLoadingPage = false;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final double fontSize = themeProvider.fontSize;
    final String quoteStyle = themeProvider.quoteDisplayStyle;

    return BlocListener<FavoritesBloc, FavoritesState>(
      listener: (context, state) {
        // Show authentication error messages from FavoritesBloc
        if (state is FavoritesAuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Login',
                onPressed: () {
                  // Navigate to login screen or show login dialog
                  // For example: Navigator.pushNamed(context, '/login');
                },
                textColor: Colors.white,
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      },
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount:
                _showLoadingPage
                    ? widget.quotes.length + 1
                    : widget.quotes.length,
            onPageChanged: (int index) {
              debugPrint(
                'Page changed to index: $index, currentPage: $_currentPage, length: ${widget.quotes.length}',
              );
              setState(() {
                _currentPage = index;
              });
              // Dispatch ViewQuoteEvent for the newly visible quote
              if (index < widget.quotes.length) {
                final quote = widget.quotes[index];
                context.read<HomeBloc>().add(ViewQuoteEvent(quote.id));
              }
              // Check if we need to load more quotes
              if (index >= widget.quotes.length - 5 && !_showLoadingPage) {
                _loadMoreQuotesWithIndicator();
              }
              // Reset and restart animation when page changes
              _animationController.reset();
              _animationController.forward();
            },
            itemBuilder: (context, index) {
              // If we're showing the loading page and this is the last index, show loading indicator
              if (_showLoadingPage && index == widget.quotes.length) {
                return const Center(child: LoadingIndicator());
              }
              final quote = widget.quotes[index];
              final GlobalKey quoteKey = GlobalKey();
              // Check if this quote is liked using BlocBuilder
              return BlocBuilder<HomeBloc, HomeState>(
                buildWhen: (previous, current) {
                  // Only rebuild when liked status or view count changes for this quote
                  if (previous is QuoteBatchLoaded &&
                      current is QuoteBatchLoaded) {
                    return previous.isQuoteLiked(quote.id) !=
                            current.isQuoteLiked(quote.id) ||
                        previous.getViewCount(quote.id) !=
                            current.getViewCount(quote.id);
                  }
                  return true;
                },
                builder: (context, state) {
                  final bool isLiked =
                      state is QuoteBatchLoaded
                          ? state.isQuoteLiked(quote.id)
                          : false;
                  final int viewCount =
                      state is QuoteBatchLoaded
                          ? state.getViewCount(quote.id)
                          : 0;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: FavoriteCheck(
                          key: ValueKey("favorite-${quote.id}"),
                          quote: quote,
                          builder:
                              (isFavorite, toggleFavorite) => QuoteView(
                                quote: quote,
                                isDarkMode: widget.isDarkMode,
                                fontSize: fontSize,
                                quoteStyle: quoteStyle,
                                animationController: _animationController,
                                opacityAnimation: _opacityAnimation,
                                scaleAnimation: _scaleAnimation,
                                rotateAnimation: _rotateAnimation,
                                isFavorite: isFavorite,
                                isLiked: isLiked,
                                onLike: () {
                                  // Get current HomeBloc state for determining if quote is liked
                                  final homeState = context.read<HomeBloc>().state;
                                  final favoritesBloc = context.read<FavoritesBloc>();
                                  
                                  if (homeState is QuoteBatchLoaded) {
                                    if (homeState.isQuoteLiked(quote.id)) {
                                      // Remove like using only FavoritesBloc
                                      favoritesBloc.add(fav_events.UnlikeQuoteEvent(quote.id));
                                      
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            'Removed from liked quotes',
                                          ),
                                          backgroundColor:
                                              Theme.of(context).colorScheme.error,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          duration: const Duration(
                                            milliseconds: 800,
                                          ),
                                        ),
                                      );
                                    } else {
                                      // Add like using only FavoritesBloc
                                      favoritesBloc.add(fav_events.LikeQuoteEvent(quote));
                                      
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            'Added to liked quotes!',
                                          ),
                                          backgroundColor:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          duration: const Duration(
                                            milliseconds: 800,
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                                onSaveToFavorites: () {
                                  toggleFavorite();
                                  final favoritesBloc = context.read<FavoritesBloc>();
                                  
                                  if (!isFavorite) {
                                    // Add to favorites in FavoritesBloc
                                    favoritesBloc.add(
                                      fav_events.AddToFavoritesEvent(quote),
                                    );

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Added to favorites!',
                                        ),
                                        backgroundColor:
                                            Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        duration: const Duration(
                                          milliseconds: 800,
                                        ),
                                      ),
                                    );
                                  } else {
                                    // Remove from favorites in FavoritesBloc
                                    favoritesBloc.add(
                                      fav_events.RemoveFromFavoritesEvent(
                                        quote.id,
                                      ),
                                    );

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Removed from favorites',
                                        ),
                                        backgroundColor:
                                            Theme.of(context).colorScheme.error,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        duration: const Duration(
                                          milliseconds: 800,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                onShareQuote:
                                    () => _shareQuoteImageWithKey(quoteKey),
                                quoteKey: quoteKey,
                              ),
                        ),
                      ), // View counter and position counter below the quote
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // View count
                            const Icon(
                              Icons.visibility,
                              size: 20,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$viewCount views',
                              style: TextStyle(color: Colors.grey),
                            ),

                            // Quote position counter (always show)
                            const SizedBox(width: 12),
                            Icon(
                              state is QuoteBatchLoaded &&
                                      state.currentMood != null
                                  ? Icons.filter_list
                                  : Icons.format_quote,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${index + 1}/${widget.totalCount}',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          // Top mood filter indicator
          BlocBuilder<HomeBloc, HomeState>(
            buildWhen:
                (previous, current) =>
                    (previous is QuoteBatchLoaded &&
                        current is QuoteBatchLoaded) &&
                    (previous.currentMood != current.currentMood ||
                        previous.quotes.length != current.quotes.length),
            builder: (context, state) {
              if (state is QuoteBatchLoaded && state.currentMood != null) {
                return Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.filter_alt, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${state.currentMood} • ${widget.totalCount} quote${widget.totalCount != 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Clear filter button
                        GestureDetector(
                          onTap: () {
                            context.read<HomeBloc>().add(RefreshQuotesEvent());
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surface.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'Clear filter',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Loading indicator overlay for "load more" operations
          if (_isLoadingMore)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color:
                    widget.isDarkMode
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
                        : Theme.of(context).colorScheme.primary.withOpacity(0.8),
                height: 50,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
