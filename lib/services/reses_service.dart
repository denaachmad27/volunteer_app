import 'dart:convert';
import 'api_service.dart';

class ResesItem {
  final int id;
  final String judul;
  final String deskripsi;
  final String lokasi;
  final String tanggalMulai;
  final String tanggalSelesai;
  final String status;
  final String? fotoKegiatan;
  final int legislativeMemberId;
  final String? legislativeMemberName;
  final String? createdAt;
  final String? updatedAt;

  ResesItem({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.lokasi,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.status,
    this.fotoKegiatan,
    required this.legislativeMemberId,
    this.legislativeMemberName,
    this.createdAt,
    this.updatedAt,
  });

  factory ResesItem.fromJson(Map<String, dynamic> json) {
    return ResesItem(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      lokasi: json['lokasi'] ?? '',
      tanggalMulai: json['tanggal_mulai'] ?? '',
      tanggalSelesai: json['tanggal_selesai'] ?? '',
      status: json['status'] ?? 'scheduled',
      fotoKegiatan: json['foto_kegiatan'],
      legislativeMemberId: json['legislative_member_id'] ?? 0,
      legislativeMemberName: json['legislative_member_name'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class ResesResponse {
  final bool success;
  final String message;
  final List<ResesItem> data;
  final int? total;

  ResesResponse({
    required this.success,
    required this.message,
    required this.data,
    this.total,
  });

  factory ResesResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];

    return ResesResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: dataList.map((item) => ResesItem.fromJson(item as Map<String, dynamic>)).toList(),
      total: json['total'],
    );
  }
}

class ResesService {
  // Dummy data for demonstration
  static List<ResesItem> getDummyData() {
    final now = DateTime.now();

    return [
      // Scheduled reses
      ResesItem(
        id: 1,
        judul: 'Reses Masa Sidang I - Kecamatan Bandung Wetan',
        deskripsi: 'Kegiatan reses untuk menampung aspirasi masyarakat Kecamatan Bandung Wetan terkait pembangunan infrastruktur jalan dan fasilitas umum. Akan dihadiri oleh tokoh masyarakat dan RT/RW setempat.',
        lokasi: 'Aula Kecamatan Bandung Wetan, Kota Bandung',
        tanggalMulai: now.add(const Duration(days: 7)).toIso8601String(),
        tanggalSelesai: now.add(const Duration(days: 9)).toIso8601String(),
        status: 'scheduled',
        fotoKegiatan: null,
        legislativeMemberId: 1,
        legislativeMemberName: 'Dr. Budi Santoso, S.H., M.H.',
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      ),
      ResesItem(
        id: 2,
        judul: 'Reses Pendidikan - Kelurahan Cigadung',
        deskripsi: 'Dialog dengan para guru dan kepala sekolah membahas peningkatan kualitas pendidikan dan kebutuhan sarana prasarana sekolah di wilayah Cigadung.',
        lokasi: 'SDN 01 Cigadung, Kecamatan Cibeunying Kaler',
        tanggalMulai: now.add(const Duration(days: 14)).toIso8601String(),
        tanggalSelesai: now.add(const Duration(days: 14)).toIso8601String(),
        status: 'scheduled',
        fotoKegiatan: null,
        legislativeMemberId: 1,
        legislativeMemberName: 'Dr. Budi Santoso, S.H., M.H.',
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      ),

      // Ongoing reses
      ResesItem(
        id: 3,
        judul: 'Reses Kesehatan Masyarakat - RSUD Kota Bandung',
        deskripsi: 'Kunjungan ke RSUD Kota Bandung untuk membahas pelayanan kesehatan masyarakat, ketersediaan obat, dan peningkatan fasilitas rumah sakit. Diskusi dengan direktur RS dan tenaga medis.',
        lokasi: 'RSUD Kota Bandung, Jl. Rumah Sakit No. 22',
        tanggalMulai: now.subtract(const Duration(days: 1)).toIso8601String(),
        tanggalSelesai: now.add(const Duration(days: 2)).toIso8601String(),
        status: 'ongoing',
        fotoKegiatan: null,
        legislativeMemberId: 1,
        legislativeMemberName: 'Dr. Budi Santoso, S.H., M.H.',
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      ),
      ResesItem(
        id: 4,
        judul: 'Reses UMKM - Pasar Baru Bandung',
        deskripsi: 'Kunjungan ke para pedagang UMKM di Pasar Baru untuk mendengar keluhan dan aspirasi terkait revitalisasi pasar dan bantuan modal usaha.',
        lokasi: 'Pasar Baru Bandung, Kecamatan Sumur Bandung',
        tanggalMulai: now.toIso8601String(),
        tanggalSelesai: now.add(const Duration(days: 1)).toIso8601String(),
        status: 'ongoing',
        fotoKegiatan: null,
        legislativeMemberId: 1,
        legislativeMemberName: 'Dr. Budi Santoso, S.H., M.H.',
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      ),

      // Completed reses
      ResesItem(
        id: 5,
        judul: 'Reses Infrastruktur - Kelurahan Dago',
        deskripsi: 'Telah dilaksanakan reses membahas perbaikan jalan berlubang di Jl. Ir. H. Djuanda (Dago) dan pemasangan lampu jalan di gang-gang perumahan. Hasil: Disetujui perbaikan jalan dengan anggaran APBD 2024.',
        lokasi: 'Kelurahan Dago, Kecamatan Coblong',
        tanggalMulai: now.subtract(const Duration(days: 30)).toIso8601String(),
        tanggalSelesai: now.subtract(const Duration(days: 28)).toIso8601String(),
        status: 'completed',
        fotoKegiatan: null,
        legislativeMemberId: 1,
        legislativeMemberName: 'Dr. Budi Santoso, S.H., M.H.',
        createdAt: now.subtract(const Duration(days: 30)).toIso8601String(),
        updatedAt: now.subtract(const Duration(days: 28)).toIso8601String(),
      ),
      ResesItem(
        id: 6,
        judul: 'Reses Banjir - Kawasan Cicaheum',
        deskripsi: 'Reses darurat membahas penanganan banjir yang sering terjadi di kawasan Cicaheum. Dihadiri warga, lurah, dan dinas terkait. Menghasilkan kesepakatan normalisasi saluran air.',
        lokasi: 'Kelurahan Cicaheum, Kecamatan Kiaracondong',
        tanggalMulai: now.subtract(const Duration(days: 45)).toIso8601String(),
        tanggalSelesai: now.subtract(const Duration(days: 44)).toIso8601String(),
        status: 'completed',
        fotoKegiatan: null,
        legislativeMemberId: 1,
        legislativeMemberName: 'Dr. Budi Santoso, S.H., M.H.',
        createdAt: now.subtract(const Duration(days: 45)).toIso8601String(),
        updatedAt: now.subtract(const Duration(days: 44)).toIso8601String(),
      ),
      ResesItem(
        id: 7,
        judul: 'Reses Pemuda dan Olahraga - GOR Pajajaran',
        deskripsi: 'Pertemuan dengan komunitas olahraga dan pemuda membahas revitalisasi GOR Pajajaran dan program pembinaan atlet muda. Kesepakatan: Renovasi GOR dimulai Q2 2024.',
        lokasi: 'GOR Pajajaran, Jl. Pajajaran Kota Bandung',
        tanggalMulai: now.subtract(const Duration(days: 60)).toIso8601String(),
        tanggalSelesai: now.subtract(const Duration(days: 59)).toIso8601String(),
        status: 'completed',
        fotoKegiatan: null,
        legislativeMemberId: 1,
        legislativeMemberName: 'Dr. Budi Santoso, S.H., M.H.',
        createdAt: now.subtract(const Duration(days: 60)).toIso8601String(),
        updatedAt: now.subtract(const Duration(days: 59)).toIso8601String(),
      ),

      // Cancelled reses
      ResesItem(
        id: 8,
        judul: 'Reses Transportasi - Terminal Leuwi Panjang',
        deskripsi: 'Reses dibatalkan karena bentrok dengan agenda DPRD. Akan dijadwalkan ulang minggu depan untuk membahas sistem transportasi umum dan angkutan online.',
        lokasi: 'Terminal Leuwi Panjang, Kecamatan Bojongloa Kidul',
        tanggalMulai: now.subtract(const Duration(days: 3)).toIso8601String(),
        tanggalSelesai: now.subtract(const Duration(days: 2)).toIso8601String(),
        status: 'cancelled',
        fotoKegiatan: null,
        legislativeMemberId: 1,
        legislativeMemberName: 'Dr. Budi Santoso, S.H., M.H.',
        createdAt: now.subtract(const Duration(days: 10)).toIso8601String(),
        updatedAt: now.subtract(const Duration(days: 3)).toIso8601String(),
      ),
    ];
  }

  static Future<ResesResponse> getResesList({String? status}) async {
    try {
      String endpoint = '/reses';
      if (status != null && status.isNotEmpty) {
        endpoint += '?status=$status';
      }

      final response = await ApiService.get(endpoint);

      print('=== RESES SERVICE: Response received ===');
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ResesResponse.fromJson(jsonData);
      } else {
        // Return empty list if API fails
        print('=== RESES SERVICE: API failed, returning empty list ===');
        return ResesResponse(
          success: false,
          message: 'Failed to load data',
          data: [],
        );
      }
    } catch (e) {
      print('=== RESES SERVICE: Error, returning empty list ===');
      print('Error: $e');
      // Return empty list on error
      return ResesResponse(
        success: false,
        message: 'Error: $e',
        data: [],
      );
    }
  }

  static Future<ResesItem?> getResesDetail(int id) async {
    try {
      final response = await ApiService.get('/reses/$id');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return ResesItem.fromJson(jsonData['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error getting reses detail: $e');
      return null;
    }
  }

  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }

    // If it's already a full URL, return it
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    // Otherwise, construct the full URL
    final baseUrl = ApiService.baseUrl.replaceAll('/api', '');
    return '$baseUrl/storage/$imagePath';
  }

  static String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '';
    }

    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
      ];

      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  static int getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return 0xFF2196F3; // Blue
      case 'ongoing':
        return 0xFFFF9800; // Orange
      case 'completed':
        return 0xFF4CAF50; // Green
      case 'cancelled':
        return 0xFFF44336; // Red
      default:
        return 0xFF9E9E9E; // Grey
    }
  }

  static String getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return 'Dijadwalkan';
      case 'ongoing':
        return 'Berlangsung';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }
}
