import 'package:flutter/material.dart';
import '../../core/utils/constants.dart';

class ExitConfirmationWrapper extends StatefulWidget {
  final Widget child;

  const ExitConfirmationWrapper({
    super.key,
    required this.child,
  });

  @override
  State<ExitConfirmationWrapper> createState() => _ExitConfirmationWrapperState();
}

class _ExitConfirmationWrapperState extends State<ExitConfirmationWrapper> {
  DateTime? _lastTimeBackButtonWasClicked;
  
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        
        _handleBackButton(context);
      },
      child: widget.child,
    );
  }
  
  void _handleBackButton(BuildContext context) {
    // If this is the first back button press or more than 2 seconds have passed
    if (_lastTimeBackButtonWasClicked == null || 
        DateTime.now().difference(_lastTimeBackButtonWasClicked!) > const Duration(seconds: 2)) {
      
      // Update the last time back button was clicked
      setState(() {
        _lastTimeBackButtonWasClicked = DateTime.now();
      });

      // Show a toast message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Press back again to exit'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.baseRadius),
            ),
          ),
        );
      }
    } else {
      // This is the second tap within 2 seconds - actually exit the app
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}