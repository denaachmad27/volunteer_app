import 'dart:convert';
import 'api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class WargaItem {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final Map<String, dynamic>? profile;

  WargaItem({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.profile,
  });

  factory WargaItem.fromJson(Map<String, dynamic> json) {
    return WargaItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      profile: json['profile'] != null ? Map<String, dynamic>.from(json['profile']) : null,
    );
  }
}

class PaginatedWarga {
  final List<WargaItem> items;
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  PaginatedWarga({
    required this.items,
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  factory PaginatedWarga.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List? ?? [];
    return PaginatedWarga(
      items: data.map((e) => WargaItem.fromJson(Map<String, dynamic>.from(e))).toList(),
      currentPage: json['current_page'] ?? 1,
      perPage: json['per_page'] ?? 15,
      total: json['total'] ?? 0,
      lastPage: json['last_page'] ?? 1,
    );
  }
}

class RelawanService {
  static Future<PaginatedWarga> listWarga({String? search, int page = 1, int perPage = 15}) async {
    final query = <String, String>{
      'page': '$page',
      'per_page': '$perPage',
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final endpoint = Uri(path: '/relawan/warga', queryParameters: query).toString();
    final response = await ApiService.get(endpoint);
    final parsed = ApiService.parseResponse(response);
    if (parsed['status'] == 'success') {
      return PaginatedWarga.fromJson(parsed['data'] ?? {});
    }
    throw Exception(parsed['message'] ?? 'Gagal memuat daftar warga');
  }

  static Future<Map<String, dynamic>> assignWarga({List<int>? wargaIds, int? wargaId}) async {
    final payload = <String, dynamic>{};
    if (wargaIds != null && wargaIds.isNotEmpty) payload['warga_ids'] = wargaIds;
    if (wargaId != null) payload['warga_id'] = wargaId;
    final response = await ApiService.post('/relawan/assign-warga', payload);
    final parsed = ApiService.parseResponse(response);
    return parsed;
  }

  static Future<Map<String, dynamic>> createWarga({
    required String namaLengkap,
    required String nik,
    required String alamat,
    File? ktpFoto,
  }) async {
    final token = await ApiService.getToken();
    final uri = Uri.parse('${ApiService.baseUrl}/relawan/create-warga');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Accept'] = 'application/json';
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    request.fields['nama_lengkap'] = namaLengkap;
    request.fields['nik'] = nik;
    request.fields['alamat'] = alamat;
    if (ktpFoto != null && await ktpFoto.exists()) {
      request.files.add(await http.MultipartFile.fromPath('ktp_foto', ktpFoto.path));
    }
    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);
    final parsed = ApiService.parseResponse(resp);
    return parsed;
  }
}
