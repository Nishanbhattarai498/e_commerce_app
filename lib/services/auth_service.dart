import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';
import 'supabase_service.dart';

class AuthService extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  Profile? _profile;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  Profile? get profile => _profile;
  bool get isAuthenticated => _supabaseService.isAuthenticated;
  User? get currentUser => _supabaseService.currentUser;

  Future<void> initialize() async {
    _setLoading(true);
    try {
      if (_supabaseService.isAuthenticated) {
        await _fetchProfile();
      }
    } catch (e) {
      debugPrint('Error initializing auth service: $e');
    } finally {
      _setLoading(false);
    }

    // Listen for auth state changes
    _supabaseService.authStateChanges.listen((event) async {
      if (event.event == AuthChangeEvent.signedIn) {
        await _fetchProfile();
      } else if (event.event == AuthChangeEvent.signedOut) {
        _profile = null;
        notifyListeners();
      }
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    _setLoading(true);
    try {
      final response = await _supabaseService.signUp(
        email: email,
        password: password,
        userData: {
          'first_name': firstName ?? '',
          'last_name': lastName ?? '',
        },
      );

      if (response.user != null) {
        await _fetchProfile();
      }
    } catch (e) {
      debugPrint('Error signing up: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final response = await _supabaseService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _fetchProfile();
      }
    } catch (e) {
      debugPrint('Error signing in: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _supabaseService.signOut();
      _profile = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetPassword(String email) async {
    _setLoading(true);
    try {
      await _supabaseService.resetPassword(email);
    } catch (e) {
      debugPrint('Error resetting password: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendEmailOtp({
    required String email,
    bool shouldCreateUser = false,
    String? firstName,
    String? lastName,
  }) async {
    _setLoading(true);
    try {
      final metadata = <String, dynamic>{};
      if (firstName != null && firstName.isNotEmpty) {
        metadata['first_name'] = firstName;
      }
      if (lastName != null && lastName.isNotEmpty) {
        metadata['last_name'] = lastName;
      }

      await _supabaseService.sendEmailOtp(
        email: email,
        shouldCreateUser: shouldCreateUser,
        data: metadata.isEmpty ? null : metadata,
      );
    } catch (e) {
      debugPrint('Error sending email OTP: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    _setLoading(true);
    try {
      final response = await _supabaseService.verifyEmailOtp(
        email: email,
        token: token,
      );

      if (response.user != null) {
        await _fetchProfile();
      }
    } catch (e) {
      debugPrint('Error verifying email OTP: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
  }) async {
    if (_profile == null) return;

    _setLoading(true);
    try {
      final updatedProfile = _profile!.copyWith(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        avatarUrl: avatarUrl,
      );

      await _supabaseService.client.from('profiles').update({
        'first_name': updatedProfile.firstName,
        'last_name': updatedProfile.lastName,
        'phone': updatedProfile.phone,
        'avatar_url': updatedProfile.avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', _profile!.id);

      _profile = updatedProfile;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _fetchProfile() async {
    if (!_supabaseService.isAuthenticated) return;

    try {
      final response = await _supabaseService.client
          .from('profiles')
          .select()
          .eq('id', _supabaseService.currentUser!.id)
          .single();

      _profile = Profile.fromJson(response);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
