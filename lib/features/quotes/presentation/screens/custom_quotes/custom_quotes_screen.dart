import 'package:dailyboost/core/navigation/navigation_utils.dart';
import 'package:dailyboost/core/utils/constants.dart';
import 'package:dailyboost/features/quotes/data/models/custom_quote_model.dart';
import 'package:dailyboost/features/quotes/logic/bloc/custom_quotes/custom_quotes_bloc.dart';
import 'package:dailyboost/features/quotes/logic/bloc/custom_quotes/custom_quotes_event.dart';
import 'package:dailyboost/features/quotes/logic/bloc/custom_quotes/custom_quotes_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class CustomQuotesScreen extends StatefulWidget {
  const CustomQuotesScreen({super.key});

  @override
  State<CustomQuotesScreen> createState() => _CustomQuotesScreenState();
}

class _CustomQuotesScreenState extends State<CustomQuotesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Pagination variables
  bool _isLoadingMore = false;
  bool _hasReachedEnd = false;
  final List<CustomQuoteModel> _userQuotes = [];
  final List<CustomQuoteModel> _communityQuotes = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load user's custom quotes when the screen is first shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load both types of quotes initially
      _loadUserQuotes();
      // Preload community quotes too for faster tab switching
      context.read<CustomQuotesBloc>().add(LoadPublicCustomQuotesEvent());
    });
    
    _tabController.addListener(() {
      // When tab changes, ensure the appropriate quotes are shown
      if (_tabController.index == 0 && _userQuotes.isEmpty) {
        _loadUserQuotes();
      } else if (_tabController.index == 1 && _communityQuotes.isEmpty) {
        _loadCommunityQuotes();
      }
    });
  }
  
  void _loadUserQuotes() {
    if (!_isLoadingMore) {
      context.read<CustomQuotesBloc>().add(LoadUserCustomQuotesEvent());
    }
  }
  
  void _loadCommunityQuotes() {
    if (!_isLoadingMore) {
      context.read<CustomQuotesBloc>().add(LoadPublicCustomQuotesEvent());
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Quotes',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: isDarkMode
              ? AppConstants.primaryColorDark
              : AppConstants.primaryColor,
          labelColor: isDarkMode
              ? AppConstants.primaryColorDark
              : AppConstants.primaryColor,
          unselectedLabelColor: isDarkMode
              ? AppConstants.textColorDark.withOpacity(0.6)
              : AppConstants.textColor.withOpacity(0.6),
          tabs: const [
            Tab(text: 'My Quotes'),
            Tab(text: 'Community'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // My Quotes Tab
          _buildQuotesList(isMyQuotes: true),
          
          // Community Quotes Tab
          _buildQuotesList(isMyQuotes: false),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 65.0),
        child: FloatingActionButton(
          onPressed: () => _navigateToCreateQuote(context),
          backgroundColor: isDarkMode
              ? AppConstants.primaryColorDark
              : AppConstants.primaryColor,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
  
  Widget _buildQuotesList({required bool isMyQuotes}) {
    return BlocBuilder<CustomQuotesBloc, CustomQuotesState>(
      builder: (context, state) {
        // Handle the CustomQuoteUpdated state - update the quote in the list
        if (state is CustomQuoteUpdated) {
          final updatedQuote = state.quote;
          // If the quote's visibility changed, we need to update the lists
          if (isMyQuotes) {
            // Find and update the quote in the user quotes list
            final index = _userQuotes.indexWhere((q) => q.id == updatedQuote.id);
            if (index >= 0) {
              _userQuotes[index] = updatedQuote;
            }
          }
          // Return the current list with updated quote
          return _buildQuotesListView(
            quotes: isMyQuotes ? _userQuotes : _communityQuotes,
            isMyQuotes: isMyQuotes,
          );
        }
        
        // Handle loading state
        if (state is CustomQuotesLoading && 
            ((_userQuotes.isEmpty && isMyQuotes) || (_communityQuotes.isEmpty && !isMyQuotes))) {
          return _buildShimmerLoading();
        }
        
        // Handle loaded state - update our cached lists
        if (state is CustomQuotesLoaded) {
          final quotes = state.quotes;
          
          // Update the appropriate list based on which tab we're in and the state
          if (state.isUserQuotes && isMyQuotes) {
            // Only replace if not paginating
            _userQuotes.clear();
            _userQuotes.addAll(quotes);
            _hasReachedEnd = state.hasReachedEnd;
          } else if (!state.isUserQuotes && !isMyQuotes) {
            // Only replace if not paginating
            _communityQuotes.clear();
            _communityQuotes.addAll(quotes);
            _hasReachedEnd = state.hasReachedEnd;
          }
          
          // Use the appropriate list
          final displayQuotes = isMyQuotes ? _userQuotes : _communityQuotes;
          
          if (displayQuotes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isMyQuotes ? Icons.format_quote_outlined : Icons.public,
                    size: 64,
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isMyQuotes 
                        ? 'You haven\'t created any quotes yet'
                        : 'No community quotes available',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (isMyQuotes)
                    ElevatedButton.icon(
                      onPressed: () => _navigateToCreateQuote(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Create Your First Quote'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }
          
          return _buildQuotesListView(
            quotes: displayQuotes,
            isMyQuotes: isMyQuotes,
          );
        }
        
        // Handle error state
        if (state is CustomQuotesError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: ${state.message}',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (isMyQuotes) {
                      context.read<CustomQuotesBloc>().add(
                        const LoadUserCustomQuotesEvent(refresh: true)
                      );
                    } else {
                      context.read<CustomQuotesBloc>().add(
                        const LoadPublicCustomQuotesEvent(refresh: true)
                      );
                    }
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }
        
        // Handle deleted state
        if (state is CustomQuoteDeleted && isMyQuotes) {
          // Remove the deleted quote from the list
          final deletedId = state.quoteId;
          _userQuotes.removeWhere((quote) => quote.id == deletedId);
          
          // If the list is empty after deletion, show empty state
          if (_userQuotes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.format_quote_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You haven\'t created any quotes yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToCreateQuote(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Your First Quote'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          
          return _buildQuotesListView(
            quotes: _userQuotes,
            isMyQuotes: true,
          );
        }
        
        // Initial state - trigger loading if needed
        if ((isMyQuotes && _userQuotes.isEmpty) || (!isMyQuotes && _communityQuotes.isEmpty)) {
          // Only load if we don't have data yet
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (isMyQuotes) {
              context.read<CustomQuotesBloc>().add(const LoadUserCustomQuotesEvent());
            } else {
              context.read<CustomQuotesBloc>().add(const LoadPublicCustomQuotesEvent());
            }
          });
          return _buildShimmerLoading();
        }
        
        // Use cached quotes if we have them
        final quotes = isMyQuotes ? _userQuotes : _communityQuotes;
        return _buildQuotesListView(
          quotes: quotes,
          isMyQuotes: isMyQuotes,
        );
      },
    );
  }
  
  Widget _buildQuotesListView({
    required List<CustomQuoteModel> quotes,
    required bool isMyQuotes,
  }) {
    // Using a NotificationListener to detect scroll position for pagination
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!_isLoadingMore && 
            !_hasReachedEnd && 
            scrollInfo.metrics.pixels > scrollInfo.metrics.maxScrollExtent - 200) {
          _isLoadingMore = true;
          
          // Load next batch of quotes
          if (isMyQuotes && _userQuotes.isNotEmpty) {
            context.read<CustomQuotesBloc>().add(
              LoadUserCustomQuotesEvent(lastQuote: _userQuotes.last)
            );
          } else if (!isMyQuotes && _communityQuotes.isNotEmpty) {
            context.read<CustomQuotesBloc>().add(
              LoadPublicCustomQuotesEvent(lastQuote: _communityQuotes.last)
            );
          }
          
          _isLoadingMore = false;
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          if (isMyQuotes) {
            context.read<CustomQuotesBloc>().add(
              const LoadUserCustomQuotesEvent(refresh: true)
            );
          } else {
            context.read<CustomQuotesBloc>().add(
              const LoadPublicCustomQuotesEvent(refresh: true)
            );
          }
        },
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: quotes.length + 1, // +1 for the loading indicator
          itemBuilder: (context, index) {
            // Show loading indicator at the end if more items can be loaded
            if (index == quotes.length) {
              return _hasReachedEnd 
                  ? const SizedBox() 
                  : const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
            }
            
            final quote = quotes[index];
            return _buildQuoteCard(context, quote, isMyQuotes);
          },
        ),
      ),
    );
  }
  
  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).brightness == Brightness.dark 
            ? Colors.grey[800]! 
            : Colors.grey[300]!,
        highlightColor: Theme.of(context).brightness == Brightness.dark 
            ? Colors.grey[700]! 
            : Colors.grey[100]!,
        child: ListView.builder(
          itemCount: 5,  // Show 5 shimmer items while loading
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildShimmerQuoteCard(),
          ),
        ),
      ),
    );
  }
  
  Widget _buildShimmerQuoteCard() {
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
            // Quote content placeholder
            Container(
              width: double.infinity,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            
            // Author and mood placeholders
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 100,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: 60,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Date and actions placeholders
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuoteCard(
    BuildContext context, 
    CustomQuoteModel quote, 
    bool isMyQuote,
  ) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    final formattedDate = DateFormat('MMM d, yyyy')
        .format(quote.createdAt.toDate());
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.baseRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quote content
            Text(
              '"${quote.content}"',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            
            // Author and mood
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '- ${quote.author}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    quote.mood,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white : Colors.white,
                    ),
                  ),
                  backgroundColor: isDarkMode
                      ? AppConstants.accentColorDark
                      : AppConstants.accentColor,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Date and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
                if (isMyQuote)
                  Row(
                    children: [
                      // Edit button
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () => _navigateToEditQuote(context, quote),
                        color: theme.colorScheme.primary,
                        tooltip: 'Edit quote',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 16),
                      
                      // Visibility toggle button
                      IconButton(
                        icon: Icon(
                          quote.isPublic
                              ? Icons.public
                              : Icons.public_off,
                          size: 20,
                        ),
                        onPressed: () => _toggleQuoteVisibility(context, quote),
                        color: quote.isPublic
                            ? Colors.green
                            : theme.colorScheme.onBackground.withOpacity(0.6),
                        tooltip: quote.isPublic
                            ? 'Public - Click to make private'
                            : 'Private - Click to make public',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 16),
                      
                      // Delete button
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () => _showDeleteConfirmation(context, quote),
                        color: Colors.red,
                        tooltip: 'Delete quote',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _navigateToCreateQuote(BuildContext context) {
    NavigationUtils.navigateToCreateQuote(context);
  }
  
  void _navigateToEditQuote(BuildContext context, CustomQuoteModel quote) {
    NavigationUtils.navigateToEditQuote(context, quote);
  }
  
  void _toggleQuoteVisibility(BuildContext context, CustomQuoteModel quote) {
    context.read<CustomQuotesBloc>().add(ToggleQuotePublicStatusEvent(quote.id));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          quote.isPublic
              ? 'Quote is now private'
              : 'Quote is now public and visible to other users',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.baseRadius),
        ),
      ),
    );
  }
  
  void _showDeleteConfirmation(BuildContext context, CustomQuoteModel quote) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quote'),
        content: const Text(
          'Are you sure you want to delete this quote? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CustomQuotesBloc>().add(DeleteCustomQuoteEvent(quote.id));
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Quote deleted'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.baseRadius),
                  ),
                ),
              );
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.baseRadius),
        ),
      ),
    );
  }
}