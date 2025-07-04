import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class BantuanSosialService {
  // Get all bantuan sosial programs
  static Future<Map<String, dynamic>> getAllPrograms({
    String? jenisFilter,
    String? search,
    int page = 1,
    int limit = 50, // Increase limit to get more data
  }) async {
    try {
      String endpoint = '/bantuan-sosial?page=$page&limit=$limit';
      
      if (jenisFilter != null && jenisFilter != 'Semua') {
        endpoint += '&jenis_bantuan=${Uri.encodeComponent(jenisFilter)}';
      }
      
      if (search != null && search.isNotEmpty) {
        endpoint += '&search=${Uri.encodeComponent(search)}';
      }
      
      print('=== BantuanSosialService getAllPrograms ===');
      print('Endpoint: $endpoint');
      
      final response = await ApiService.get(endpoint);
      final data = ApiService.parseResponse(response);
      
      print('=== API Response Data ===');
      print('Response structure: ${data.keys}');
      if (data['data'] != null) {
        print('Data count: ${data['data'].length}');
        if (data['data'].length > 0) {
          print('First item keys: ${data['data'][0].keys}');
          print('First item sample: ${data['data'][0]}');
        }
      }
      
      return {
        'success': true,
        'data': data['data'] ?? [],
        'meta': data['meta'] ?? {},
        'message': 'Programs loaded successfully'
      };
    } catch (e) {
      print('Error in getAllPrograms: $e');
      return {
        'success': false,
        'data': [],
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  // Get program by ID
  static Future<Map<String, dynamic>> getProgramById(int id) async {
    try {
      final response = await ApiService.get('/bantuan-sosial/$id');
      final data = ApiService.parseResponse(response);
      
      return {
        'success': true,
        'data': data['data'] ?? {},
        'message': 'Program loaded successfully'
      };
    } catch (e) {
      print('Error in getProgramById: $e');
      return {
        'success': false,
        'data': {},
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  // Submit application for bantuan sosial
  static Future<Map<String, dynamic>> submitApplication({
    required int bantuanSosialId,
    String? catatanTambahan,
    List<Map<String, String>>? dokumenPendukung,
  }) async {
    try {
      final applicationData = {
        'bantuan_sosial_id': bantuanSosialId,
        'alasan_pengajuan': catatanTambahan ?? '', // Backend expects this field
        // Note: dokumen_upload is for file uploads, not JSON string
        // Removed dokumen_pendukung and status as they're not required
      };
      
      print('=== Submitting Application ===');
      print('Data to send: $applicationData');
      
      final response = await ApiService.post('/pendaftaran', applicationData);
      final data = ApiService.parseResponse(response);
      
      print('=== Submission Response ===');
      print('Response data: $data');
      
      return {
        'success': true,
        'data': data['data'] ?? {},
        'message': data['message'] ?? 'Aplikasi berhasil disubmit'
      };
    } catch (e) {
      print('Error in submitApplication: $e');
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  // Resubmit application (for Perlu Dilengkapi status)
  static Future<Map<String, dynamic>> resubmitApplication({
    required int applicationId,
    String? catatanTambahan,
    List<Map<String, String>>? dokumenPendukung,
  }) async {
    try {
      final applicationData = {
        'alasan_pengajuan': catatanTambahan ?? '',
        // Note: dokumen_upload is for file uploads, not JSON string
      };
      
      print('=== Resubmitting Application ===');
      print('Application ID: $applicationId');
      print('Data to send: $applicationData');
      
      final response = await ApiService.post('/pendaftaran/$applicationId/resubmit', applicationData);
      final data = ApiService.parseResponse(response);
      
      print('=== Resubmission Response ===');
      print('Response data: $data');
      
      return {
        'success': true,
        'data': data['data'] ?? {},
        'message': data['message'] ?? 'Aplikasi berhasil disubmit ulang'
      };
    } catch (e) {
      print('Error in resubmitApplication: $e');
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  // Get user applications
  static Future<Map<String, dynamic>> getUserApplications({
    String? status,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      // Use the correct endpoint for user's own pendaftaran
      String endpoint = '/pendaftaran';
      
      print('=== BantuanSosialService getUserApplications ===');
      print('Endpoint: $endpoint');
      
      final response = await ApiService.get(endpoint);
      final data = ApiService.parseResponse(response);
      
      print('=== User Applications Response ===');
      print('Response keys: ${data.keys}');
      print('Data type: ${data['data'].runtimeType}');
      if (data['data'] != null) {
        print('Applications count: ${data['data'].length}');
      }
      
      // Filter by status if specified
      List<dynamic> applications = data['data'] ?? [];
      if (status != null && status != 'Semua') {
        applications = applications.where((app) => app['status'] == status).toList();
      }
      
      return {
        'success': true,
        'data': applications,
        'message': 'Applications loaded successfully'
      };
    } catch (e) {
      print('Error in getUserApplications: $e');
      return {
        'success': false,
        'data': [],
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  // Get application by ID
  static Future<Map<String, dynamic>> getApplicationById(int id) async {
    try {
      final response = await ApiService.get('/pendaftaran/$id');
      final data = ApiService.parseResponse(response);
      
      return {
        'success': true,
        'data': data['data'] ?? {},
        'message': 'Application loaded successfully'
      };
    } catch (e) {
      print('Error in getApplicationById: $e');
      return {
        'success': false,
        'data': {},
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  // Get application statistics for user
  static Future<Map<String, dynamic>> getUserStats() async {
    try {
      final response = await ApiService.get('/pendaftaran/user/stats');
      final data = ApiService.parseResponse(response);
      
      return {
        'success': true,
        'data': data['data'] ?? {},
        'message': 'Stats loaded successfully'
      };
    } catch (e) {
      print('Error in getUserStats: $e');
      return {
        'success': false,
        'data': {
          'total': 0,
          'pending': 0,
          'approved': 0,
          'rejected': 0
        },
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  // Helper method to format currency
  static String formatCurrency(dynamic amount) {
    if (amount == null) return 'Rp 0';
    
    try {
      int value = amount is String ? int.parse(amount) : amount;
      return 'Rp ${value.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
        (Match m) => '${m[1]}.',
      )}';
    } catch (e) {
      return 'Rp 0';
    }
  }

  // Helper method to format date
  static String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Tanggal tidak tersedia';
    
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return 'Tanggal tidak valid';
    }
  }

  // Helper method to get status color
  static Map<String, dynamic> getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return {
          'color': 'orange',
          'label': 'Menunggu',
          'description': 'Aplikasi sedang menunggu review'
        };
      case 'under review':
      case 'diproses':
        return {
          'color': 'blue',
          'label': 'Diproses',
          'description': 'Aplikasi sedang dalam review'
        };
      case 'disetujui':
      case 'approved':
        return {
          'color': 'green',
          'label': 'Disetujui',
          'description': 'Aplikasi telah disetujui'
        };
      case 'ditolak':
      case 'rejected':
        return {
          'color': 'red',
          'label': 'Ditolak',
          'description': 'Aplikasi ditolak'
        };
      case 'perlu dilengkapi':
      case 'need_completion':
        return {
          'color': 'orange',
          'label': 'Belum Lengkap',
          'description': 'Dokumen perlu dilengkapi untuk melanjutkan proses'
        };
      case 'selesai':
      case 'completed':
        return {
          'color': 'gray',
          'label': 'Selesai',
          'description': 'Bantuan telah disalurkan'
        };
      default:
        return {
          'color': 'gray',
          'label': status,
          'description': 'Status tidak diketahui'
        };
    }
  }

  // Helper method to get category color
  static Map<String, dynamic> getCategoryConfig(String category) {
    switch (category.toLowerCase()) {
      case 'pendidikan':
        return {
          'color': 'blue',
          'icon': '🎓',
          'description': 'Bantuan untuk pendidikan'
        };
      case 'kesehatan':
        return {
          'color': 'green',
          'icon': '🏥',
          'description': 'Bantuan untuk kesehatan'
        };
      case 'ekonomi':
        return {
          'color': 'orange',
          'icon': '💰',
          'description': 'Bantuan untuk ekonomi'
        };
      case 'perumahan':
        return {
          'color': 'purple',
          'icon': '🏠',
          'description': 'Bantuan untuk perumahan'
        };
      case 'pangan':
        return {
          'color': 'red',
          'icon': '🍚',
          'description': 'Bantuan untuk pangan'
        };
      default:
        return {
          'color': 'gray',
          'icon': '📋',
          'description': 'Bantuan sosial'
        };
    }
  }

  // Helper method to validate application data
  static Map<String, dynamic> validateApplicationData({
    required int bantuanSosialId,
    String? catatanTambahan,
  }) {
    List<String> errors = [];
    
    if (bantuanSosialId <= 0) {
      errors.add('Program bantuan tidak valid');
    }
    
    if (catatanTambahan != null && catatanTambahan.length > 500) {
      errors.add('Catatan tambahan maksimal 500 karakter');
    }
    
    return {
      'isValid': errors.isEmpty,
      'errors': errors
    };
  }

  // Helper method to check quota availability
  static bool isQuotaAvailable(Map<String, dynamic> program) {
    if (program['kuota'] == null) {
      return true; // Assume available if quota data is missing
    }
    
    final kuota = _parseIntValue(program['kuota']);
    final kuotaTerpakai = _parseIntValue(program['kuota_terpakai'] ?? 0);
    
    if (kuota <= 0) {
      return true; // No quota limit
    }
    
    return kuotaTerpakai < kuota;
  }

  // Helper method to safely parse int values
  static int _parseIntValue(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // Helper method to calculate quota percentage
  static double getQuotaPercentage(Map<String, dynamic> program) {
    final kuota = _parseIntValue(program['kuota']);
    final kuotaTerpakai = _parseIntValue(program['kuota_terpakai'] ?? 0);
    
    if (kuota <= 0) return 0.0;
    
    return (kuotaTerpakai / kuota) * 100;
  }

  // Helper method to get remaining quota
  static int getRemainingQuota(Map<String, dynamic> program) {
    final kuota = _parseIntValue(program['kuota']);
    final kuotaTerpakai = _parseIntValue(program['kuota_terpakai'] ?? 0);
    
    final remaining = kuota - kuotaTerpakai;
    return remaining < 0 ? 0 : remaining;
  }
}