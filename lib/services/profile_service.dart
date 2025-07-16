import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class ProfileService {
  // Get user profile data
  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      final response = await ApiService.get('/profile');
      final data = ApiService.parseResponse(response);
      
      return data['data'];
    } catch (e) {
      print('Error getting profile: $e');
      throw Exception('Gagal mengambil data profil: $e');
    }
  }
  
  // Create or update profile
  static Future<Map<String, dynamic>> createOrUpdateProfile({
    required String nik,
    required String namaLengkap,
    required String jenisKelamin,
    required String tempatLahir,
    required String tanggalLahir,
    required String alamat,
    required String kelurahan,
    required String kecamatan,
    required String kota,
    required String provinsi,
    required String kodePos,
    required String agama,
    required String statusPernikahan,
    required String pendidikanTerakhir,
    required String pekerjaan,
  }) async {
    try {
      final data = {
        'nik': nik,
        'nama_lengkap': namaLengkap,
        'jenis_kelamin': jenisKelamin,
        'tempat_lahir': tempatLahir,
        'tanggal_lahir': tanggalLahir,
        'alamat': alamat,
        'kelurahan': kelurahan,
        'kecamatan': kecamatan,
        'kota': kota,
        'provinsi': provinsi,
        'kode_pos': kodePos,
        'agama': agama,
        'status_pernikahan': statusPernikahan,
        'pendidikan_terakhir': pendidikanTerakhir,
        'pekerjaan': pekerjaan,
      };
      
      final response = await ApiService.post('/profile', data);
      return ApiService.parseResponse(response);
    } catch (e) {
      print('Error creating/updating profile: $e');
      throw Exception('Gagal menyimpan profil: $e');
    }
  }
  
  // Upload profile photo
  static Future<Map<String, dynamic>> uploadProfilePhoto(File imageFile) async {
    try {
      final token = await ApiService.getToken();
      final uri = Uri.parse('${ApiService.baseUrl}/profile/photo');
      
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll({
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });
      
      // Add image file
      final multipartFile = await http.MultipartFile.fromPath(
        'foto_profil',
        imageFile.path,
      );
      request.files.add(multipartFile);
      
      print('=== Upload Photo Request ===');
      print('URL: $uri');
      print('File path: ${imageFile.path}');
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('=== Upload Photo Response ===');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      
      return ApiService.parseResponse(response);
    } catch (e) {
      print('Error uploading photo: $e');
      throw Exception('Gagal upload foto profil: $e');
    }
  }
  
  // Get profile photo URL
  static String getProfilePhotoUrl(String? photoPath) {
    if (photoPath == null || photoPath.isEmpty) return '';
    
    // If photo path is just filename, add profile_photos directory
    if (!photoPath.contains('profile_photos/')) {
      return '${ApiService.storageUrl}/profile_photos/$photoPath';
    }
    
    return '${ApiService.storageUrl}/$photoPath';
  }
  
  // Validation helpers
  static String? validateNik(String? value) {
    if (value == null || value.isEmpty) {
      return 'NIK harus diisi';
    }
    if (value.length != 16) {
      return 'NIK harus 16 digit';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'NIK hanya boleh berisi angka';
    }
    return null;
  }
  
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName harus diisi';
    }
    return null;
  }
  
  static String? validateKodePos(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kode pos harus diisi';
    }
    if (value.length > 10) {
      return 'Kode pos maksimal 10 karakter';
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
      
      // Check minimum age (e.g., 17 years old)
      final age = now.difference(date).inDays / 365.25;
      if (age < 17) {
        return 'Usia minimal 17 tahun';
      }
      
      return null;
    } catch (e) {
      return 'Format tanggal tidak valid';
    }
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
  static const List<String> jenisKelaminOptions = ['Laki-laki', 'Perempuan'];
  
  static const List<String> agamaOptions = [
    'Islam', 'Kristen', 'Katolik', 'Hindu', 'Buddha', 'Konghucu'
  ];
  
  static const List<String> statusPernikahanOptions = [
    'Belum Menikah', 'Menikah', 'Cerai', 'Janda/Duda'
  ];
  
  static const List<String> pendidikanOptions = [
    'SD', 'SMP', 'SMA', 'D3', 'S1', 'S2', 'S3'
  ];
}