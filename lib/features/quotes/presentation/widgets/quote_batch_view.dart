import 'package:dailyboost/core/theme/theme_provider.dart';
import 'package:dailyboost/features/quotes/data/models/quote_model.dart';
import 'package:dailyboost/features/quotes/logic/bloc/home/home_bloc.dart';
import 'package:dailyboost/features/quotes/logic/bloc/home/home_event.dart';
import 'package:dailyboost/features/quotes/presentation/widgets/favorite_check.dart';
import 'package:dailyboost/features/quotes/presentation/widgets/quote_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final double fontSize = themeProvider.fontSize;
    final String quoteStyle = themeProvider.quoteDisplayStyle;

    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemCount: widget.quotes.length,
      onPageChanged: (int index) {
        setState(() {
          _currentPage = index;
        });

        // Check if we need to load more quotes
        if (index >= widget.quotes.length - 5) {
          widget.onLoadMore();
        }

        // Reset and restart animation when page changes
        _animationController.reset();
        _animationController.forward();
      },
      itemBuilder: (context, index) {
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
    );
  }
}
