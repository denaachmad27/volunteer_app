import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class NewsItem {
  final int id;
  final String judul;
  final String slug;
  final String konten;
  final String kategori;
  final String? gambarUtama;
  final String? tanggalPublikasi;
  final int views;
  final String? author;
  final bool isPublished;
  final String? excerpt;
  final int? readingTime;

  NewsItem({
    required this.id,
    required this.judul,
    required this.slug,
    required this.konten,
    required this.kategori,
    this.gambarUtama,
    this.tanggalPublikasi,
    required this.views,
    this.author,
    required this.isPublished,
    this.excerpt,
    this.readingTime,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    try {
      print('=== NewsItem Debug ===');
      print('ID: ${json['id']} (${json['id'].runtimeType})');
      print('Views: ${json['views']} (${json['views'].runtimeType})');
      print('Published: ${json['is_published']} (${json['is_published'].runtimeType})');
      print('Reading time: ${json['reading_time']} (${json['reading_time']?.runtimeType})');
      
      final newsItem = NewsItem(
        id: _parseInt(json['id']) ?? 0,
        judul: json['judul']?.toString() ?? '',
        slug: json['slug']?.toString() ?? '',
        konten: json['konten']?.toString() ?? '',
        kategori: json['kategori']?.toString() ?? '',
        gambarUtama: json['gambar_utama']?.toString(),
        tanggalPublikasi: json['published_at']?.toString() ?? json['tanggal_publikasi']?.toString(),
        views: _parseInt(json['views']) ?? 0,
        author: _getAuthorName(json['author']),
        isPublished: _parseBool(json['is_published']) ?? false,
        excerpt: json['excerpt']?.toString(),
        readingTime: _parseInt(json['reading_time']),
      );
      
      print('=== Created NewsItem ===');
      print('ID: ${newsItem.id}');
      print('Title: ${newsItem.judul}');
      print('Image Path: ${newsItem.gambarUtama}');
      print('Image URL: ${NewsService.getImageUrl(newsItem.gambarUtama)}');
      print('=======================');
      
      return newsItem;
    } catch (e) {
      print('Error parsing NewsItem: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  // Helper methods for safe type conversion
  static int? _parseInt(dynamic value) {
    try {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) {
        if (value.isEmpty) return null;
        return int.tryParse(value);
      }
      if (value is double) return value.toInt();
      if (value is num) return value.toInt();
      
      // Try to convert other types to string first
      final stringValue = value.toString();
      return int.tryParse(stringValue);
    } catch (e) {
      print('Error parsing int from $value (${value.runtimeType}): $e');
      return null;
    }
  }

  static bool? _parseBool(dynamic value) {
    try {
      if (value == null) return null;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) {
        final lowerValue = value.toLowerCase();
        return lowerValue == 'true' || lowerValue == '1' || lowerValue == 'yes';
      }
      if (value is num) return value != 0;
      return null;
    } catch (e) {
      print('Error parsing bool from $value (${value.runtimeType}): $e');
      return false;
    }
  }

  static String _getAuthorName(dynamic author) {
    try {
      if (author == null) return 'Unknown';
      if (author is String) return author.isNotEmpty ? author : 'Unknown';
      if (author is Map<String, dynamic>) {
        final name = author['name'];
        if (name != null && name.toString().isNotEmpty) {
          return name.toString();
        }
        // Try other possible fields
        final displayName = author['display_name'] ?? author['username'] ?? author['email'];
        return displayName?.toString() ?? 'Unknown';
      }
      return author.toString().isNotEmpty ? author.toString() : 'Unknown';
    } catch (e) {
      print('Error parsing author from $author (${author.runtimeType}): $e');
      return 'Unknown';
    }
  }
}

class NewsResponse {
  final bool success;
  final List<NewsItem> data;
  final int? currentPage;
  final int? lastPage;
  final int? total;
  final String? message;

  NewsResponse({
    required this.success,
    required this.data,
    this.currentPage,
    this.lastPage,
    this.total,
    this.message,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    print('=== NewsResponse Debug ===');
    print('JSON keys: ${json.keys.toList()}');
    print('Status: ${json['status']}');
    
    final status = json['status'] == 'success';
    final newsData = json['data'];
    
    print('NewsData type: ${newsData.runtimeType}');
    
    List<NewsItem> newsList = [];
    int? currentPage;
    int? lastPage;
    int? total;
    
    if (newsData != null) {
      if (newsData is List) {
        print('Processing simple list with ${newsData.length} items');
        // Simple list response
        newsList = (newsData)
            .map((item) {
              print('Processing item: ${item.keys.toList()}');
              return NewsItem.fromJson(item);
            })
            .toList();
      } else if (newsData is Map) {
        print('Processing paginated response');
        print('Pagination keys: ${newsData.keys.toList()}');
        
        // Paginated response
        final data = newsData['data'];
        if (data is List) {
          print('Found data list with ${data.length} items');
          newsList = (data)
              .map((item) {
                print('Processing paginated item: ${item.keys.toList()}');
                return NewsItem.fromJson(item);
              })
              .toList();
        }
        currentPage = newsData['current_page'];
        lastPage = newsData['last_page'];
        total = newsData['total'];
        
        print('Pagination: page $currentPage/$lastPage, total: $total');
      }
    }
    
    print('Parsed ${newsList.length} news items successfully');
    
    return NewsResponse(
      success: status,
      data: newsList,
      currentPage: currentPage,
      lastPage: lastPage,
      total: total,
      message: json['message'],
    );
  }
}

class NewsService {
  // Get all published news (public endpoint)
  static Future<NewsResponse> getPublishedNews({
    String? kategori,
    String? search,
    int page = 1,
  }) async {
    String endpoint = '/news?page=$page';
    
    if (kategori != null && kategori.isNotEmpty && kategori != 'Semua') {
      endpoint += '&kategori=${Uri.encodeComponent(kategori)}';
    }
    
    if (search != null && search.isNotEmpty) {
      endpoint += '&search=${Uri.encodeComponent(search)}';
    }
    
    print('=== NewsService Debug ===');
    print('Fetching news from: ${ApiService.baseUrl}$endpoint');
    
    try {
      final response = await ApiService.get(endpoint);
      final data = ApiService.parseResponse(response);
      
      print('News API Response received: ${data['status']}');
      
      return NewsResponse.fromJson(data);
    } catch (e) {
      print('News API Error: $e');
      
      // Handle specific connection errors
      if (e.toString().contains('Connection refused')) {
        return NewsResponse(
          success: false,
          data: [],
          message: 'Tidak dapat terhubung ke server. Pastikan backend berjalan di localhost:8000',
        );
      } else if (e.toString().contains('Network error')) {
        return NewsResponse(
          success: false,
          data: [],
          message: 'Masalah koneksi jaringan. Periksa koneksi internet Anda.',
        );
      }
      
      return NewsResponse(
        success: false,
        data: [],
        message: 'Gagal memuat berita: ${e.toString()}',
      );
    }
  }
  
  // Get single news by slug (public endpoint)
  static Future<NewsItem?> getNewsBySlug(String slug) async {
    try {
      final response = await ApiService.get('/news/$slug');
      final data = ApiService.parseResponse(response);
      
      if (data['status'] == 'success' && data['data'] != null) {
        final newsData = data['data']['news'] ?? data['data'];
        return NewsItem.fromJson(newsData);
      }
      return null;
    } catch (e) {
      print('Error fetching news by slug: $e');
      return null;
    }
  }
  
  // Get related news by category
  static Future<List<NewsItem>> getRelatedNews(String kategori, {int limit = 3}) async {
    try {
      final response = await getPublishedNews(kategori: kategori);
      if (response.success) {
        return response.data.take(limit).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching related news: $e');
      return [];
    }
  }
  
  // Get categories (hardcoded to match backend)
  static List<String> getCategories() {
    return [
      'Semua',
      'Pengumuman',
      'Kegiatan', 
      'Bantuan',
      'Umum',
      // Add legacy categories for compatibility
      'Pemberdayaan',
      'Kesehatan',
      'Pendidikan',
      'Laporan'
    ];
  }
  
  // Map category colors (to match the existing UI)
  static int getCategoryColor(String category) {
    switch (category) {
      case 'Pemberdayaan':
        return 0xFF4CAF50;
      case 'Kesehatan':
        return 0xFF2196F3;
      case 'Pendidikan':
        return 0xFFFF9800;
      case 'Laporan':
        return 0xFF9C27B0;
      case 'Pengumuman':
        return 0xFFF44336;
      case 'Kegiatan':
        return 0xFF00BCD4;
      case 'Bantuan':
        return 0xFF8BC34A;
      case 'Umum':
        return 0xFF607D8B;
      default:
        return 0xFF667eea;
    }
  }
  
  // Format date for display
  static String formatDate(String? dateString) {
    if (dateString == null) return '';
    
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date).inDays;
      
      if (difference == 0) {
        return 'Hari ini';
      } else if (difference == 1) {
        return 'Kemarin';
      } else if (difference < 7) {
        return '$difference hari lalu';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }
  
  // Get image URL for news
  static String? getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return null;
    }
    
    // If it's already a full URL, return as is
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    
    // Use ApiService.storageUrl to match the configured backend server
    final cleanPath = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
    String fullUrl;
    
    // Laravel storage:link creates symlink from /storage/ to /storage/app/public/
    if (cleanPath.startsWith('news_images/')) {
      fullUrl = '${ApiService.storageUrl}/$cleanPath';
    } else {
      // Add news_images prefix if not present
      fullUrl = '${ApiService.storageUrl}/news_images/$cleanPath';
    }
    
    print('=== Image URL Generated ===');
    print('Original path: $imagePath');
    print('Final URL: $fullUrl');
    print('========================');
    
    return fullUrl;
  }
  
  // Test image connectivity
  static Future<bool> testImageConnectivity(String? imagePath) async {
    final imageUrl = getImageUrl(imagePath);
    if (imageUrl == null) return false;
    
    try {
      print('=== Testing Image Connectivity ===');
      print('Testing URL: $imageUrl');
      
      final response = await http.get(Uri.parse(imageUrl));
      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response content-type: ${response.headers['content-type']}');
      print('================================');
      
      return response.statusCode == 200 && 
             (response.headers['content-type']?.startsWith('image/') == true);
    } catch (e) {
      print('=== Image Connectivity Test Failed ===');
      print('Error: $e');
      print('====================================');
      return false;
    }
  }

  // Test server connectivity
  static Future<Map<String, String>> testServerConnectivity() async {
    final servers = [
      'http://192.168.0.194:8000',
      'http://10.0.2.2:8000',
      'http://localhost:8000',
      'http://127.0.0.1:8000',
    ];
    
    Map<String, String> results = {};
    
    for (final server in servers) {
      try {
        print('=== Testing Server: $server ===');
        final response = await http.get(Uri.parse('$server/api/news')).timeout(
          const Duration(seconds: 5),
        );
        results[server] = 'Status: ${response.statusCode}';
        print('✓ $server - Status: ${response.statusCode}');
      } catch (e) {
        results[server] = 'Error: ${e.toString()}';
        print('✗ $server - Error: $e');
      }
    }
    
    return results;
  }
}