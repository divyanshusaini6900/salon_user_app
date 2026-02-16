import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import '../../app/firebase_bootstrap.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.phone,
    required this.dob,
    required this.address,
    required this.email,
    required this.biometricEnabled,
  });

  final String uid;
  final String name;
  final String phone;
  final String dob;
  final String address;
  final String email;
  final bool biometricEnabled;

  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      dob: data['dob'] as String? ?? '',
      address: data['address'] as String? ?? '',
      email: data['email'] as String? ?? '',
      biometricEnabled: data['biometricEnabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'dob': dob,
      'address': address,
      'email': email,
      'biometricEnabled': biometricEnabled,
    };
  }
}

class AuthState {
  const AuthState({
    required this.isAuthenticated,
    this.profile,
    this.isLoading = false,
    this.error,
  });

  final bool isAuthenticated;
  final UserProfile? profile;
  final bool isLoading;
  final String? error;

  AuthState copyWith({
    bool? isAuthenticated,
    UserProfile? profile,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._firestore, this._auth)
      : _storage = const FlutterSecureStorage(),
        _localAuth = LocalAuthentication(),
        super(const AuthState(isAuthenticated: false)) {
    final auth = _auth;
    if (FirebaseBootstrap.enableFirebase && auth != null) {
      _sub = auth.authStateChanges().listen(_handleAuthChange);
    }
  }

  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;
  final FlutterSecureStorage _storage;
  final LocalAuthentication _localAuth;
  StreamSubscription<User?>? _sub;

  Future<void> _handleAuthChange(User? user) async {
    if (!FirebaseBootstrap.enableFirebase) return;
    if (user == null) {
      state = const AuthState(isAuthenticated: false);
      return;
    }
    final store = _firestore;
    if (store == null) return;
    final doc = await store.collection('users').doc(user.uid).get();
    if (doc.exists) {
      state = AuthState(isAuthenticated: true, profile: UserProfile.fromMap(user.uid, doc.data()!));
    } else {
      state = AuthState(isAuthenticated: true, profile: UserProfile(
        uid: user.uid,
        name: '',
        phone: '',
        dob: '',
        address: '',
        email: user.email ?? '',
        biometricEnabled: false,
      ));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String dob,
    required String address,
    required bool enableBiometric,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    if (!FirebaseBootstrap.enableFirebase) {
      state = AuthState(
        isAuthenticated: true,
        profile: UserProfile(
          uid: 'demo',
          name: name,
          phone: phone,
          dob: dob,
          address: address,
          email: email,
          biometricEnabled: enableBiometric,
        ),
      );
      return;
    }

    try {
      final auth = _auth;
      if (auth == null) return;
      final cred = await auth.createUserWithEmailAndPassword(email: email, password: password);
      final profile = UserProfile(
        uid: cred.user!.uid,
        name: name,
        phone: phone,
        dob: dob,
        address: address,
        email: email,
        biometricEnabled: enableBiometric,
      );
      if (_firestore != null) {
        await _firestore.collection('users').doc(profile.uid).set(profile.toMap());
      }
      if (enableBiometric) {
        await _storage.write(key: _passwordKey(email), value: password);
        await _saveBiometricEmail(email);
      }
      state = AuthState(isAuthenticated: true, profile: profile);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> loginWithPassword({
    required String email,
    required String password,
    required bool rememberForBiometric,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    if (!FirebaseBootstrap.enableFirebase) {
      state = AuthState(
        isAuthenticated: true,
        profile: UserProfile(
          uid: 'demo',
          name: 'Demo User',
          phone: '',
          dob: '',
          address: '',
          email: email,
          biometricEnabled: rememberForBiometric,
        ),
      );
      return;
    }

    try {
      final auth = _auth;
      if (auth == null) return;
      await auth.signInWithEmailAndPassword(email: email, password: password);
      if (rememberForBiometric) {
        await _storage.write(key: _passwordKey(email), value: password);
        await _saveBiometricEmail(email);
      }
      state = state.copyWith(isLoading: false);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> loginWithBiometric({required String email}) async {
    state = state.copyWith(isLoading: true, error: null);
    if (kIsWeb) {
      state = state.copyWith(isLoading: false, error: 'Biometric login not supported on web.');
      return;
    }

    if (!FirebaseBootstrap.enableFirebase) {
      state = state.copyWith(isLoading: false, error: 'Firebase disabled.');
      return;
    }

    final enabled = await _isBiometricEnabledForEmail(email);
    if (!enabled) {
      state = state.copyWith(isLoading: false, error: 'Biometric not enabled for this email on this device.');
      return;
    }

    final storedPassword = await _storage.read(key: _passwordKey(email));
    if (storedPassword == null) {
      state = state.copyWith(isLoading: false, error: 'Biometric not enabled for this email on this device.');
      return;
    }

    final canCheck = await _localAuth.canCheckBiometrics;
    final isSupported = await _localAuth.isDeviceSupported();
    if (!canCheck || !isSupported) {
      state = state.copyWith(isLoading: false, error: 'Biometrics not available on this device.');
      return;
    }

    final ok = await _localAuth.authenticate(
      localizedReason: 'Verify your identity to login',
      options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
    );

    if (!ok) {
      state = state.copyWith(isLoading: false, error: 'Biometric authentication failed.');
      return;
    }

    final auth = _auth;
    if (auth == null) return;
    await auth.signInWithEmailAndPassword(email: email, password: storedPassword);
    state = state.copyWith(isLoading: false);
  }

  Future<void> signOut() async {
    final auth = _auth;
    if (FirebaseBootstrap.enableFirebase && auth != null) {
      await auth.signOut();
    }
    state = const AuthState(isAuthenticated: false);
  }

  String _passwordKey(String email) => 'pwd_${email.toLowerCase()}';
  String _biometricEmailsKey() => 'biometric_emails';
  
  Future<List<String>> _loadBiometricEmails() async {
    final raw = await _storage.read(key: _biometricEmailsKey());
    if (raw == null || raw.isEmpty) return [];
    return raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  Future<void> _saveBiometricEmail(String email) async {
    final lower = email.toLowerCase();
    final emails = await _loadBiometricEmails();
    if (!emails.contains(lower)) {
      emails.add(lower);
    }
    await _storage.write(key: _biometricEmailsKey(), value: emails.join(','));
  }

  Future<bool> _isBiometricEnabledForEmail(String email) async {
    final emails = await _loadBiometricEmails();
    return emails.contains(email.toLowerCase());
  }

  Future<void> setBiometricEnabled({required String email, required bool enabled, String? password}) async {
    final lower = email.toLowerCase();
    if (enabled) {
      if (password == null || password.isEmpty) {
        state = state.copyWith(error: 'Password required to enable biometric.');
        return;
      }
      await _storage.write(key: _passwordKey(lower), value: password);
      await _saveBiometricEmail(lower);
    } else {
      final emails = await _loadBiometricEmails();
      emails.remove(lower);
      await _storage.write(key: _biometricEmailsKey(), value: emails.join(','));
      await _storage.delete(key: _passwordKey(lower));
    }
  }

  Future<bool> isBiometricEnabledForEmail(String email) async {
    return _isBiometricEnabledForEmail(email);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final enabled = FirebaseBootstrap.enableFirebase;
  final firestore = enabled ? FirebaseFirestore.instance : null;
  final auth = enabled ? FirebaseAuth.instance : null;
  return AuthController(firestore, auth);
});

final authStatusProvider = Provider<bool>((ref) {
  return ref.watch(authControllerProvider).isAuthenticated;
});
