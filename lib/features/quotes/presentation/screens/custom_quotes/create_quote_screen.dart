import 'package:dailyboost/core/navigation/navigation_utils.dart';
import 'package:dailyboost/core/utils/constants.dart';
import 'package:dailyboost/features/quotes/data/models/custom_quote_model.dart';
import 'package:dailyboost/features/quotes/logic/bloc/custom_quotes/custom_quotes_bloc.dart';
import 'package:dailyboost/features/quotes/logic/bloc/custom_quotes/custom_quotes_event.dart';
import 'package:dailyboost/features/quotes/logic/bloc/custom_quotes/custom_quotes_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateQuoteScreen extends StatefulWidget {
  final bool isEditing;
  final CustomQuoteModel? quote;

  const CreateQuoteScreen({
    super.key,
    required this.isEditing,
    this.quote,
  });

  @override
  State<CreateQuoteScreen> createState() => _CreateQuoteScreenState();
}

class _CreateQuoteScreenState extends State<CreateQuoteScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _contentController;
  late final TextEditingController _authorController;
  late String _selectedMood;
  late bool _isPublic;
  bool _isSubmitting = false;
  
  // List of predefined moods with their associated icons
  final List<Map<String, dynamic>> _moods = [
    {'name': 'Motivational', 'icon': Icons.emoji_events, 'color': Colors.amber},
    {'name': 'Inspirational', 'icon': Icons.lightbulb, 'color': Colors.yellow},
    {'name': 'Happy', 'icon': Icons.sentiment_very_satisfied, 'color': Colors.green},
    {'name': 'Reflective', 'icon': Icons.beach_access, 'color': Colors.blue},
    {'name': 'Hopeful', 'icon': Icons.wb_sunny, 'color': Colors.orange},
    {'name': 'Calm', 'icon': Icons.spa, 'color': Colors.teal},
    {'name': 'Focus', 'icon': Icons.center_focus_strong, 'color': Colors.indigo},
    {'name': 'Wisdom', 'icon': Icons.psychology, 'color': Colors.purple},
    {'name': 'Success', 'icon': Icons.star, 'color': Colors.deepOrange},
    {'name': 'Gratitude', 'icon': Icons.favorite, 'color': Colors.pink},
    {'name': 'Love', 'icon': Icons.favorite_border, 'color': Colors.red},
    {'name': 'Friendship', 'icon': Icons.people, 'color': Colors.cyan},
    {'name': 'Other', 'icon': Icons.more_horiz, 'color': Colors.grey},
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers and values
    _contentController = TextEditingController(
      text: widget.isEditing ? widget.quote?.content ?? '' : '',
    );
    _authorController = TextEditingController(
      text: widget.isEditing ? widget.quote?.author ?? '' : '',
    );
    _selectedMood = widget.isEditing 
        ? widget.quote?.mood ?? _moods.first['name'] 
        : _moods.first['name'];
    _isPublic = widget.isEditing 
        ? widget.quote?.isPublic ?? false 
        : false;
  }

  @override
  void dispose() {
    _contentController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // Call this method whenever you need to print the stack
    // For debugging purposes, you might call this in initState or when specific events occur

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Quote' : 'Create Quote',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => NavigationUtils.navigateToCustomQuotes(context),
        ),
      ),
      body: BlocListener<CustomQuotesBloc, CustomQuotesState>(
        listener: (context, state) {
          if (state is CustomQuoteCreated || state is CustomQuoteUpdated) {
            setState(() => _isSubmitting = false);
            
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(widget.isEditing ? 'Quote updated' : 'Quote created'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.baseRadius),
                ),
              ),
            );
            
            // Refresh quotes list and navigate back
            context.read<CustomQuotesBloc>().add(LoadUserCustomQuotesEvent());
            NavigationUtils.navigateToCustomQuotes(context);
          } else if (state is CustomQuotesError) {
            setState(() => _isSubmitting = false);
            
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.baseRadius),
                ),
              ),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quote content input
                TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: 'Quote Text',
                    hintText: 'Enter your quote here',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.baseRadius),
                    ),
                    prefixIcon: const Icon(Icons.format_quote),
                  ),
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter some text';
                    }
                    if (value.length < 3) {
                      return 'Quote is too short';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                
                // Author input
                TextFormField(
                  controller: _authorController,
                  decoration: InputDecoration(
                    labelText: 'Author',
                    hintText: 'Who said this quote?',
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.baseRadius),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an author';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                
                // Mood selection - Visual chips with icons instead of dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Mood',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDarkMode 
                              ? Colors.grey.shade700 
                              : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(AppConstants.baseRadius),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _moods.map((mood) {
                          final bool isSelected = _selectedMood == mood['name'];
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedMood = mood['name'];
                              });
                            },
                            borderRadius: BorderRadius.circular(AppConstants.baseRadius),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? (isDarkMode 
                                        ? mood['color'].withOpacity(0.3) 
                                        : mood['color'].withOpacity(0.2))
                                    : isDarkMode 
                                        ? Colors.grey.shade800 
                                        : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(AppConstants.baseRadius),
                                border: Border.all(
                                  color: isSelected 
                                      ? mood['color'] 
                                      : isDarkMode 
                                          ? Colors.grey.shade700 
                                          : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    mood['icon'],
                                    size: 20,
                                    color: isSelected 
                                        ? mood['color']
                                        : isDarkMode 
                                            ? Colors.grey.shade400 
                                            : Colors.grey.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    mood['name'],
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected 
                                          ? isDarkMode 
                                              ? mood['color'].withOpacity(0.9) 
                                              : mood['color'].shade800
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Public/private toggle
                SwitchListTile(
                  title: const Text('Make this quote public'),
                  subtitle: const Text(
                    'Public quotes are visible to all app users in the community section',
                  ),
                  value: _isPublic,
                  onChanged: (value) => setState(() => _isPublic = value),
                  activeColor: isDarkMode
                      ? AppConstants.primaryColorDark
                      : AppConstants.primaryColor,
                ),
                const SizedBox(height: 32),
                
                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode
                          ? AppConstants.primaryColorDark
                          : AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.baseRadius),
                      ),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            widget.isEditing ? 'UPDATE QUOTE' : 'CREATE QUOTE',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _submitForm() {
    // Validate form
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    
    setState(() => _isSubmitting = true);
    
    if (widget.isEditing && widget.quote != null) {
      // Update existing quote
      final updatedQuote = widget.quote!.copyWith(
        content: _contentController.text.trim(),
        author: _authorController.text.trim(),
        mood: _selectedMood,
        isPublic: _isPublic,
      );
      
      context.read<CustomQuotesBloc>().add(UpdateCustomQuoteEvent(updatedQuote));
    } else {
      // Create new quote
      context.read<CustomQuotesBloc>().add(
        CreateCustomQuoteEvent(
          content: _contentController.text.trim(),
          author: _authorController.text.trim(),
          mood: _selectedMood,
          isPublic: _isPublic,
        ),
      );
    }
  }
}