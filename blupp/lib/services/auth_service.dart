import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  AuthService() {
    // Initialize from current session, and listen for changes
    _supabase.auth.onAuthStateChange.listen((data) {
      notifyListeners();
    });
  }

  bool get isAuthenticated => _supabase.auth.currentSession != null;

  Future<String?> login(String email, String password) async {
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
      return null; // null means success
    } on AuthException catch (e) {
      return e.message; // return error message to show in UI
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }

  Future<String?> register(String email, String password) async {
    try {
      await _supabase.auth.signUp(email: email, password: password);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  Future<void> authenticatePin(String pin) async {
    // TODO: Implement actual PIN authentication
    if (kDebugMode) {
      print('Authenticating with PIN: $pin');
    }
  }
}