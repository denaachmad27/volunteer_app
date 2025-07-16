import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';

class FamilyService {
  // Get all family members
  static Future<List<Map<String, dynamic>>> getFamilyMembers() async {
    try {
      final response = await ApiService.get('/family');
      final data = ApiService.parseResponse(response);
      
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } catch (e) {
      print('Error getting family members: $e');
      throw Exception('Gagal mengambil data keluarga: $e');
    }
  }
  
  // Add new family member
  static Future<Map<String, dynamic>> addFamilyMember({
    required String namaAnggota,
    required String hubungan,
    required String jenisKelamin,
    required String tanggalLahir,
    required String pekerjaan,
    required String pendidikan,
    required double penghasilan,
    required bool tanggungan,
  }) async {
    try {
      final data = {
        'nama_anggota': namaAnggota,
        'hubungan': hubungan,
        'jenis_kelamin': jenisKelamin,
        'tanggal_lahir': tanggalLahir,
        'pekerjaan': pekerjaan,
        'pendidikan': pendidikan,
        'penghasilan': penghasilan,
        'tanggungan': tanggungan,
      };
      
      final response = await ApiService.post('/family', data);
      return ApiService.parseResponse(response);
    } catch (e) {
      print('Error adding family member: $e');
      throw Exception('Gagal menambah anggota keluarga: $e');
    }
  }
  
  // Update family member
  static Future<Map<String, dynamic>> updateFamilyMember({
    required int id,
    required String namaAnggota,
    required String hubungan,
    required String jenisKelamin,
    required String tanggalLahir,
    required String pekerjaan,
    required String pendidikan,
    required double penghasilan,
    required bool tanggungan,
  }) async {
    try {
      final data = {
        'nama_anggota': namaAnggota,
        'hubungan': hubungan,
        'jenis_kelamin': jenisKelamin,
        'tanggal_lahir': tanggalLahir,
        'pekerjaan': pekerjaan,
        'pendidikan': pendidikan,
        'penghasilan': penghasilan,
        'tanggungan': tanggungan,
      };
      
      final response = await ApiService.post('/family/$id', data);
      return ApiService.parseResponse(response);
    } catch (e) {
      print('Error updating family member: $e');
      throw Exception('Gagal mengupdate anggota keluarga: $e');
    }
  }
  
  // Delete family member
  static Future<Map<String, dynamic>> deleteFamilyMember(int id) async {
    try {
      // Using POST with DELETE method since some APIs handle it this way
      final response = await ApiService.post('/family/$id/delete', {});
      return ApiService.parseResponse(response);
    } catch (e) {
      print('Error deleting family member: $e');
      throw Exception('Gagal menghapus anggota keluarga: $e');
    }
  }
  
  // Get family statistics
  static Future<Map<String, dynamic>> getFamilyStatistics() async {
    try {
      final response = await ApiService.get('/family/statistics');
      final data = ApiService.parseResponse(response);
      
      return data['data'] ?? {};
    } catch (e) {
      print('Error getting family statistics: $e');
      throw Exception('Gagal mengambil statistik keluarga: $e');
    }
  }
  
  // Validation helpers
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName harus diisi';
    }
    return null;
  }
  
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tanggal lahir harus diisi';
    }
    
    try {
      final date = DateTime.parse(value);
      final now = DateTime.now();
      
      if (date.isAfter(now)) {
        return 'Tanggal lahir tidak boleh di masa depan';
      }
      
      return null;
    } catch (e) {
      return 'Format tanggal tidak valid';
    }
  }
  
  static String? validatePenghasilan(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Penghasilan harus diisi';
    }
    
    final penghasilan = parseCurrency(value);
    if (penghasilan < 0) {
      return 'Penghasilan tidak boleh negatif';
    }
    
    return null;
  }
  
  // Helper method to calculate age
  static int calculateAge(String birthDate) {
    try {
      final birth = DateTime.parse(birthDate);
      final now = DateTime.now();
      final age = now.difference(birth).inDays / 365.25;
      return age.floor();
    } catch (e) {
      return 0;
    }
  }
  
  // Format currency for display
  static String formatCurrency(double amount) {
    if (amount == 0) return 'Rp 0';
    
    final formatter = NumberFormat('#,###', 'id_ID');
    return 'Rp ${formatter.format(amount)}';
  }
  
  // Parse currency from string
  static double parseCurrency(String value) {
    if (value.isEmpty) return 0.0;
    
    // Remove currency symbols and keep only digits and separators
    String cleanValue = value.replaceAll(RegExp(r'[^\d,.]'), '');
    
    // Handle Indonesian format where dots are used as thousand separators
    // Example: "3.000.000" should become "3000000"
    // Remove all dots and commas as they are thousand separators
    cleanValue = cleanValue.replaceAll('.', '').replaceAll(',', '');
    
    final result = double.tryParse(cleanValue) ?? 0.0;
    print('Currency parsing: "$value" -> cleaned: "$cleanValue" -> result: $result');
    return result;
  }
  
  // Format date for display
  static String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      
      return '${date.day} ${months[date.month]} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }
  
  // Dropdown options
  static const List<String> hubunganOptions = [
    'Suami', 'Istri', 'Anak', 'Orang Tua', 'Saudara', 'Lainnya'
  ];
  
  static const List<String> jenisKelaminOptions = [
    'Laki-laki', 'Perempuan'
  ];
  
  static const List<String> pendidikanOptions = [
    'Tidak Sekolah', 'SD', 'SMP', 'SMA', 'D3', 'S1', 'S2', 'S3'
  ];
  
  // Get relationship icon
  static IconData getRelationshipIcon(String hubungan) {
    switch (hubungan.toLowerCase()) {
      case 'suami':
        return Icons.man;
      case 'istri':
        return Icons.woman;
      case 'anak':
        return Icons.child_care;
      case 'orang tua':
        return Icons.elderly;
      case 'saudara':
        return Icons.people;
      default:
        return Icons.person;
    }
  }
  
  // Get relationship color
  static Color getRelationshipColor(String hubungan) {
    switch (hubungan.toLowerCase()) {
      case 'suami':
      case 'istri':
        return const Color(0xFF667eea); // Primary
      case 'anak':
        return const Color(0xFF10B981); // Green
      case 'orang tua':
        return const Color(0xFFF59E0B); // Yellow
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }
}