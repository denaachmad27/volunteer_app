import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class LegislativeService {
  // Use ApiService.baseUrl untuk menggunakan konfigurasi yang sama
  static String get baseUrl => ApiService.baseUrl;

  static Future<LegislativeResponse> getActiveLegislativeMembers() async {
    try {
      print('=== LEGISLATIVE SERVICE: Fetching active legislative members ===');

      final response = await http.get(
        Uri.parse('$baseUrl/anggota-legislatif/options'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return LegislativeResponse.fromJson(data);
      } else {
        throw Exception('Failed to load legislative members: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getActiveLegislativeMembers: $e');
      throw Exception('Failed to load legislative members: $e');
    }
  }

  // Get all legislative members for admin with pagination
  static Future<Map<String, dynamic>> getAllLegislativeMembers({
    int page = 1,
    int limit = 100,
    String? search,
  }) async {
    try {
      print('=== LEGISLATIVE SERVICE: Fetching all legislative members for admin ===');

      String endpoint = '/admin/anggota-legislatif?page=$page&limit=$limit';
      if (search != null && search.isNotEmpty) {
        endpoint += '&search=${Uri.encodeComponent(search)}';
      }

      final response = await ApiService.get(endpoint);
      final data = ApiService.parseResponse(response);

      print('Response status: ${response.statusCode}');
      print('Response data keys: ${data.keys}');

      if (data['status'] == 'success' && data['data'] != null) {
        // Handle nested data structure from backend pagination
        List<dynamic> itemsList = [];
        Map<String, dynamic> metaData = {};

        if (data['data'] is Map<String, dynamic>) {
          // Backend returns nested structure: data.data contains the items
          itemsList = data['data']['data'] as List<dynamic>? ?? [];
          metaData = data['data'] as Map<String, dynamic>;
          // Remove the actual items from meta to avoid confusion
          metaData.remove('data');
        } else if (data['data'] is List) {
          // Fallback if backend returns direct list
          itemsList = data['data'] as List<dynamic>;
        }

        final members = itemsList
            .map((item) => LegislativeMember.fromAdminJson(item))
            .toList();

        return {
          'success': true,
          'data': members,
          'meta': metaData,
          'message': data['message'] ?? 'Legislative members loaded successfully'
        };
      } else {
        return {
          'success': false,
          'data': <LegislativeMember>[],
          'message': data['message'] ?? 'Failed to load legislative members'
        };
      }
    } catch (e) {
      print('Error in getAllLegislativeMembers: $e');
      return {
        'success': false,
        'data': <LegislativeMember>[],
        'message': 'Failed to load legislative members: $e'
      };
    }
  }

  static Future<LegislativeMember?> getUserLegislativeMember() async {
    try {
      print('=== LEGISLATIVE SERVICE: Fetching user\'s selected legislative member ===');
      
      final response = await http.get(
        Uri.parse('$baseUrl/auth/my-legislative-member'),
        headers: await ApiService.getHeaders(),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          return LegislativeMember.fromJson(data['data']);
        }
      } else if (response.statusCode == 404) {
        print('User has no associated legislative member');
        return null;
      } else {
        throw Exception('Failed to load user legislative member: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getUserLegislativeMember: $e');
      throw Exception('Failed to load user legislative member: $e');
    }
    return null;
  }

  static Future<LegislativeMemberDetailResponse> getLegislativeMemberDetail(int id) async {
    try {
      print('=== LEGISLATIVE SERVICE: Fetching legislative member detail for ID: $id ===');
      
      final response = await http.get(
        Uri.parse('$baseUrl/anggota-legislatif/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return LegislativeMemberDetailResponse.fromJson(data);
      } else {
        throw Exception('Failed to load legislative member detail: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getLegislativeMemberDetail: $e');
      throw Exception('Failed to load legislative member detail: $e');
    }
  }

  static String getProfilePhotoUrl(String? photoPath) {
    if (photoPath == null || photoPath.isEmpty) {
      return '';
    }

    // Remove 'public/' prefix if it exists in the path
    String cleanPath = photoPath.startsWith('public/')
        ? photoPath.substring(7)
        : photoPath;

    return '${ApiService.storageUrl}/$cleanPath';
  }

  static String formatPhoneNumber(String phone) {
    // Remove any non-digit characters except +
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Format Indonesian phone numbers
    if (cleaned.startsWith('08')) {
      return '+62${cleaned.substring(1)}';
    } else if (cleaned.startsWith('62')) {
      return '+$cleaned';
    } else if (cleaned.startsWith('+62')) {
      return cleaned;
    }
    
    return phone; // Return original if not recognized pattern
  }

  static String getAgeFromBirthDate(String? birthDate) {
    if (birthDate == null || birthDate.isEmpty) {
      return 'N/A';
    }

    try {
      final birthDateTime = DateTime.parse(birthDate);
      final now = DateTime.now();
      final age = now.year - birthDateTime.year;
      
      // Check if birthday hasn't occurred this year yet
      if (now.month < birthDateTime.month || 
          (now.month == birthDateTime.month && now.day < birthDateTime.day)) {
        return '${age - 1} tahun';
      }
      
      return '$age tahun';
    } catch (e) {
      return 'N/A';
    }
  }

  static String formatBirthDate(String? birthDate) {
    if (birthDate == null || birthDate.isEmpty) {
      return 'N/A';
    }

    try {
      // Handle both formats: "2023-01-01" and "2023-01-01T00:00:00.000000Z"
      String cleanDate = birthDate.split('T')[0]; // Remove time part if exists
      final birthDateTime = DateTime.parse(cleanDate);
      
      // Format as dd MMMM yyyy (Indonesian format)
      final months = [
        '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      
      return '${birthDateTime.day} ${months[birthDateTime.month]} ${birthDateTime.year}';
    } catch (e) {
      print('Error formatting birth date: $e');
      return birthDate.split('T')[0]; // Fallback to just date part
    }
  }
}

class LegislativeResponse {
  final bool success;
  final String message;
  final List<LegislativeMember> data;

  LegislativeResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LegislativeResponse.fromJson(Map<String, dynamic> json) {
    return LegislativeResponse(
      success: json['status'] == 'success',
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => LegislativeMember.fromJson(item))
          .toList() ?? [],
    );
  }
}

class LegislativeMemberDetailResponse {
  final bool success;
  final String message;
  final LegislativeMemberDetail data;

  LegislativeMemberDetailResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LegislativeMemberDetailResponse.fromJson(Map<String, dynamic> json) {
    return LegislativeMemberDetailResponse(
      success: json['status'] == 'success',
      message: json['message'] ?? '',
      data: LegislativeMemberDetail.fromJson(json['data']),
    );
  }
}

class LegislativeMember {
  final int id;
  final String kodeAleg;
  final String namaLengkap;
  final String jabatanSaatIni;
  final String? fotoProfil;

  LegislativeMember({
    required this.id,
    required this.kodeAleg,
    required this.namaLengkap,
    required this.jabatanSaatIni,
    this.fotoProfil,
  });

  factory LegislativeMember.fromJson(Map<String, dynamic> json) {
    return LegislativeMember(
      id: json['id'] ?? 0,
      kodeAleg: json['kode_aleg'] ?? '',
      namaLengkap: json['nama_lengkap'] ?? '',
      jabatanSaatIni: json['jabatan_saat_ini'] ?? '',
      fotoProfil: json['foto_profil'],
    );
  }

  factory LegislativeMember.fromAdminJson(Map<String, dynamic> json) {
    return LegislativeMember(
      id: json['id'] ?? 0,
      kodeAleg: json['kode_aleg'] ?? '',
      namaLengkap: json['nama_lengkap'] ?? '',
      jabatanSaatIni: json['jabatan_saat_ini'] ?? '',
      fotoProfil: json['foto_profil'],
    );
  }

  String get profilePhotoUrl {
    return LegislativeService.getProfilePhotoUrl(fotoProfil);
  }
}

class LegislativeMemberDetail {
  final int id;
  final String kodeAleg;
  final String namaLengkap;
  final String jenisKelamin;
  final String tempatLahir;
  final String? tanggalLahir;
  final String alamat;
  final String kelurahan;
  final String kecamatan;
  final String kota;
  final String provinsi;
  final String kodePos;
  final String noTelepon;
  final String email;
  final String jabatanSaatIni;
  final String partaiPolitik;
  final String daerahPemilihan;
  final String? riwayatJabatan;
  final String? fotoProfil;
  final String status;
  final List<Volunteer>? volunteers;
  final int? volunteersCount;

  LegislativeMemberDetail({
    required this.id,
    required this.kodeAleg,
    required this.namaLengkap,
    required this.jenisKelamin,
    required this.tempatLahir,
    this.tanggalLahir,
    required this.alamat,
    required this.kelurahan,
    required this.kecamatan,
    required this.kota,
    required this.provinsi,
    required this.kodePos,
    required this.noTelepon,
    required this.email,
    required this.jabatanSaatIni,
    required this.partaiPolitik,
    required this.daerahPemilihan,
    this.riwayatJabatan,
    this.fotoProfil,
    required this.status,
    this.volunteers,
    this.volunteersCount,
  });

  factory LegislativeMemberDetail.fromJson(Map<String, dynamic> json) {
    return LegislativeMemberDetail(
      id: json['id'] ?? 0,
      kodeAleg: json['kode_aleg'] ?? '',
      namaLengkap: json['nama_lengkap'] ?? '',
      jenisKelamin: json['jenis_kelamin'] ?? '',
      tempatLahir: json['tempat_lahir'] ?? '',
      tanggalLahir: json['tanggal_lahir'],
      alamat: json['alamat'] ?? '',
      kelurahan: json['kelurahan'] ?? '',
      kecamatan: json['kecamatan'] ?? '',
      kota: json['kota'] ?? '',
      provinsi: json['provinsi'] ?? '',
      kodePos: json['kode_pos'] ?? '',
      noTelepon: json['no_telepon'] ?? '',
      email: json['email'] ?? '',
      jabatanSaatIni: json['jabatan_saat_ini'] ?? '',
      partaiPolitik: json['partai_politik'] ?? '',
      daerahPemilihan: json['daerah_pemilihan'] ?? '',
      riwayatJabatan: json['riwayat_jabatan'],
      fotoProfil: json['foto_profil'],
      status: json['status'] ?? '',
      volunteers: json['volunteers'] != null
          ? (json['volunteers'] as List)
              .map((v) => Volunteer.fromJson(v))
              .toList()
          : null,
      volunteersCount: json['volunteers_count'],
    );
  }

  String get fullAddress {
    return '$alamat, $kelurahan, $kecamatan, $kota, $provinsi $kodePos';
  }

  String get formattedPhoneNumber {
    return LegislativeService.formatPhoneNumber(noTelepon);
  }

  String get age {
    return LegislativeService.getAgeFromBirthDate(tanggalLahir);
  }

  String get profilePhotoUrl {
    return LegislativeService.getProfilePhotoUrl(fotoProfil);
  }

  String get formattedBirthDate {
    return LegislativeService.formatBirthDate(tanggalLahir);
  }

  int get volunteerCount {
    // If volunteers data is available, use its length
    if (volunteers != null) {
      return volunteers!.length;
    }
    // Otherwise, use volunteers_count field (for public access)
    return volunteersCount ?? 0;
  }
}

class Volunteer {
  final int id;
  final String name;
  final String email;
  final String? profilePhotoUrl;

  Volunteer({
    required this.id,
    required this.name,
    required this.email,
    this.profilePhotoUrl,
  });

  factory Volunteer.fromJson(Map<String, dynamic> json) {
    return Volunteer(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profilePhotoUrl: json['profile']?['foto_profil'] != null
          ? LegislativeService.getProfilePhotoUrl(json['profile']['foto_profil'])
          : null,
    );
  }
}