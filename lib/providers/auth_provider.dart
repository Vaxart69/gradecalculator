import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../api/auth_api.dart';
import '../models/user.dart' as model;

class AuthProvider with ChangeNotifier {
  final FirebaseAuthAPI _authApi = FirebaseAuthAPI();

  User? _firebaseUser;
  model.User? _appUser;

  // Expose Firebase user and app user
  User? get firebaseUser => _firebaseUser;
  model.User? get appUser => _appUser;
  bool _isLoading = true;
bool get isLoading => _isLoading;

  // Listen to auth state changes
  AuthProvider() {
    _isLoading = true;
    _authApi.getUser().listen((user) async {
      _firebaseUser = user;
      if (user != null) {
        _appUser = await _authApi.getUserInfo(user.uid);
      } else {
        _appUser = null;
      }

      _isLoading = false;
      notifyListeners();
    });
  }

  // Sign in
  Future<String?> signIn(String email, String password) async {
    final result = await _authApi.signIn(email, password);
    if (result == null && _firebaseUser != null) {
      _appUser = await _authApi.getUserInfo(_firebaseUser!.uid);
      notifyListeners();
    }
    return result;
  }

  // Sign up
  Future<String?> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String username,
  }) async {
    final result = await _authApi.signUp(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      username: username,
    );
    if (result == null && _firebaseUser != null) {
      _appUser = await _authApi.getUserInfo(_firebaseUser!.uid);
      notifyListeners();
    }
    return result;
  }

  // Sign out
  Future<void> signOut() async {
    await _authApi.signOut();
    _firebaseUser = null;
    _appUser = null;
    notifyListeners();
  }

  // Update user info
  Future<String?> updateUserInfo(Map<String, dynamic> updatedData) async {
    if (_firebaseUser == null) return "No user signed in";
    final result = await _authApi.updateUserInfo(_firebaseUser!.uid, updatedData);
    if (result == null) {
      _appUser = await _authApi.getUserInfo(_firebaseUser!.uid);
      notifyListeners();
    }
    return result;
  }
}