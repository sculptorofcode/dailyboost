import 'package:flutter/material.dart';
import '../../core/navigation/navigation_utils.dart';
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
      onPopInvoked: (didPop) async {
        // If already popped, no need to handle
        if (didPop) return;

        // Check if we're at the root route (home)
        // This is an approximation, may need to be adjusted based on your navigation structure
        final bool isHomeRoute = ModalRoute.of(context)?.settings.name == '/' || 
                                ModalRoute.of(context)?.settings.name == null;
        
        if (isHomeRoute) {
          // If this is the first back button press or more than 2 seconds have passed
          if (_lastTimeBackButtonWasClicked == null || 
              DateTime.now().difference(_lastTimeBackButtonWasClicked!) > const Duration(seconds: 2)) {
            
            // Update the last time back button was clicked
            setState(() {
              _lastTimeBackButtonWasClicked = DateTime.now();
            });

            // Show a toast message
            if (mounted && context.mounted) {
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
            
            // Don't exit the app
            return;
          }

          // If we reach here, this is the second tap within 2 seconds
          // Allow the app to exit
          if (mounted) {
            setState(() {
            });
            Navigator.of(context).pop();
          }
        } else {
          // Not on home route, try to go back in the navigation stack
          final navigator = Navigator.of(context);
          if (navigator.canPop()) {
            navigator.pop();
          } else {
            // If can't pop and not on home route, navigate to home
            NavigationUtils.navigateToHome(context);
          }
        }
      },
      child: widget.child,
    );
  }
}