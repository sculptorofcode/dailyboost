import 'package:dailyboost/core/navigation/navigation_utils.dart';
import 'package:dailyboost/core/utils/constants.dart';
import 'package:dailyboost/features/auth/logic/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final authProvider = Provider.of<UserAuthProvider>(
          context,
          listen: false,
        );
        await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        // If we get here, login was successful
        if (mounted) {
          NavigationUtils.navigateToHome(context); // Navigate to home screen
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  // Handle Google Sign In
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<UserAuthProvider>(
        context,
        listen: false,
      );
      final user = await authProvider.signInWithGoogle();

      if (user != null && mounted) {
        NavigationUtils.navigateToHome(context); // Navigate to home screen
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  // Handle Skip/Guest mode
  void _skipLogin() {
    final authProvider = Provider.of<UserAuthProvider>(context, listen: false);

    authProvider.enableGuestMode();
    NavigationUtils.navigateToHome(context); // Navigate to home screen
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App logo or icon
                  Icon(
                    Icons.local_fire_department_rounded,
                    size: 80,
                    color:
                        isDarkMode
                            ? AppConstants.primaryColorDark
                            : AppConstants.primaryColor,
                  ),
                  const SizedBox(height: 16),

                  // App name
                  Text(
                    AppConstants.appName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color:
                          isDarkMode
                              ? AppConstants.textColorDark
                              : AppConstants.textColor,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Error message if any
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (_errorMessage != null) const SizedBox(height: 20),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Forgot password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        NavigationUtils.navigateToForgotPassword(context);
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color:
                              isDarkMode
                                  ? AppConstants.accentColorDark
                                  : AppConstants.accentColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Login button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDarkMode
                              ? AppConstants.primaryColorDark
                              : AppConstants.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                  ),
                  const SizedBox(height: 20),

                  // OR divider
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color:
                              isDarkMode
                                  ? AppConstants.textColorDark.withOpacity(0.3)
                                  : AppConstants.textColor.withOpacity(0.3),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color:
                                isDarkMode
                                    ? AppConstants.textColorDark.withOpacity(
                                      0.5,
                                    )
                                    : AppConstants.textColor.withOpacity(0.5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color:
                              isDarkMode
                                  ? AppConstants.textColorDark.withOpacity(0.3)
                                  : AppConstants.textColor.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Google Sign in button
                  OutlinedButton.icon(
                    onPressed: _isGoogleLoading ? null : _signInWithGoogle,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color:
                            isDarkMode
                                ? AppConstants.textColorDark.withOpacity(0.5)
                                : Colors.grey.shade400,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon:
                        _isGoogleLoading
                            ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDarkMode
                                      ? AppConstants.textColorDark
                                      : AppConstants.textColor,
                                ),
                              ),
                            )
                            : Image.asset(
                              'assets/icons/google_logo.png',
                              height: 20,
                              width: 20,
                              errorBuilder:
                                  (context, _, __) =>
                                      const Icon(Icons.g_mobiledata),
                            ),
                    label: const Text(
                      'Sign in with Google',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Skip button (Guest mode)
                  TextButton(
                    onPressed: _skipLogin,
                    child: Text(
                      'Skip (Continue as Guest)',
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            isDarkMode
                                ? AppConstants.textColorDark.withOpacity(0.7)
                                : AppConstants.textColor.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sign up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color:
                              isDarkMode
                                  ? AppConstants.textColorDark.withOpacity(0.7)
                                  : AppConstants.textColor.withOpacity(0.7),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          NavigationUtils.navigateToSignup(context);
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                isDarkMode
                                    ? AppConstants.accentColorDark
                                    : AppConstants.accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
