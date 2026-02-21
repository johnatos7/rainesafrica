import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/app_utils.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String? redirectPath;

  const LoginScreen({super.key, this.redirectPath});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _hasSetUpListener = false;

  void _watchAuthStateAndNavigate() {
    print('🔵 LOGIN SCREEN: Watching auth state for navigation');

    // Watch auth state and navigate once it's properly updated
    ref.listen(authProvider, (previous, next) {
      if (!mounted) {
        print('🔴 LOGIN SCREEN: Widget not mounted during auth state watch');
        return;
      }

      print(
        '🔵 LOGIN SCREEN: Auth state changed - isAuthenticated: ${next.isAuthenticated}',
      );

      if (next.isAuthenticated) {
        print('🟢 LOGIN SCREEN: Auth state is now authenticated, navigating');

        final redirectPath = widget.redirectPath;
        print('🔵 LOGIN SCREEN: Redirect path: ${redirectPath ?? "null"}');

        if (redirectPath != null && redirectPath.isNotEmpty) {
          print('🔵 LOGIN SCREEN: Navigating to redirect path: $redirectPath');
          context.go(redirectPath);
          print('🟢 LOGIN SCREEN: Navigated to redirect path');
        } else {
          print('🔵 LOGIN SCREEN: No redirect path, navigating to home');
          context.go(AppConstants.homeRoute);
          print('🟢 LOGIN SCREEN: Navigated to home route');
        }
      }
    });
  }

  void _handleSuccessfulLogin() {
    print('🔵 LOGIN SCREEN: Handling successful login navigation');

    final redirectPath = widget.redirectPath;
    print('🔵 LOGIN SCREEN: Redirect path: ${redirectPath ?? "null"}');

    if (redirectPath != null && redirectPath.isNotEmpty) {
      print('🔵 LOGIN SCREEN: Navigating to redirect path: $redirectPath');
      context.go(redirectPath);
      print('🟢 LOGIN SCREEN: Navigated to redirect path');
    } else {
      print('🔵 LOGIN SCREEN: No redirect path, navigating to home');
      context.go(AppConstants.homeRoute);
      print('🟢 LOGIN SCREEN: Navigated to home route');
    }
  }

  @override
  void initState() {
    super.initState();
    print(
      '🔵 LOGIN SCREEN: Initialized with redirectPath: ${widget.redirectPath}',
    );
    // Router will handle redirect automatically when auth state changes
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    print('🔵 LOGIN SCREEN: _login() called');

    if (!_formKey.currentState!.validate()) {
      print('🔴 LOGIN SCREEN: Form validation failed');
      return;
    }

    print('🔵 LOGIN SCREEN: Form validation passed');

    // Close keyboard
    FocusScope.of(context).unfocus();

    // Set loading state
    setState(() {
      _isLoading = true;
    });
    print('🔵 LOGIN SCREEN: Loading state set to true');

    try {
      // Get email and password
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      print(
        '🔵 LOGIN SCREEN: Email: $email, Password: ${password.length} chars',
      );

      // Call login method from auth provider
      print('🔵 LOGIN SCREEN: Calling authProvider.createEmailSession()');
      final success = await ref
          .read(authProvider.notifier)
          .createEmailSession(email: email, password: password);

      print('🔵 LOGIN SCREEN: Auth provider login result: $success');

      if (!mounted) {
        print('🔴 LOGIN SCREEN: Widget not mounted, returning');
        return;
      }

      if (success) {
        print('🟢 LOGIN SCREEN: Login successful, showing success message');
        print('🔵 LOGIN SCREEN: Redirect path: ${widget.redirectPath}');
        // Show success message
        AppUtils.showSnackBar(
          context,
          message: 'Login successful!',
          backgroundColor: Theme.of(context).colorScheme.primary,
        );

        // Manually trigger navigation after successful login
        print('🔵 LOGIN SCREEN: Manually triggering navigation...');
        _handleSuccessfulLogin();
      } else {
        print('🔴 LOGIN SCREEN: Login failed, showing error message');
        // Show error message if login failed
        final authState = ref.read(authProvider);
        AppUtils.showSnackBar(
          context,
          message:
              'Login failed: Please check your email and password and try again.',
          backgroundColor: Theme.of(context).colorScheme.error,
        );
        // Reset loading state on failure
        setState(() {
          _isLoading = false;
        });
        print('🔵 LOGIN SCREEN: Loading state reset to false');
      }
    } catch (e) {
      print('🔴 LOGIN SCREEN: Exception caught: $e');
      if (!mounted) {
        print('🔴 LOGIN SCREEN: Widget not mounted after exception, returning');
        return;
      }

      AppUtils.showSnackBar(
        context,
        message:
            'Login failed: Please check your email and password and try again.',
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      // Reset loading state on error
      setState(() {
        _isLoading = false;
      });
      print('🔵 LOGIN SCREEN: Loading state reset to false after exception');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set up auth state listener only once to handle redirect after authentication
    if (!_hasSetUpListener) {
      _hasSetUpListener = true;
      _watchAuthStateAndNavigate();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              context.pop();
            } else {
              context.go(AppConstants.homeRoute);
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to your account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!AppUtils.isValidEmail(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        _showForgotPasswordDialog();
                      },
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text('Log In'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          final redirectPath = widget.redirectPath;
                          if (redirectPath != null && redirectPath.isNotEmpty) {
                            context.go(
                              '${AppConstants.registerRoute}?redirect=$redirectPath',
                            );
                          } else {
                            context.go(AppConstants.registerRoute);
                          }
                        },
                        child: const Text('Register'),
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

  void _showForgotPasswordDialog() {
    showDialog(context: context, builder: (context) => ForgotPasswordDialog());
  }
}

class ForgotPasswordDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<ForgotPasswordDialog> createState() =>
      _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends ConsumerState<ForgotPasswordDialog> {
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _currentStep = 0; // 0: Email, 1: Token, 2: New Password
  String _userEmail = '';
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
  }

  void _previousStep() {
    setState(() {
      _currentStep--;
    });
  }

  void _resetFlow() {
    setState(() {
      _currentStep = 0;
      _userEmail = '';
      _emailController.clear();
      _tokenController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  Future<void> _sendForgotPasswordEmail() async {
    if (_emailController.text.isEmpty) {
      AppUtils.showSnackBar(
        context,
        message: 'Please enter your email',
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      return;
    }

    final authNotifier = ref.read(authProvider.notifier);
    final result = await authNotifier.forgotPassword(
      email: _emailController.text.trim(),
    );

    if (result != null) {
      setState(() {
        _userEmail = _emailController.text.trim();
      });
      _nextStep();
      AppUtils.showSnackBar(
        context,
        message: 'Verification code sent to your email',
        backgroundColor: Theme.of(context).colorScheme.primary,
      );
    } else {
      final authState = ref.read(authProvider);
      AppUtils.showSnackBar(
        context,
        message: authState.errorMessage ?? 'Failed to send verification code',
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    }
  }

  Future<void> _verifyToken() async {
    if (_tokenController.text.isEmpty) {
      AppUtils.showSnackBar(
        context,
        message: 'Please enter the verification code',
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      return;
    }

    final authNotifier = ref.read(authProvider.notifier);
    final result = await authNotifier.verifyToken(
      email: _userEmail,
      token: _tokenController.text.trim(),
    );

    if (result != null) {
      _nextStep();
      AppUtils.showSnackBar(
        context,
        message: 'Verification code verified successfully',
        backgroundColor: Theme.of(context).colorScheme.primary,
      );
    } else {
      final authState = ref.read(authProvider);
      AppUtils.showSnackBar(
        context,
        message: authState.errorMessage ?? 'Invalid verification code',
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    }
  }

  Future<void> _updatePassword() async {
    if (_passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      AppUtils.showSnackBar(
        context,
        message: 'Please fill in all fields',
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      AppUtils.showSnackBar(
        context,
        message: 'Passwords do not match',
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      AppUtils.showSnackBar(
        context,
        message: 'Password must be at least 6 characters',
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      return;
    }

    final authNotifier = ref.read(authProvider.notifier);
    final result = await authNotifier.updatePassword(
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
      token: _tokenController.text.trim(),
      email: _userEmail,
    );

    if (result != null) {
      Navigator.of(context).pop();
      AppUtils.showSnackBar(
        context,
        message:
            'Password updated successfully! You can now login with your new password.',
        backgroundColor: Theme.of(context).colorScheme.primary,
      );
    } else {
      final authState = ref.read(authProvider);
      AppUtils.showSnackBar(
        context,
        message: authState.errorMessage ?? 'Failed to update password',
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AlertDialog(
      title: Text(
        _currentStep == 0
            ? 'Forgot Password'
            : _currentStep == 1
            ? 'Verify Code'
            : 'New Password',
        style: theme.textTheme.titleLarge?.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress indicator
            Row(
              children: [
                for (int i = 0; i < 3; i++)
                  Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                      decoration: BoxDecoration(
                        color:
                            i <= _currentStep ? colors.primary : colors.outline,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            if (_currentStep == 0) ...[
              Text(
                'Enter your email address and we\'ll send you a verification code.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: Icon(Icons.email_outlined, color: colors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ] else if (_currentStep == 1) ...[
              Text(
                'Enter the 5-digit verification code sent to $_userEmail',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _tokenController,
                keyboardType: TextInputType.number,
                maxLength: 5,
                decoration: InputDecoration(
                  labelText: 'Verification Code',
                  hintText: 'Enter 5-digit code',
                  prefixIcon: Icon(Icons.security, color: colors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  counterText: '',
                ),
              ),
            ] else if (_currentStep == 2) ...[
              Text(
                'Create a new password for your account.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  hintText: 'Enter new password',
                  prefixIcon: Icon(Icons.lock_outline, color: colors.primary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Confirm new password',
                  prefixIcon: Icon(Icons.lock_outline, color: colors.primary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (_currentStep > 0)
          TextButton(
            onPressed: _previousStep,
            child: Text(
              'Back',
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _resetFlow();
          },
          child: Text(
            'Cancel',
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
        ),
        ElevatedButton(
          onPressed:
              authState.isLoading
                  ? null
                  : () {
                    if (_currentStep == 0) {
                      _sendForgotPasswordEmail();
                    } else if (_currentStep == 1) {
                      _verifyToken();
                    } else if (_currentStep == 2) {
                      _updatePassword();
                    }
                  },
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child:
              authState.isLoading
                  ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colors.onPrimary,
                      ),
                    ),
                  )
                  : Text(
                    _currentStep == 0
                        ? 'Send Code'
                        : _currentStep == 1
                        ? 'Verify'
                        : 'Update Password',
                  ),
        ),
      ],
    );
  }
}
