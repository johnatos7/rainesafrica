import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/app_utils.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final String? redirectPath;

  const RegisterScreen({super.key, this.redirectPath});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  PhoneNumber? _phoneNumber;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    // Close keyboard
    FocusScope.of(context).unfocus();

    // Set loading state
    setState(() {
      _isLoading = true;
    });

    try {
      if (_phoneNumber == null) {
        AppUtils.showSnackBar(
          context,
          message: 'Please enter a valid phone number',
          backgroundColor: Theme.of(context).colorScheme.error,
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get form values
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final countryCode = _phoneNumber!.countryCode;
      final phone = int.parse(_phoneNumber!.nsn);

      // Call create method from auth provider
      final user = await ref
          .read(authProvider.notifier)
          .create(
            name: name,
            email: email, // Use the actual email from the form
            password: password,
            countryCode: countryCode,
            phone: phone,
          );

      final success = user != null;

      if (!mounted) return;

      if (success) {
        // Show success message
        AppUtils.showSnackBar(
          context,
          message: 'Registration successful!',
          backgroundColor: Theme.of(context).colorScheme.primary,
        );
        // On success, always redirect to login screen with redirect path
        final redirectPath = widget.redirectPath;
        print(
          '🔵 REGISTER SCREEN: Registration successful, redirecting to login',
        );
        if (redirectPath != null && redirectPath.isNotEmpty) {
          print(
            '🔵 REGISTER SCREEN: Passing redirect path to login: $redirectPath',
          );
          context.go('${AppConstants.loginRoute}?redirect=$redirectPath');
        } else {
          context.go(AppConstants.loginRoute);
        }
        print('🟢 REGISTER SCREEN: Redirected to login screen');
      } else {
        // Show error message if registration failed
        final authState = ref.read(authProvider);
        AppUtils.showSnackBar(
          context,
          message: authState.errorMessage ?? 'Registration failed',
          backgroundColor: Theme.of(context).colorScheme.error,
        );
        // Reset loading state on failure
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      AppUtils.showSnackBar(
        context,
        message: 'Registration failed: ${e.toString()}',
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      // Reset loading state on error
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
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
                    'Create your account',
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
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'Enter your full name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
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
                  PhoneFormField(
                    initialValue: PhoneNumber.parse('+263'),
                    validator: (PhoneNumber? phone) {
                      if (phone == null) {
                        return 'Phone number is required';
                      }
                      if (!phone.isValid()) {
                        return 'Please enter a valid mobile number';
                      }
                      return null;
                    },
                    countrySelectorNavigator:
                        const CountrySelectorNavigator.page(),
                    onChanged: (phoneNumber) {
                      setState(() {
                        _phoneNumber = phoneNumber;
                      });
                    },
                    enabled: true,
                    isCountrySelectionEnabled: true,
                    isCountryButtonPersistent: true,
                    countryButtonStyle: const CountryButtonStyle(
                      showDialCode: true,
                      showIsoCode: true,
                      showFlag: true,
                      flagSize: 16,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'Enter your phone number',
                    ),
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
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      hintText: 'Confirm your password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _register,
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
                            : const Text('Register'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
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
                              '${AppConstants.loginRoute}?redirect=$redirectPath',
                            );
                          } else {
                            context.go(AppConstants.loginRoute);
                          }
                        },
                        child: const Text('Login'),
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
