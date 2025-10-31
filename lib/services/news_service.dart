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
  final List<String> tags;

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
    this.tags = const [],
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
        tags: _parseTagsList(json['tags']),
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

  static List<String> _parseTagsList(dynamic tags) {
    try {
      if (tags == null) return [];
      if (tags is List) {
        return tags.map((tag) => tag.toString()).toList();
      }
      if (tags is String) {
        // If it's a JSON string, try to parse it
        return [];
      }
      return [];
    } catch (e) {
      print('Error parsing tags from $tags (${tags.runtimeType}): $e');
      return [];
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
  // Test endpoint - get all news without any filters
  static Future<Map<String, dynamic>> getAllNewsTest() async {
    const endpoint = '/admin/news/test';

    print('=== NewsService Test Debug ===');
    print('Endpoint: $endpoint');
    print('Full URL: ${ApiService.baseUrl}$endpoint');

    try {
      final response = await ApiService.get(endpoint);
      final data = ApiService.parseResponse(response);

      print('Test Response Status: ${data['status']}');
      if (data['data'] != null && data['data']['total'] != null) {
        print('Total News: ${data['data']['total']}');
        if (data['data']['news'] != null) {
          print('News Count: ${data['data']['news'].length}');
          print('First 3 Items:');
          for (int i = 0; i < data['data']['news'].length && i < 3; i++) {
            final item = data['data']['news'][i];
            print('  Item ${i+1}: ${item['judul']} (id: ${item['id']}, aleg_id: ${item['anggota_legislatif_id']})');
          }
        }
      }

      return data;
    } catch (e) {
      print('Test API Error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get all news for admin (without id_aleg filter)
  static Future<NewsResponse> getAllNewsForAdmin({
    String? kategori,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    String endpoint = '/admin/news?page=$page&limit=$limit';

    if (kategori != null && kategori.isNotEmpty && kategori != 'Semua') {
      endpoint += '&kategori=${Uri.encodeComponent(kategori)}';
    }

    if (search != null && search.isNotEmpty) {
      endpoint += '&search=${Uri.encodeComponent(search)}';
    }

    print('=== NewsService Admin Debug ===');
    print('Endpoint: $endpoint');
    print('Full URL: ${ApiService.baseUrl}$endpoint');

    try {
      final response = await ApiService.get(endpoint);
      final data = ApiService.parseResponse(response);

      print('Response Status: ${data['status']}');
      print('Response Data Keys: ${data.keys}');
      if (data['data'] != null) {
        if (data['data'] is Map) {
          print('Response Data Structure: Pagination');
          print('Total Count: ${data['data']['total']}');
          print('Current Page: ${data['data']['current_page']}');
          if (data['data']['data'] != null) {
            print('Items Count: ${data['data']['data'].length}');
            print('First 3 Items:');
            for (int i = 0; i < data['data']['data'].length && i < 3; i++) {
              final item = data['data']['data'][i];
              print('  Item ${i+1}: ${item['judul']} (id: ${item['id']}, aleg_id: ${item['anggota_legislatif_id']})');
            }
          }
        } else if (data['data'] is List) {
          print('Response Data Structure: Simple List');
          print('Items Count: ${data['data'].length}');
        }
      }

      return NewsResponse.fromJson(data);
    } catch (e) {
      print('Admin News API Error: $e');

      return NewsResponse(
        success: false,
        data: [],
        message: 'Gagal memuat berita admin: ${e.toString()}',
      );
    }
  }

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
        return 0xFFFFA726;
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

  // Create news (Admin only)
  static Future<NewsCreateResponse> createNews({
    required String judul,
    required String konten,
    required String kategori,
    bool isPublished = false,
    List<String> tags = const [],
    dynamic gambarUtama, // Can be File (mobile) or String (web)
    int? anggotaLegislatifId,
  }) async {
    try {
      print('=== Creating News ===');
      print('Judul: $judul');
      print('Kategori: $kategori');
      print('Is Published: $isPublished');
      print('Tags: $tags');
      print('Has Image: ${gambarUtama != null}');

      final Map<String, String> requestData = {
        'judul': judul,
        'konten': konten,
        'kategori': kategori,
        'is_published': isPublished ? '1' : '0',
      };

      // Add tags only if not empty
      if (tags.isNotEmpty) {
        requestData['tags'] = jsonEncode(tags);
      }

      if (anggotaLegislatifId != null) {
        requestData['anggota_legislatif_id'] = anggotaLegislatifId.toString();
      }

      final response = await ApiService.postMultipart(
        '/admin/news',
        data: requestData,
        filePath: gambarUtama,
        fileFieldName: 'gambar_utama',
      );

      final data = ApiService.parseResponse(response);

      print('Create News Response: ${data['status']}');

      if (data['status'] == 'success') {
        return NewsCreateResponse(
          success: true,
          message: data['message'] ?? 'Berita berhasil dibuat',
          data: data['data'] != null ? NewsItem.fromJson(data['data']) : null,
        );
      } else {
        return NewsCreateResponse(
          success: false,
          message: data['message'] ?? 'Gagal membuat berita',
        );
      }
    } catch (e) {
      print('Create News Error: $e');
      return NewsCreateResponse(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }

  // Update news (Admin only)
  static Future<NewsCreateResponse> updateNews({
    required int id,
    required String judul,
    required String konten,
    required String kategori,
    bool isPublished = false,
    List<String> tags = const [],
    dynamic gambarUtama,
    int? anggotaLegislatifId,
  }) async {
    try {
      print('=== Updating News $id ===');

      final Map<String, String> requestData = {
        'judul': judul,
        'konten': konten,
        'kategori': kategori,
        'is_published': isPublished ? '1' : '0',
        '_method': 'PUT', // Laravel method spoofing for multipart
      };

      // Add tags only if not empty
      if (tags.isNotEmpty) {
        requestData['tags'] = jsonEncode(tags);
      }

      if (anggotaLegislatifId != null) {
        requestData['anggota_legislatif_id'] = anggotaLegislatifId.toString();
      }

      final response = await ApiService.postMultipart(
        '/admin/news/$id',
        data: requestData,
        filePath: gambarUtama,
        fileFieldName: 'gambar_utama',
      );

      final data = ApiService.parseResponse(response);

      if (data['status'] == 'success') {
        return NewsCreateResponse(
          success: true,
          message: data['message'] ?? 'Berita berhasil diupdate',
          data: data['data'] != null ? NewsItem.fromJson(data['data']) : null,
        );
      } else {
        return NewsCreateResponse(
          success: false,
          message: data['message'] ?? 'Gagal mengupdate berita',
        );
      }
    } catch (e) {
      print('Update News Error: $e');
      return NewsCreateResponse(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }

  // Delete news (Admin only)
  static Future<NewsCreateResponse> deleteNews(int id) async {
    try {
      print('=== Deleting News $id ===');

      final response = await ApiService.delete('/admin/news/$id');
      final data = ApiService.parseResponse(response);

      if (data['status'] == 'success') {
        return NewsCreateResponse(
          success: true,
          message: data['message'] ?? 'Berita berhasil dihapus',
        );
      } else {
        return NewsCreateResponse(
          success: false,
          message: data['message'] ?? 'Gagal menghapus berita',
        );
      }
    } catch (e) {
      print('Delete News Error: $e');
      return NewsCreateResponse(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }
}

class NewsCreateResponse {
  final bool success;
  final String message;
  final NewsItem? data;

  NewsCreateResponse({
    required this.success,
    required this.message,
    this.data,
  });
}
