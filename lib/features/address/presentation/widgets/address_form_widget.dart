import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/domain/entities/address_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/presentation/providers/address_providers.dart';

class AddressFormWidget extends ConsumerStatefulWidget {
  final AddressEntity? initialAddress;
  final VoidCallback? onSaved;
  final VoidCallback? onCancel;
  final String? submitButtonText;
  final String? cancelButtonText;
  final bool showCancelButton;

  const AddressFormWidget({
    super.key,
    this.initialAddress,
    this.onSaved,
    this.onCancel,
    this.submitButtonText,
    this.cancelButtonText,
    this.showCancelButton = true,
  });

  @override
  ConsumerState<AddressFormWidget> createState() => _AddressFormWidgetState();
}

class _AddressFormWidgetState extends ConsumerState<AddressFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController();
  final _stateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print('DEBUG: AddressFormWidget initState called');
    print('DEBUG: Initial address: ${widget.initialAddress}');
    if (widget.initialAddress != null) {
      print('DEBUG: Loading address data for editing');
      _loadAddressData(widget.initialAddress!);
    } else {
      print('DEBUG: Creating new address - no initial data');
    }
  }

  void _loadAddressData(AddressEntity address) {
    print('DEBUG: _loadAddressData called with address: $address');
    _titleController.text = address.title;
    _streetController.text = address.street;
    _cityController.text = address.city;
    _pincodeController.text = address.pincode ?? '';
    _phoneController.text = address.phone.toString();
    _countryController.text = address.country?.name ?? '';
    _stateController.text = address.state?.name ?? '';

    print('DEBUG: Controllers populated:');
    print('  Title: "${_titleController.text}"');
    print('  Street: "${_streetController.text}"');
    print('  City: "${_cityController.text}"');
    print('  Pincode: "${_pincodeController.text}"');
    print('  Phone: "${_phoneController.text}"');
    print('  Country: "${_countryController.text}"');
    print('  State: "${_stateController.text}"');

    ref.read(addressFormProvider.notifier).loadFromAddress(address);
    print('DEBUG: Address form provider updated');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formData = ref.watch(addressFormProvider);
    final countriesAsync = ref.watch(countriesProvider);

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Wrap(
          spacing: 10,
          runSpacing: 5,
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Address Title',
                hintText: 'e.g., Home, Office, etc.',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                print('DEBUG: Title field changed to: "$value"');
                ref.read(addressFormProvider.notifier).updateTitle(value);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an address title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Street Address Field
            TextFormField(
              controller: _streetController,
              decoration: const InputDecoration(
                labelText: 'Street Address',
                hintText: 'Enter your street address',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (value) {
                print('DEBUG: Street field changed to: "$value"');
                ref.read(addressFormProvider.notifier).updateStreet(value);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your street address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // City Field
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'City',
                hintText: 'Enter your city',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                print('DEBUG: City field changed to: "$value"');
                ref.read(addressFormProvider.notifier).updateCity(value);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your city';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Postal Code Field
            TextFormField(
              controller: _pincodeController,
              decoration: const InputDecoration(
                labelText: 'Postal Code',
                hintText: 'Enter your postal code',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                print('DEBUG: Postal code field changed to: "$value"');
                ref
                    .read(addressFormProvider.notifier)
                    .updatePincode(value.isEmpty ? null : value);
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your postal code';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Country Selection
            countriesAsync.when(
              data:
                  (countries) => TextFormField(
                    controller: _countryController,
                    decoration: const InputDecoration(
                      labelText: 'Country',
                      hintText: 'Select your country',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                    readOnly: true,
                    onTap: _onCountryTextFieldTap,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a country';
                      }
                      return null;
                    },
                  ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error loading countries: $error'),
            ),
            const SizedBox(height: 16),

            // State Selection
            if (formData.countryId > 0)
              countriesAsync.when(
                data: (countries) {
                  final countryIndex = countries.indexWhere(
                    (country) => country.id == formData.countryId,
                  );

                  if (countryIndex == -1) {
                    return const SizedBox.shrink();
                  }

                  final selectedCountry = countries[countryIndex];

                  if (selectedCountry.states.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return TextFormField(
                    controller: _stateController,
                    decoration: const InputDecoration(
                      labelText: 'State/Province',
                      hintText: 'Select your state/province',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                    readOnly: true,
                    onTap: _onStateTextFieldTap,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a state/province';
                      }
                      return null;
                    },
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => const SizedBox.shrink(),
              ),
            const SizedBox(height: 16),

            // Phone Number Field
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter your phone number',
                border: const OutlineInputBorder(),
                prefixText:
                    formData.countryId > 0
                        ? '+${countriesAsync.value?.where((c) => c.id == formData.countryId).firstOrNull?.callingCode ?? ''} '
                        : '+',
              ),
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                print('DEBUG: Phone field changed to: "$value"');
                ref.read(addressFormProvider.notifier).updatePhone(value);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  if (widget.showCancelButton) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onCancel,
                        child: Text(widget.cancelButtonText ?? 'Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleSubmit,
                      child: Text(widget.submitButtonText ?? 'Save Address'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    final formData = ref.read(addressFormProvider);

    // DEBUG: Print all form data properties
    print('=== DEBUG: Form Submit Started ===');
    print('Form data type: ${formData.runtimeType}');
    print('Form data: $formData');
    print('Title: "${formData.title}"');
    print('Street: "${formData.street}"');
    print('City: "${formData.city}"');
    print('Pincode: "${formData.pincode}"');
    print('Phone: "${formData.phone}"');
    print('Country ID: ${formData.countryId}');
    print('State ID: ${formData.stateId}');
    print('Country Code: "${formData.countryCode}"');
    print('Type: ${formData.type}');

    // Check if country is selected
    if (formData.countryId <= 0) {
      print(
        'DEBUG: Country validation failed - countryId: ${formData.countryId}',
      );
      _showErrorSnackBar('Please select a country');
      return;
    }
    print('DEBUG: Country validation passed');

    // Check if state is selected (if country has states)
    final countriesAsync = ref.read(countriesProvider);
    countriesAsync.whenData((countries) {
      final countryIndex = countries.indexWhere(
        (country) => country.id == formData.countryId,
      );

      if (countryIndex != -1) {
        final selectedCountry = countries[countryIndex];
        if (selectedCountry.states.isNotEmpty && formData.stateId <= 0) {
          _showErrorSnackBar('Please select a state/province');
          return;
        }
      }

      // Validate individual fields
      print('DEBUG: Starting field validation...');

      print(
        'DEBUG: Checking street - value: "${formData.street}", trimmed: "${formData.street.trim()}", isEmpty: ${formData.street.trim().isEmpty}',
      );
      if (formData.street.trim().isEmpty) {
        print('DEBUG: Street validation FAILED');
        _showErrorSnackBar('Please enter your street address');
        return;
      }
      print('DEBUG: Street validation PASSED');

      print(
        'DEBUG: Checking city - value: "${formData.city}", trimmed: "${formData.city.trim()}", isEmpty: ${formData.city.trim().isEmpty}',
      );
      if (formData.city.trim().isEmpty) {
        print('DEBUG: City validation FAILED');
        _showErrorSnackBar('Please enter your city');
        return;
      }
      print('DEBUG: City validation PASSED');

      print(
        'DEBUG: Checking postal code - value: "${formData.pincode}", isNull: ${formData.pincode == null}, trimmed: "${formData.pincode?.trim()}", isEmpty: ${formData.pincode?.trim().isEmpty ?? true}',
      );
      if (formData.pincode?.trim().isEmpty ?? true) {
        print('DEBUG: Postal code validation FAILED');
        _showErrorSnackBar('Please enter your postal code');
        return;
      }
      print('DEBUG: Postal code validation PASSED');

      print(
        'DEBUG: Checking phone - value: "${formData.phone}", trimmed: "${formData.phone.trim()}", isEmpty: ${formData.phone.trim().isEmpty}',
      );
      if (formData.phone.trim().isEmpty) {
        print('DEBUG: Phone validation FAILED');
        _showErrorSnackBar('Please enter your phone number');
        return;
      }
      print('DEBUG: Phone validation PASSED');
      print('DEBUG: All validations completed successfully!');
      print('DEBUG: Calling onSaved callback...');

      // If all validations pass, call the save callback
      widget.onSaved?.call();

      print('DEBUG: onSaved callback completed');
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
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

  /// Handles the text field tap for the country
  void _onCountryTextFieldTap() {
    print('DEBUG: _onCountryTextFieldTap called');
    final countriesAsync = ref.read(countriesProvider);
    print('DEBUG: Countries provider state: $countriesAsync');
    countriesAsync.whenData((countries) {
      print('DEBUG: Countries loaded: ${countries.length} countries');

      // Prioritize certain countries
      List<String> priorityCountries = ["Zimbabwe", "Zambia", "South Africa"];

      // Separate countries into priority and remaining
      List<CountryEntity> priorityList = [];
      List<CountryEntity> remainingList = [];

      for (var country in countries) {
        if (priorityCountries.contains(country.name)) {
          priorityList.add(country);
        } else {
          remainingList.add(country);
        }
      }

      // Sort remaining countries alphabetically
      remainingList.sort((a, b) => a.name.compareTo(b.name));

      // Combine priority + remaining
      List<CountryEntity> finalCountriesList = [
        ...priorityList,
        ...remainingList,
      ];

      final List<SelectedListItem<CountryEntity>> countryList =
          finalCountriesList
              .map((country) => SelectedListItem<CountryEntity>(data: country))
              .toList();
      print(
        'DEBUG: Country list created with ${countryList.length} items (prioritized)',
      );

      DropDownState<CountryEntity>(
        dropDown: DropDown<CountryEntity>(
          isDismissible: true,
          bottomSheetTitle: const Text(
            'Select Country',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
          ),
          submitButtonText: 'Select',
          clearButtonText: 'Clear',
          data: countryList,
          listItemBuilder: (index, dataItem) {
            return Row(children: [Expanded(child: Text(dataItem.data.name))]);
          },
          onSelected: (selectedItems) {
            print('DEBUG: Country selection callback triggered');
            print('DEBUG: Selected items count: ${selectedItems.length}');
            if (selectedItems.isNotEmpty) {
              final selectedCountry = selectedItems.first.data;
              print(
                'DEBUG: Selected country: ${selectedCountry.name} (ID: ${selectedCountry.id})',
              );
              _countryController.text = selectedCountry.name;
              print(
                'DEBUG: Country controller text set to: "${_countryController.text}"',
              );
              ref
                  .read(addressFormProvider.notifier)
                  .updateCountry(selectedCountry.id);
              // Update country code when country is selected
              ref
                  .read(addressFormProvider.notifier)
                  .updateCountryCode(selectedCountry.callingCode ?? '');
              // Reset state when country changes
              ref.read(addressFormProvider.notifier).updateState(0);
              _stateController.clear();
              print('DEBUG: Country ID set to: ${selectedCountry.id}');
              print(
                'DEBUG: Country code set to: ${selectedCountry.callingCode}',
              );
              print('DEBUG: State reset and cleared');
            } else {
              print('DEBUG: No country selected');
            }
          },
          searchDelegate: (query, dataItems) {
            return dataItems
                .where(
                  (item) => item.data.name.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
                )
                .toList();
          },
        ),
      ).showModal(context);
    });
  }

  /// Handles the text field tap for the state
  void _onStateTextFieldTap() {
    print('DEBUG: _onStateTextFieldTap called');
    final formData = ref.read(addressFormProvider);
    print('DEBUG: Current form data country ID: ${formData.countryId}');
    if (formData.countryId <= 0) {
      print('DEBUG: No country selected, showing error message');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a country first')),
      );
      return;
    }

    // Get states from the selected country
    print('DEBUG: Getting countries to find states');
    final countriesAsync = ref.read(countriesProvider);
    countriesAsync.whenData((countries) {
      print('DEBUG: Countries loaded for state selection: ${countries.length}');
      final countryIndex = countries.indexWhere(
        (country) => country.id == formData.countryId,
      );
      print('DEBUG: Country index found: $countryIndex');

      if (countryIndex == -1) {
        print('DEBUG: Country not found in list');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Country not found')));
        return;
      }

      final selectedCountry = countries[countryIndex];
      print('DEBUG: Selected country: ${selectedCountry.name}');
      print('DEBUG: States available: ${selectedCountry.states.length}');

      if (selectedCountry.states.isEmpty) {
        print('DEBUG: No states available for this country');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No states available for this country')),
        );
        return;
      }

      final List<SelectedListItem<StateEntity>> stateList =
          selectedCountry.states
              .map((state) => SelectedListItem<StateEntity>(data: state))
              .toList();
      print('DEBUG: State list created with ${stateList.length} states');

      DropDownState<StateEntity>(
        dropDown: DropDown<StateEntity>(
          isDismissible: true,
          bottomSheetTitle: const Text(
            'Select State/Province',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
          ),
          submitButtonText: 'Select',
          clearButtonText: 'Clear',
          data: stateList,
          listItemBuilder: (index, dataItem) {
            return Text(dataItem.data.name);
          },
          onSelected: (selectedItems) {
            print('DEBUG: State selection callback triggered');
            print('DEBUG: Selected items count: ${selectedItems.length}');
            if (selectedItems.isNotEmpty) {
              final selectedState = selectedItems.first.data;
              print(
                'DEBUG: Selected state: ${selectedState.name} (ID: ${selectedState.id})',
              );
              _stateController.text = selectedState.name;
              print(
                'DEBUG: State controller text set to: "${_stateController.text}"',
              );
              ref
                  .read(addressFormProvider.notifier)
                  .updateState(selectedState.id);
              print('DEBUG: State ID updated in form provider');
            } else {
              print('DEBUG: No state selected');
            }
          },
          searchDelegate: (query, dataItems) {
            return dataItems
                .where(
                  (item) => item.data.name.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
                )
                .toList();
          },
        ),
      ).showModal(context);
    });
  }
}
