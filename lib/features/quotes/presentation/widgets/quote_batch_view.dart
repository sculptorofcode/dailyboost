import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dailyboost/core/theme/theme_provider.dart';
import 'package:dailyboost/features/quotes/data/models/quote_model.dart';
import 'package:dailyboost/features/quotes/logic/bloc/home/home_bloc.dart';
import 'package:dailyboost/features/quotes/logic/bloc/home/home_event.dart';
import 'package:dailyboost/features/quotes/logic/bloc/home/home_state.dart';
import 'package:dailyboost/features/quotes/presentation/widgets/favorite_check.dart';
import 'package:dailyboost/features/quotes/presentation/widgets/loading.dart';
import 'package:dailyboost/features/quotes/presentation/widgets/quote_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class QuoteBatchView extends StatefulWidget {
  final List<QuoteModel> quotes;
  final bool isDarkMode;
  final VoidCallback onLoadMore;

  const QuoteBatchView({
    required this.quotes,
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

    return Stack(
      children: [
        PageView.builder(            
          controller: _pageController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: _showLoadingPage ? widget.quotes.length + 1 : widget.quotes.length,
          onPageChanged: (int index) {
            debugPrint('Page changed to index: $index, currentPage: $_currentPage, length: ${widget.quotes.length}');
            setState(() {
              _currentPage = index;
            });
        
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
        
            return FavoriteCheck(
              key: ValueKey("favorite-${quote.id}"),
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
                    onNewQuote: () {
                      final nextPage = (_currentPage + 1) % widget.quotes.length;
                      _pageController.animateToPage(
                        nextPage,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    onSaveToFavorites: () {
                      toggleFavorite();
                      if (!isFavorite) {
                        context.read<HomeBloc>().add(AddToFavoritesEvent(quote));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Added to favorites!'),
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            duration: const Duration(milliseconds: 300),
                          ),
                        );
                      } else {
                        context.read<HomeBloc>().add(
                          RemoveFromFavoritesEvent(quote.id),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Removed from favorites'),
                            backgroundColor: Theme.of(context).colorScheme.error,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            duration: const Duration(milliseconds: 300),
                          ),
                        );
                      }
                    },
                    onShareQuote: () => _shareQuoteImageWithKey(quoteKey),
                    quoteKey: quoteKey,
                  ),
            );
          },
        ),
        
        // Loading indicator overlay for "load more" operations
        if (_isLoadingMore)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Loading more quotes...',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
