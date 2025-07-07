import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class ComplaintService {
  // Get all complaints for the authenticated user
  static Future<List<Map<String, dynamic>>> getUserComplaints({
    String? status,
    String? kategori,
  }) async {
    String endpoint = '/complaint';
    
    // Build query parameters
    List<String> queryParams = [];
    if (status != null && status.isNotEmpty) {
      queryParams.add('status=$status');
    }
    if (kategori != null && kategori.isNotEmpty) {
      queryParams.add('kategori=$kategori');
    }
    
    if (queryParams.isNotEmpty) {
      endpoint += '?${queryParams.join('&')}';
    }
    
    final response = await ApiService.get(endpoint);
    final data = ApiService.parseResponse(response);
    
    if (data['status'] == 'success' && data['data'] != null) {
      return List<Map<String, dynamic>>.from(data['data']);
    }
    
    return [];
  }
  
  // Get complaint by ID
  static Future<Map<String, dynamic>?> getComplaintById(int id) async {
    final response = await ApiService.get('/complaint/$id');
    final data = ApiService.parseResponse(response);
    
    if (data['status'] == 'success' && data['data'] != null) {
      return Map<String, dynamic>.from(data['data']);
    }
    
    return null;
  }
  
  // Create new complaint
  static Future<Map<String, dynamic>> createComplaint({
    required String judul,
    required String kategori,
    required String deskripsi,
    required String prioritas,
    File? imageFile,
  }) async {
    final token = await ApiService.getToken();
    final uri = Uri.parse('${ApiService.baseUrl}/complaint');
    
    var request = http.MultipartRequest('POST', uri);
    
    // Add headers
    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });
    
    // Add text fields
    request.fields.addAll({
      'judul': judul,
      'kategori': kategori,
      'deskripsi': deskripsi,
      'prioritas': prioritas,
    });
    
    // Add image file if provided
    if (imageFile != null) {
      String fileName = imageFile.path.split('/').last;
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          filename: fileName,
        ),
      );
    }
    
    print('=== Creating Complaint ===');
    print('URL: $uri');
    print('Fields: ${request.fields}');
    print('Files: ${request.files.map((f) => f.filename)}');
    
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('=== Response ===');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      
      final data = ApiService.parseResponse(response);
      
      if (data['status'] == 'success') {
        return Map<String, dynamic>.from(data['data']);
      }
      
      throw Exception(data['message'] ?? 'Failed to create complaint');
    } catch (e) {
      print('=== Error ===');
      print('Error: $e');
      throw Exception('Network error: $e');
    }
  }
  
  // Update complaint (only if status is 'Baru')
  static Future<Map<String, dynamic>> updateComplaint({
    required int id,
    required String judul,
    required String kategori,
    required String deskripsi,
    required String prioritas,
  }) async {
    final complaintData = {
      'judul': judul,
      'kategori': kategori,
      'deskripsi': deskripsi,
      'prioritas': prioritas,
    };
    
    final headers = await ApiService.getHeaders();
    final uri = Uri.parse('${ApiService.baseUrl}/complaint/$id');
    
    final response = await http.put(
      uri,
      headers: headers,
      body: jsonEncode(complaintData),
    );
    
    final data = ApiService.parseResponse(response);
    
    if (data['status'] == 'success') {
      return Map<String, dynamic>.from(data['data']);
    }
    
    throw Exception(data['message'] ?? 'Failed to update complaint');
  }
  
  // Give feedback and rating (only for completed complaints)
  static Future<Map<String, dynamic>> giveFeedback({
    required int id,
    required int rating,
    String? feedback,
  }) async {
    final feedbackData = {
      'rating': rating,
      if (feedback != null && feedback.isNotEmpty) 'feedback': feedback,
    };
    
    final response = await ApiService.post('/complaint/$id/feedback', feedbackData);
    final data = ApiService.parseResponse(response);
    
    if (data['status'] == 'success') {
      return Map<String, dynamic>.from(data['data']);
    }
    
    throw Exception(data['message'] ?? 'Failed to submit feedback');
  }
  
  // Get user dashboard statistics
  static Future<Map<String, dynamic>> getUserDashboard() async {
    final response = await ApiService.get('/complaint/dashboard');
    final data = ApiService.parseResponse(response);
    
    if (data['status'] == 'success' && data['data'] != null) {
      return Map<String, dynamic>.from(data['data']);
    }
    
    return {};
  }
  
  // Get available categories
  static List<String> getCategories() {
    return [
      'Teknis',
      'Pelayanan',
      'Bantuan',
      'Saran',
      'Lainnya',
    ];
  }
  
  // Get available priorities
  static List<String> getPriorities() {
    return [
      'Rendah',
      'Sedang',
      'Tinggi',
      'Urgent',
    ];
  }
  
  // Get status colors
  static Map<String, dynamic> getStatusConfig(String status) {
    switch (status) {
      case 'Baru':
        return {
          'color': 0xFFF44336, // Red
          'label': 'Baru',
          'icon': 'error_outline',
        };
      case 'Diproses':
        return {
          'color': 0xFF2196F3, // Blue
          'label': 'Diproses',
          'icon': 'autorenew',
        };
      case 'Selesai':
        return {
          'color': 0xFF4CAF50, // Green
          'label': 'Selesai',
          'icon': 'check_circle',
        };
      case 'Ditutup':
        return {
          'color': 0xFF9E9E9E, // Grey
          'label': 'Ditutup',
          'icon': 'cancel',
        };
      default:
        return {
          'color': 0xFF667eea,
          'label': status,
          'icon': 'help_outline',
        };
    }
  }
  
  // Get priority colors
  static Map<String, dynamic> getPriorityConfig(String priority) {
    switch (priority) {
      case 'Rendah':
        return {
          'color': 0xFF4CAF50, // Green
          'label': 'Rendah',
        };
      case 'Sedang':
        return {
          'color': 0xFF2196F3, // Blue
          'label': 'Sedang',
        };
      case 'Tinggi':
        return {
          'color': 0xFFFF9800, // Orange
          'label': 'Tinggi',
        };
      case 'Urgent':
        return {
          'color': 0xFFF44336, // Red
          'label': 'Urgent',
        };
      default:
        return {
          'color': 0xFF9E9E9E,
          'label': priority,
        };
    }
  }
  
  // Get category colors
  static Map<String, dynamic> getCategoryConfig(String kategori) {
    switch (kategori) {
      case 'Teknis':
        return {
          'color': 0xFF2196F3, // Blue
          'icon': 'build',
        };
      case 'Pelayanan':
        return {
          'color': 0xFF4CAF50, // Green
          'icon': 'support_agent',
        };
      case 'Bantuan':
        return {
          'color': 0xFFFF9800, // Orange
          'icon': 'help',
        };
      case 'Saran':
        return {
          'color': 0xFF9C27B0, // Purple
          'icon': 'lightbulb',
        };
      case 'Lainnya':
        return {
          'color': 0xFF607D8B, // Blue Grey
          'icon': 'more_horiz',
        };
      default:
        return {
          'color': 0xFF9E9E9E,
          'icon': 'category',
        };
    }
  }
}