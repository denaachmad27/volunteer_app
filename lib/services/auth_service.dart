import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'google_sign_in_service.dart';
import 'api_service.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final int? anggotaLegislatifId;
  final String? phone;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.anggotaLegislatifId,
    this.phone,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      anggotaLegislatifId: json['anggota_legislatif_id'],
      phone: json['phone'],
      emailVerifiedAt: json['email_verified_at'] != null 
          ? DateTime.parse(json['email_verified_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'anggota_legislatif_id': anggotaLegislatifId,
      'phone': phone,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isAdminAleg => role == 'admin_aleg';
  bool get isUser => role == 'user';
}

class AuthResponse {
  final bool success;
  final String? message;
  final User? user;
  final String? token;

  AuthResponse({
    required this.success,
    this.message,
    this.user,
    this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['status'] == 'success',
      message: json['message'],
      user: json['data']?['user'] != null 
          ? User.fromJson(json['data']['user'])
          : null,
      token: json['data']?['token'],
    );
  }
}

class AuthService {
  // Login user
  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      final data = ApiService.parseResponse(response);
      final authResponse = AuthResponse.fromJson(data);

      if (authResponse.success && authResponse.token != null) {
        // Save token and user data
        await _saveAuthData(authResponse.token!, authResponse.user!);
      }

      return authResponse;
    } catch (e) {
      return AuthResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  // Register user
  static Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    required String anggotaLegislatifId,
  }) async {
    try {
      final Map<String, dynamic> requestData = {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      };
      
      // Add phone if provided
      if (phone != null && phone.isNotEmpty) {
        requestData['phone'] = phone;
      }
      
      // Add anggota_legislatif_id - now required
      requestData['anggota_legislatif_id'] = int.parse(anggotaLegislatifId);
      
      final response = await ApiService.post('/auth/register', requestData);

      final data = ApiService.parseResponse(response);
      final authResponse = AuthResponse.fromJson(data);

      if (authResponse.success && authResponse.token != null) {
        // Save token and user data
        await _saveAuthData(authResponse.token!, authResponse.user!);
      }

      return authResponse;
    } catch (e) {
      return AuthResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  // Get current user
  static Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user');
      
      if (userData != null) {
        return User.fromJson(jsonDecode(userData));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await ApiService.getToken();
    if (token == null) return false;

    // Verify token is still valid by calling backend
    try {
      final response = await ApiService.get('/auth/me');
      final data = ApiService.parseResponse(response);

      if (data['status'] == 'success' && data['user'] != null) {
        // Token is valid, update user data
        final user = User.fromJson(data['user']);
        await _saveUser(user);
        return true;
      }

      // Token invalid, clear auth data
      await _clearAuthData();
      return false;
    } catch (e) {
      // Token invalid or network error, clear auth data
      await _clearAuthData();
      return false;
    }
  }

  // Logout user
  static Future<bool> logout() async {
    try {
      // Call logout API if token exists
      final token = await ApiService.getToken();
      if (token != null) {
        try {
          await ApiService.post('/auth/logout', {});
        } catch (e) {
          // Ignore API errors during logout, just clear local data
        }
      }

      // IMPORTANT: Sign out from Firebase Auth and Google Sign-In
      // This ensures that cached credentials are cleared
      try {
        await FirebaseAuth.instance.signOut();
        await GoogleSignInService.signOut();
      } catch (e) {
        // Ignore errors, continue with clearing local data
      }

      // Clear local storage
      await _clearAuthData();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Refresh user data from API
  static Future<User?> refreshUser() async {
    try {
      final response = await ApiService.get('/auth/me');
      final data = ApiService.parseResponse(response);
      
      if (data['status'] == 'success' && data['user'] != null) {
        final user = User.fromJson(data['user']);
        await _saveUser(user);
        return user;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Save authentication data
  static Future<void> _saveAuthData(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user', jsonEncode(user.toJson()));
  }

  // Save user data only
  static Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
  }

  // Clear authentication data
  static Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  // Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate password strength
  static String? validatePassword(String password) {
    if (password.length < 8) {
      return 'Password minimal 8 karakter';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password harus mengandung huruf besar';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password harus mengandung huruf kecil';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password harus mengandung angka';
    }
    return null;
  }

  // Get anggota legislatif options for dropdown
  static Future<Map<String, dynamic>> getAnggotaLegislatifOptions() async {
    try {
      print('Fetching anggota legislatif options from API...');
      final response = await ApiService.get('/anggota-legislatif/options');
      final parsedResponse = ApiService.parseResponse(response);
      print('Anggota legislatif options response: $parsedResponse');
      return parsedResponse;
    } catch (e) {
      print('Error in getAnggotaLegislatifOptions: $e');
      throw Exception('Gagal memuat daftar anggota legislatif: $e');
    }
  }
}