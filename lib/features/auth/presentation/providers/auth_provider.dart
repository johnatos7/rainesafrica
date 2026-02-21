import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/secure_storage_service.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/domain/entities/address_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/usecases/login_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/usecases/logout_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/usecases/register_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/usecases/get_current_user_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/usecases/update_profile_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/usecases/forgot_password_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/usecases/verify_token_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/usecases/update_password_use_case.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

// Auth status enum
enum AuthStatus {
  uninitialized,
  unauthenticated,
  authenticated,
  authenticating,
}

// Auth state
class AuthState {
  final AuthStatus status;
  final bool loading;
  final UserEntity? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.uninitialized,
    this.loading = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    bool? loading,
    UserEntity? user,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      loading: loading ?? this.loading,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status.name,
      'loading': loading,
      'user': user?.toJson(),
      'error': error,
    };
  }

  // Convenience getters for backward compatibility
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => loading;
  String? get errorMessage => error;
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final RegisterUseCase _registerUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final VerifyTokenUseCase _verifyTokenUseCase;
  final UpdatePasswordUseCase _updatePasswordUseCase;
  final SecureStorageService _secureStorage;

  AuthNotifier({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required RegisterUseCase registerUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required ForgotPasswordUseCase forgotPasswordUseCase,
    required VerifyTokenUseCase verifyTokenUseCase,
    required UpdatePasswordUseCase updatePasswordUseCase,
    required GetCurrentUserUseCase
    getCurrentUserUseCase, // Keep parameter for backward compatibility
    required SecureStorageService secureStorage,
  }) : _loginUseCase = loginUseCase,
       _logoutUseCase = logoutUseCase,
       _registerUseCase = registerUseCase,
       _updateProfileUseCase = updateProfileUseCase,
       _forgotPasswordUseCase = forgotPasswordUseCase,
       _verifyTokenUseCase = verifyTokenUseCase,
       _updatePasswordUseCase = updatePasswordUseCase,
       _secureStorage = secureStorage,
       super(const AuthState()) {
    _getUser();
  }

  Future _getUser() async {
    try {
      state = state.copyWith(loading: true);
      // Try to get stored user data
      final userDataString = await _secureStorage.getUserData();
      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        final user = UserEntity.fromJson(userData);
        state = state.copyWith(
          user: user,
          loading: false,
          error: null,
          status: AuthStatus.authenticated,
        );
        developer.postEvent('appwrite_kit:authEvent', state.toMap());
        return;
      }
    } catch (e) {
      // If there's an error reading stored data, just continue as guest
    }

    // Set state as not authenticated but without error
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      error: null,
      user: null,
      loading: false,
    );
    developer.postEvent('appwrite_kit:authEvent', state.toMap());
  }

  // Address helpers: keep user addresses in sync after add/update
  void addOrReplaceAddress(AddressEntity address) {
    final currentUser = state.user;
    if (currentUser == null) return;

    final List<AddressEntity> updated = List<AddressEntity>.from(
      currentUser.address,
    );

    final index = updated.indexWhere((a) => a.id == address.id);
    if (index >= 0) {
      updated[index] = address;
    } else {
      updated.add(address);
    }

    final updatedUser = currentUser.copyWith(address: updated);
    state = state.copyWith(user: updatedUser);
    // Persist to storage so reload picks up the change
    _secureStorage.storeUserData(jsonEncode(updatedUser.toJson()));
  }

  // Reload user data
  Future<void> reloadUser() async {
    print('DEBUG: Reloading user data...');
    await _getUser();
    print('DEBUG: User reload completed');
  }

  Future<bool> createEmailSession({
    required String email,
    required String password,
    bool notify = true,
  }) async {
    state = state.copyWith(status: AuthStatus.authenticating, loading: true);

    try {
      final result = await _loginUseCase.execute(
        email: email,
        password: password,
      );

      return await result.fold(
        (failure) async {
          state = state.copyWith(
            status: AuthStatus.unauthenticated,
            loading: false,
            error: failure.message,
          );
          await _secureStorage.clearAll();
          return false;
        },
        (user) async {
          // Store user data first
          await _secureStorage.storeUserData(jsonEncode(user.toJson()));

          // Then update state
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            error: null,
            loading: false,
          );

          // Associate OneSignal user and set properties
          try {
            if (user.id.isNotEmpty) {
              OneSignal.login(user.id);
            }
            if (user.email.isNotEmpty) {
              OneSignal.User.addEmail(user.email);
            }
            final phoneStr = (user.phone ?? '').trim();
            if (phoneStr.isNotEmpty) {
              final cc = (user.countryCode ?? '').trim();
              final e164 =
                  phoneStr.startsWith('+') || cc.isEmpty
                      ? phoneStr
                      : '+$cc$phoneStr';
              OneSignal.User.addSms(e164);
            }
            if (user.name.isNotEmpty) {
              OneSignal.User.addTagWithKey("name", user.name);
            }
            if ((user.countryCode ?? '').isNotEmpty) {
              OneSignal.User.addTagWithKey("country_code", user.countryCode!);
            }
          } catch (e) {
            developer.log('OneSignal setup failed on login: $e');
          }
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        loading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<UserEntity?> create({
    required String email,
    required String password,
    required String countryCode,
    required int phone,
    bool notify = true,
    bool newSession = true,
    String? name,
  }) async {
    state = state.copyWith(status: AuthStatus.authenticating, loading: true);

    try {
      final result = await _registerUseCase.execute(
        name: name ?? '',
        email: email,
        password: password,
        countryCode: countryCode,
        phone: phone,
      );

      return await result.fold(
        (failure) async {
          state = state.copyWith(
            status: AuthStatus.unauthenticated,
            loading: false,
            error: failure.message,
          );
          return null;
        },
        (user) async {
          if (newSession) {
            await createEmailSession(email: email, password: password);
          }
          // If for some reason there is a user object already, attach to OneSignal
          try {
            if (user.id.isNotEmpty) {
              OneSignal.login(user.id);
            }
            if (user.email.isNotEmpty) {
              OneSignal.User.addEmail(user.email);
            }
            final phoneStr = (user.phone ?? '').trim();
            if (phoneStr.isNotEmpty) {
              final cc = (user.countryCode ?? '').trim();
              final e164 =
                  phoneStr.startsWith('+') || cc.isEmpty
                      ? phoneStr
                      : '+$cc$phoneStr';
              OneSignal.User.addSms(e164);
            }
            if (user.name.isNotEmpty) {
              OneSignal.User.addTagWithKey("name", user.name);
            }
            if ((user.countryCode ?? '').isNotEmpty) {
              OneSignal.User.addTagWithKey("country_code", user.countryCode!);
            }
          } catch (e) {
            developer.log('OneSignal setup failed on register: $e');
          }
          return user;
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        loading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  Future<bool> deleteSession({String sessionId = 'current'}) async {
    try {
      state = state.copyWith(loading: true);
      final result = await _logoutUseCase.execute();

      return await result.fold(
        (failure) async {
          state = state.copyWith(
            error: failure.message,
            user: null,
            loading: false,
          );
          return false;
        },
        (_) async {
          state = state.copyWith(
            error: null,
            status: AuthStatus.unauthenticated,
            loading: false,
            user: null,
          );
          await _secureStorage.clearAll();
          try {
            OneSignal.logout();
          } catch (e) {
            developer.log('OneSignal logout failed: $e');
          }
          developer.postEvent('appwrite_kit:authEvent', {
            "type": "deleteSession",
            "session": {"id": sessionId},
          });
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), user: null, loading: false);
      return false;
    }
  }

  Future<UserEntity?> updatePhone({
    required String number,
    required String password,
  }) async {
    try {
      // This would need to be implemented based on your backend API
      // For now, just return the current user
      return state.user;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<UserEntity?> updatePrefs({required Map<String, dynamic> prefs}) async {
    try {
      // This would need to be implemented based on your backend API
      // For now, just return the current user
      return state.user;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return null;
    }
  }

  // Update user profile
  Future<UserEntity?> updateProfile({
    required String name,
    required String email,
    required String countryCode,
    required int phone,
  }) async {
    state = state.copyWith(loading: true);

    try {
      final result = await _updateProfileUseCase.execute(
        name: name,
        email: email,
        countryCode: countryCode,
        phone: phone,
      );

      return await result.fold(
        (failure) async {
          state = state.copyWith(loading: false, error: failure.message);
          return null;
        },
        (user) async {
          // Store updated user data
          await _secureStorage.storeUserData(jsonEncode(user.toJson()));

          // Update state with new user data
          state = state.copyWith(user: user, error: null, loading: false);
          // Sync user info to OneSignal
          try {
            if (user.id.isNotEmpty) {
              OneSignal.login(user.id);
            }
            if (user.email.isNotEmpty) {
              OneSignal.User.addEmail(user.email);
            }
            final phoneStr = (user.phone ?? '').trim();
            if (phoneStr.isNotEmpty) {
              final cc = (user.countryCode ?? '').trim();
              final e164 =
                  phoneStr.startsWith('+') || cc.isEmpty
                      ? phoneStr
                      : '+$cc$phoneStr';
              OneSignal.User.addSms(e164);
            }
            if (user.name.isNotEmpty) {
              OneSignal.User.addTagWithKey("name", user.name);
            }
            if ((user.countryCode ?? '').isNotEmpty) {
              OneSignal.User.addTagWithKey("country_code", user.countryCode!);
            }
          } catch (e) {
            developer.log('OneSignal sync failed on profile update: $e');
          }
          return user;
        },
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return null;
    }
  }

  // Forgot password
  Future<Map<String, dynamic>?> forgotPassword({required String email}) async {
    state = state.copyWith(loading: true);

    try {
      final result = await _forgotPasswordUseCase.execute(email: email);

      return await result.fold(
        (failure) async {
          state = state.copyWith(loading: false, error: failure.message);
          return null;
        },
        (response) async {
          state = state.copyWith(error: null, loading: false);
          return response;
        },
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return null;
    }
  }

  // Verify token
  Future<Map<String, dynamic>?> verifyToken({
    required String email,
    required String token,
  }) async {
    state = state.copyWith(loading: true);

    try {
      final result = await _verifyTokenUseCase.execute(
        email: email,
        token: token,
      );

      return await result.fold(
        (failure) async {
          state = state.copyWith(loading: false, error: failure.message);
          return null;
        },
        (response) async {
          state = state.copyWith(error: null, loading: false);
          return response;
        },
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return null;
    }
  }

  // Update password
  Future<Map<String, dynamic>?> updatePassword({
    required String password,
    required String passwordConfirmation,
    required String token,
    required String email,
  }) async {
    state = state.copyWith(loading: true);

    try {
      final result = await _updatePasswordUseCase.execute(
        password: password,
        passwordConfirmation: passwordConfirmation,
        token: token,
        email: email,
      );

      return await result.fold(
        (failure) async {
          state = state.copyWith(loading: false, error: failure.message);
          return null;
        },
        (response) async {
          state = state.copyWith(error: null, loading: false);
          return response;
        },
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return null;
    }
  }
}

// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final loginUseCase = ref.read(loginUseCaseProvider);
  final logoutUseCase = ref.read(logoutUseCaseProvider);
  final registerUseCase = ref.read(registerUseCaseProvider);
  final updateProfileUseCase = ref.read(updateProfileUseCaseProvider);
  final forgotPasswordUseCase = ref.read(forgotPasswordUseCaseProvider);
  final verifyTokenUseCase = ref.read(verifyTokenUseCaseProvider);
  final updatePasswordUseCase = ref.read(updatePasswordUseCaseProvider);
  final getCurrentUserUseCase = ref.read(getCurrentUserUseCaseProvider);
  final secureStorage = ref.read(secureStorageProvider);

  return AuthNotifier(
    loginUseCase: loginUseCase,
    logoutUseCase: logoutUseCase,
    registerUseCase: registerUseCase,
    updateProfileUseCase: updateProfileUseCase,
    forgotPasswordUseCase: forgotPasswordUseCase,
    verifyTokenUseCase: verifyTokenUseCase,
    updatePasswordUseCase: updatePasswordUseCase,
    getCurrentUserUseCase: getCurrentUserUseCase,
    secureStorage: secureStorage,
  );
});
