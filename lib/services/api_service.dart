import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Use 10.0.2.2:8000 for Android emulator (maps to host machine localhost)
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const String storageUrl = 'http://10.0.2.2:8000/storage';
  
  // Helper method to get complete image URL
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    
    String finalUrl;
    // If imagePath already contains full path (complaint_images/filename.jpg)
    if (imagePath.contains('complaint_images/')) {
      finalUrl = '$storageUrl/$imagePath';
    } else {
      // If imagePath is just filename, add the directory
      finalUrl = '$storageUrl/complaint_images/$imagePath';
    }
    
    print('=== IMAGE URL DEBUG ===');
    print('Input imagePath: $imagePath');
    print('Final URL: $finalUrl');
    print('=====================');
    
    return finalUrl;
  }
  
  // Get stored token from SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  
  // Get headers with authorization token
  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  // Generic GET request
  static Future<http.Response> get(String endpoint) async {
    final headers = await getHeaders();
    final uri = Uri.parse('$baseUrl$endpoint');
    
    print('=== API GET Request ===');
    print('URL: $uri');
    print('Headers: $headers');
    
    try {
      final response = await http.get(
        uri, 
        headers: headers,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout: Server tidak merespons dalam 30 detik');
        },
      );
      
      print('=== API Response ===');
      print('Status: ${response.statusCode}');
      print('Body length: ${response.body.length}');
      
      return response;
    } catch (e) {
      print('=== API Error ===');
      print('Error: $e');
      
      if (e.toString().contains('Connection refused')) {
        throw Exception('Connection refused: Tidak dapat terhubung ke server. Pastikan Laravel backend berjalan di localhost:8000');
      } else if (e.toString().contains('timeout')) {
        throw Exception('Request timeout: Server tidak merespons. Periksa koneksi internet Anda.');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('Network error: Masalah jaringan. Periksa koneksi internet dan pastikan server berjalan.');
      }
      
      throw Exception('Network error: $e');
    }
  }
  
  // Generic POST request
  static Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final headers = await getHeaders();
    final uri = Uri.parse('$baseUrl$endpoint');
    
    // Debug logging
    print('=== API POST Request ===');
    print('URL: $uri');
    print('Headers: $headers');
    print('Body: ${jsonEncode(data)}');
    
    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(data),
      );
      
      // Debug response
      print('=== API Response ===');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      
      return response;
    } catch (e) {
      print('=== API Error ===');
      print('Error: $e');
      throw Exception('Network error: $e');
    }
  }
  
  // Parse JSON response
  static Map<String, dynamic> parseResponse(http.Response response) {
    final responseBody = jsonDecode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    } else {
      // Handle 404 Not Found with specific message
      if (response.statusCode == 404) {
        throw Exception('404: ${responseBody['message'] ?? 'Data not found'}');
      }
      
      // Handle validation errors (422)
      if (response.statusCode == 422 && responseBody['errors'] != null) {
        final errors = responseBody['errors'] as Map<String, dynamic>;
        final errorMessages = <String>[];
        
        errors.forEach((field, messages) {
          if (messages is List) {
            errorMessages.addAll(messages.cast<String>());
          } else {
            errorMessages.add(messages.toString());
          }
        });
        
        throw Exception('Validation Error: ${errorMessages.join(', ')}');
      }
      
      // Handle other errors
      throw Exception(responseBody['message'] ?? 'API Error: ${response.statusCode}');
    }
  }
}