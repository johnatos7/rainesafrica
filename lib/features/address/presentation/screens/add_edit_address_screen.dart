import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/domain/entities/address_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/presentation/providers/address_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/presentation/widgets/address_form_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/domain/usecases/manage_address_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/providers/auth_provider.dart';

class AddEditAddressScreen extends ConsumerStatefulWidget {
  final AddressEntity? address;
  final Function(AddressEntity)? onAddressSaved;
  final String? redirectPath;

  const AddEditAddressScreen({
    super.key,
    this.address,
    this.onAddressSaved,
    this.redirectPath,
  });

  @override
  ConsumerState<AddEditAddressScreen> createState() =>
      _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends ConsumerState<AddEditAddressScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _countriesLoaded = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      // Load countries first
      await ref.read(countriesProvider.future);
      setState(() {
        _countriesLoaded = true;
      });

      // Then load address data if editing
      if (widget.address != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(addressFormProvider.notifier)
              .loadFromAddress(widget.address!);
        });
      }

      _animationController.forward();
    } catch (e) {
      // Handle country loading error
      if (mounted) {
        _showErrorSnackBar('Failed to load countries: $e');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: _buildAppBar(theme),
      body: _buildBody(theme, isDark),
    );
  }

  AppBar _buildAppBar(ThemeData theme) {
    return AppBar(
      title: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _countriesLoaded ? 1.0 : 0.0,
        child: Text(
          widget.address != null ? 'Edit Address' : 'Add New Address',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: theme.colorScheme.onPrimary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        onPressed: () {
          _handleCancel();
        },
      ),
      actions: [
        if (_isLoading)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(theme.colorScheme.onPrimary),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBody(ThemeData theme, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient:
            isDark
                ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.05),
                    Colors.grey[900]!,
                  ],
                )
                : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.03),
                    Colors.grey[50]!,
                  ],
                ),
      ),
      child: SafeArea(
        child:
            !_countriesLoaded
                ? _buildLoadingCountriesState(theme)
                : _isLoading
                ? _buildSavingState(theme)
                : _buildContent(theme),
      ),
    );
  }

  Widget _buildLoadingCountriesState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.primary.withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                  strokeWidth: 3,
                ),
                Icon(
                  Icons.public_rounded,
                  size: 35,
                  color: theme.colorScheme.primary.withOpacity(0.7),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading Countries...',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Preparing address form',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 120,
            child: LinearProgressIndicator(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                  strokeWidth: 3,
                ),
                Icon(
                  Icons.location_on_rounded,
                  size: 30,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.address != null
                ? 'Updating Address...'
                : 'Saving Address...',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Form Card
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AddressFormWidget(
                      initialAddress: widget.address,
                      submitButtonText:
                          widget.address != null
                              ? 'Update Address'
                              : 'Save Address',
                      onSaved: _handleSave,
                      onCancel: _handleCancel,
                    ),
                  ),
                ),

                // Additional Info
                const SizedBox(height: 20),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 600),
                  opacity: _countriesLoaded ? 1.0 : 0.0,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 600),
                    offset:
                        _countriesLoaded ? Offset.zero : const Offset(0, 0.5),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your address information is securely stored and only used for delivery purposes.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                              ),
                            ),
                          ),
                        ],
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

  void _handleSave() async {
    print('DEBUG: _handleSave called');
    if (_isLoading) {
      print('DEBUG: Already loading, returning');
      return;
    }

    // Validate form before saving
    print('DEBUG: Validating form...');
    final formNotifier = ref.read(addressFormProvider.notifier);
    final formData = ref.read(addressFormProvider);
    print('DEBUG: Form data for validation: $formData');
    print('DEBUG: isValid check: ${formData.isValid}');
    print('DEBUG: Validation errors: ${formData.validationErrors}');

    if (!formNotifier.validateForm()) {
      print('DEBUG: Form validation failed');
      _showErrorSnackBar('Please fill all required fields correctly');
      return;
    }
    print('DEBUG: Form validation passed');

    setState(() {
      _isLoading = true;
    });
    print('DEBUG: Set loading to true');

    try {
      print('DEBUG: Getting form data...');
      final formData = ref.read(addressFormProvider);
      print('DEBUG: Form data retrieved: $formData');

      if (widget.address != null) {
        print('DEBUG: Updating existing address...');
        final updateUseCase = ref.read(updateAddressUseCaseProvider);
        print('DEBUG: Calling update use case...');
        final result = await updateUseCase.execute(
          widget.address!.id,
          formData,
        );
        print('DEBUG: Update use case completed');

        result.fold(
          (failure) {
            print('DEBUG: Update failed: ${failure.message}');
            _showErrorSnackBar(failure.message);
          },
          (success) {
            print('DEBUG: Update successful');
            // Update in-memory user addresses immediately for all consumers
            ref.read(authProvider.notifier).addOrReplaceAddress(success);
            ref.read(refreshUserAddressesProvider)();
            _showSuccessSnackBar('Address updated successfully');
            widget.onAddressSaved?.call(success);
            if (widget.redirectPath != null &&
                widget.redirectPath!.isNotEmpty) {
              context.go(widget.redirectPath!);
            } else {
              Navigator.of(context).pop(success);
            }
          },
        );
      } else {
        print('DEBUG: Creating new address...');
        final createUseCase = ref.read(createAddressUseCaseProvider);
        print('DEBUG: Calling create use case...');
        final result = await createUseCase.execute(formData);
        print('DEBUG: Create use case completed');

        result.fold(
          (failure) {
            print('DEBUG: Create failed: ${failure.message}');
            _showErrorSnackBar(failure.message);
          },
          (success) {
            print('DEBUG: Create successful');
            // Update in-memory user addresses immediately for all consumers
            ref.read(authProvider.notifier).addOrReplaceAddress(success);
            ref.read(refreshUserAddressesProvider)();
            _showSuccessSnackBar('Address added successfully');
            widget.onAddressSaved?.call(success);
            if (widget.redirectPath != null &&
                widget.redirectPath!.isNotEmpty) {
              context.go(widget.redirectPath!);
            } else {
              Navigator.of(context).pop(success);
            }
          },
        );
      }
    } catch (e) {
      print('DEBUG: Exception caught: $e');
      // Reload user data as per login
      print('DEBUG: Reloading user data due to error...');
      await ref.read(authProvider.notifier).reloadUser();
      _showErrorSnackBar('Failed to save address: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleCancel() {
    // Show confirmation dialog if there are unsaved changes
    final formNotifier = ref.read(addressFormProvider.notifier);
    if (formNotifier.hasChanges()) {
      _showCancelConfirmationDialog();
    } else {
      formNotifier.reset();
      Navigator.of(context).pop();
    }
  }

  void _showCancelConfirmationDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Unsaved Changes',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'You have unsaved changes. Are you sure you want to discard them?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  ref.read(addressFormProvider.notifier).reset();
                  Navigator.of(context)
                    ..pop()
                    ..pop();
                },
                child: Text('Discard', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
