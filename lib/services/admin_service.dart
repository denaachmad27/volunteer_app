import 'api_service.dart';

class AdminService {
  // Get all news for admin (tanpa filter)
  static Future<Map<String, dynamic>> getAllNews({
    String? kategori,
    String? search,
    int page = 1,
  }) async {
    try {
      String endpoint = '/news/admin?page=$page';

      if (kategori != null && kategori.isNotEmpty && kategori != 'Semua') {
        endpoint += '&kategori=${Uri.encodeComponent(kategori)}';
      }
      if (search != null && search.isNotEmpty) {
        endpoint += '&search=${Uri.encodeComponent(search)}';
      }

      final response = await ApiService.get(endpoint);
      final data = ApiService.parseResponse(response);

      return {
        'success': true,
        'data': data['data'] ?? {},
        'message': 'All news loaded successfully'
      };
    } catch (e) {
      return {
        'success': false,
        'data': {},
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  // Get all applications for admin (tanpa filter)
  static Future<Map<String, dynamic>> getAllApplications({
    String? status,
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      String endpoint = '/pendaftaran/admin?page=$page&limit=$limit';

      if (status != null && status != 'Semua') {
        endpoint += '&status=$status';
      }
      if (search != null && search.isNotEmpty) {
        endpoint += '&search=${Uri.encodeComponent(search)}';
      }

      final response = await ApiService.get(endpoint);
      final data = ApiService.parseResponse(response);

      return {
        'success': true,
        'data': data['data'] ?? [],
        'meta': data['meta'] ?? {},
        'message': 'All applications loaded successfully'
      };
    } catch (e) {
      return {
        'success': false,
        'data': [],
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  // Get all complaints for admin (tanpa filter)
  static Future<Map<String, dynamic>> getAllComplaints({
    String? status,
    String? kategori,
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      String endpoint = '/complaint/admin?page=$page&limit=$limit';

      if (status != null && status.isNotEmpty && status != 'Semua') {
        endpoint += '&status=$status';
      }
      if (kategori != null && kategori.isNotEmpty && kategori != 'Semua') {
        endpoint += '&kategori=$kategori';
      }
      if (search != null && search.isNotEmpty) {
        endpoint += '&search=${Uri.encodeComponent(search)}';
      }

      final response = await ApiService.get(endpoint);
      final data = ApiService.parseResponse(response);

      return {
        'success': true,
        'data': data['data'] ?? [],
        'meta': data['meta'] ?? {},
        'message': 'All complaints loaded successfully'
      };
    } catch (e) {
      return {
        'success': false,
        'data': [],
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  // Get all users for admin (tanpa filter)
  static Future<Map<String, dynamic>> getAllUsers({
    String? role,
    String? status,
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      String endpoint = '/users?page=$page&limit=$limit';

      if (role != null && role.isNotEmpty && role != 'all') {
        endpoint += '&role=$role';
      }
      if (status != null && status.isNotEmpty && status != 'all') {
        endpoint += '&is_active=${status == 'active'}';
      }
      if (search != null && search.isNotEmpty) {
        endpoint += '&search=${Uri.encodeComponent(search)}';
      }

      final response = await ApiService.get(endpoint);
      final data = ApiService.parseResponse(response);

      return {
        'success': true,
        'data': data['data'] ?? [],
        'meta': data['meta'] ?? {},
        'message': 'All users loaded successfully'
      };
    } catch (e) {
      return {
        'success': false,
        'data': [],
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  // Get all warga binaan for admin (tanpa filter)
  static Future<Map<String, dynamic>> getAllWargaBinaan({
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      String endpoint = '/warga-binaan/admin?page=$page&limit=$limit';

      if (search != null && search.isNotEmpty) {
        endpoint += '&search=${Uri.encodeComponent(search)}';
      }

      final response = await ApiService.get(endpoint);
      final data = ApiService.parseResponse(response);

      return {
        'success': true,
        'data': data['data'] ?? [],
        'meta': data['meta'] ?? {},
        'message': 'All warga binaan loaded successfully'
      };
    } catch (e) {
      return {
        'success': false,
        'data': [],
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  // Get all reses for admin (tanpa filter)
  static Future<Map<String, dynamic>> getAllReses({
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      String endpoint = '/reses/admin?page=$page&limit=$limit';

      if (search != null && search.isNotEmpty) {
        endpoint += '&search=${Uri.encodeComponent(search)}';
      }

      final response = await ApiService.get(endpoint);
      final data = ApiService.parseResponse(response);

      return {
        'success': true,
        'data': data['data'] ?? [],
        'meta': data['meta'] ?? {},
        'message': 'All reses loaded successfully'
      };
    } catch (e) {
      return {
        'success': false,
        'data': [],
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  // Get all pokir for admin (tanpa filter)
  static Future<Map<String, dynamic>> getAllPokir({
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      String endpoint = '/pokir/admin?page=$page&limit=$limit';

      if (search != null && search.isNotEmpty) {
        endpoint += '&search=${Uri.encodeComponent(search)}';
      }

      final response = await ApiService.get(endpoint);
      final data = ApiService.parseResponse(response);

      return {
        'success': true,
        'data': data['data'] ?? [],
        'meta': data['meta'] ?? {},
        'message': 'All pokir loaded successfully'
      };
    } catch (e) {
      return {
        'success': false,
        'data': [],
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  // Get admin statistics
  static Future<Map<String, dynamic>> getAdminStatistics() async {
    try {
      final response = await ApiService.get('/admin/statistics');
      final data = ApiService.parseResponse(response);

      return {
        'success': true,
        'data': data['data'] ?? {},
        'message': 'Admin statistics loaded successfully'
      };
    } catch (e) {
      return {
        'success': false,
        'data': {},
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }
}