import 'package:flutter/material.dart';
import 'api_service.dart';

class ProfileCompletionService {
  // Get profile completion status
  static Future<Map<String, dynamic>?> getProfileCompletionStatus() async {
    try {
      final response = await ApiService.get('/profile/completion');
      final data = ApiService.parseResponse(response);
      
      return data['data'];
    } catch (e) {
      print('Error getting profile completion: $e');
      return null;
    }
  }
  
  // Calculate completion percentage and next step
  static Map<String, dynamic> calculateCompletion(Map<String, dynamic>? completionData) {
    if (completionData == null) {
      return {
        'percentage': 0,
        'completed_sections': 0,
        'total_sections': 4,
        'next_step': 'Profil Personal',
        'next_route': '/profil-personal',
        'is_complete': false,
        'sections': {
          'profile': false,
          'family': false,
          'economic': false,
          'social': false,
        }
      };
    }
    
    final sections = completionData['sections'] ?? {};
    final bool hasProfile = sections['profile'] ?? false;
    final bool hasFamily = sections['family'] ?? false;
    final bool hasEconomic = sections['economic'] ?? false;
    final bool hasSocial = sections['social'] ?? false;
    
    int completedSections = 0;
    if (hasProfile) completedSections++;
    if (hasFamily) completedSections++;
    if (hasEconomic) completedSections++;
    if (hasSocial) completedSections++;
    
    String nextStep = 'Profil Personal';
    String nextRoute = '/profil-personal';
    
    if (!hasProfile) {
      nextStep = 'Profil Personal';
      nextRoute = '/profil-personal';
    } else if (!hasFamily) {
      nextStep = 'Data Keluarga';
      nextRoute = '/data-keluarga';
    } else if (!hasEconomic) {
      nextStep = 'Data Ekonomi';
      nextRoute = '/data-ekonomi';
    } else if (!hasSocial) {
      nextStep = 'Data Sosial';
      nextRoute = '/data-sosial';
    }
    
    return {
      'percentage': (completedSections / 4 * 100).round(),
      'completed_sections': completedSections,
      'total_sections': 4,
      'next_step': nextStep,
      'next_route': nextRoute,
      'is_complete': completedSections == 4,
      'sections': {
        'profile': hasProfile,
        'family': hasFamily,
        'economic': hasEconomic,
        'social': hasSocial,
      }
    };
  }
  
  // Get completion color based on percentage
  static Map<String, dynamic> getCompletionColor(int percentage) {
    if (percentage >= 100) {
      return {
        'primary': const Color(0xFF10B981), // Green
        'secondary': const Color(0xFF059669),
        'background': const Color(0xFFECFDF5),
        'text': const Color(0xFF065F46),
      };
    } else if (percentage >= 75) {
      return {
        'primary': const Color(0xFF3B82F6), // Blue
        'secondary': const Color(0xFF2563EB),
        'background': const Color(0xFFEFF6FF),
        'text': const Color(0xFF1E40AF),
      };
    } else if (percentage >= 50) {
      return {
        'primary': const Color(0xFFF59E0B), // Yellow
        'secondary': const Color(0xFFD97706),
        'background': const Color(0xFFFEF3C7),
        'text': const Color(0xFF92400E),
      };
    } else {
      return {
        'primary': const Color(0xFFEF4444), // Red
        'secondary': const Color(0xFFDC2626),
        'background': const Color(0xFFFEF2F2),
        'text': const Color(0xFF991B1B),
      };
    }
  }
  
  // Get completion message
  static String getCompletionMessage(int percentage) {
    if (percentage >= 100) {
      return 'Selamat! Profil Anda sudah lengkap dengan data personal, keluarga, ekonomi, dan sosial. Sekarang Anda dapat mengakses semua fitur aplikasi dan mengajukan bantuan sosial.';
    } else if (percentage >= 75) {
      return 'Profil hampir lengkap! Sedikit lagi untuk menyelesaikan semua data.';
    } else if (percentage >= 50) {
      return 'Profil sudah setengah jalan! Lanjutkan untuk melengkapi data Anda.';
    } else if (percentage > 0) {
      return 'Profil baru sedikit terisi. Mari lengkapi data Anda untuk pengalaman yang lebih baik.';
    } else {
      return 'Profil belum diisi sama sekali. Mulai lengkapi data Anda sekarang!';
    }
  }
}