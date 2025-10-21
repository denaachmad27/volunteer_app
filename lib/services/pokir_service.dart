import 'dart:convert';
import 'api_service.dart';

class PokirItem {
  final int id;
  final String judul;
  final String deskripsi;
  final String kategori;
  final String prioritas;
  final String status;
  final String? lokasiPelaksanaan;
  final String? targetPelaksanaan;
  final int legislativeMemberId;
  final String? legislativeMemberName;
  final String? createdAt;
  final String? updatedAt;

  PokirItem({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.kategori,
    required this.prioritas,
    required this.status,
    this.lokasiPelaksanaan,
    this.targetPelaksanaan,
    required this.legislativeMemberId,
    this.legislativeMemberName,
    this.createdAt,
    this.updatedAt,
  });

  factory PokirItem.fromJson(Map<String, dynamic> json) {
    return PokirItem(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      kategori: json['kategori'] ?? '',
      prioritas: json['prioritas'] ?? 'medium',
      status: json['status'] ?? 'proposed',
      lokasiPelaksanaan: json['lokasi_pelaksanaan'],
      targetPelaksanaan: json['target_pelaksanaan'],
      legislativeMemberId: json['legislative_member_id'] ?? 0,
      legislativeMemberName: json['legislative_member_name'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class PokirResponse {
  final bool success;
  final String message;
  final List<PokirItem> data;
  final int? total;

  PokirResponse({
    required this.success,
    required this.message,
    required this.data,
    this.total,
  });

  factory PokirResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];

    return PokirResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: dataList.map((item) => PokirItem.fromJson(item as Map<String, dynamic>)).toList(),
      total: json['total'],
    );
  }
}

class PokirService {
  // Dummy data for demonstration
  static List<PokirItem> getDummyData() {
    final now = DateTime.now();

    return [
      // Proposed pokir
      PokirItem(
        id: 1,
        judul: 'Pembangunan Taman Kota di Kelurahan Dago',
        deskripsi: 'Usulan pembangunan taman kota seluas 2 hektar di Kelurahan Dago untuk area rekreasi keluarga dan ruang terbuka hijau. Taman akan dilengkapi dengan jogging track, area bermain anak, dan gazebo.',
        kategori: 'Lingkungan',
        prioritas: 'high',
        status: 'proposed',
        lokasiPelaksanaan: 'Jl. Ir. H. Djuanda (Dago), Kota Bandung',
        targetPelaksanaan: now.add(const Duration(days: 90)).toIso8601String(),
        legislativeMemberId: 1,
        legislativeMemberName: 'Dr. Budi Santoso, S.H., M.H.',
        createdAt: now.subtract(const Duration(days: 5)).toIso8601String(),
        updatedAt: now.subtract(const Duration(days: 5)).toIso8601String(),
      ),
      PokirItem(
        id: 2,
        judul: 'Program Beasiswa Siswa Berprestasi Kota Bandung',
        deskripsi: 'Usulan program beasiswa untuk 100 siswa berprestasi dari keluarga kurang mampu di Kota Bandung. Beasiswa mencakup biaya pendidikan, buku, dan seragam selama 1 tahun ajaran.',
        kategori: 'Pendidikan',
        prioritas: 'high',
        status: 'proposed',
        lokasiPelaksanaan: 'Seluruh kecamatan di Kota Bandung',
        targetPelaksanaan: now.add(const Duration(days: 60)).toIso8601String(),
        legislativeMemberId: 1,
        legislativeMemberName: 'Dr. Budi Santoso, S.H., M.H.',
        createdAt: now.subtract(const Duration(days: 3)).toIso8601String(),
        updatedAt: now.subtract(const Duration(days: 3)).toIso8601String(),
      ),
      PokirItem(
        id: 3,
        judul: 'Perbaikan Sistem Drainase di Buah Batu',
        deskripsi: 'Usulan normalisasi dan perbaikan sistem drainase untuk mengatasi banjir yang sering terjadi di kawasan Buah Batu terutama saat musim hujan.',
        kategori: 'Infrastruktur',
        prioritas: 'medium',
        status: 'proposed',
        lokasiPelaksanaan: 'Kecamatan Buah Batu, Kota Bandung',
        targetPelaksanaan: now.add(const Duration(days: 120)).toIso8601String(),
        legislativeMemberId: 1,
        legislativeMemberName: 'Dr. Budi Santoso, S.H., M.H.',
        createdAt: now.subtract(const Duration(days: 7)).toIso8601String(),
        updatedAt: now.subtract(const Duration(days: 7)).toIso8601String(),
      ),

      // Approved pokir
      PokirItem(
        id: 4,
        judul: 'Pengadaan Ambulans untuk Puskesmas Kelurahan',
        deskripsi: 'Pengadaan 5 unit ambulans untuk puskesmas kelurahan di Kota Bandung guna meningkatkan pelayanan kesehatan darurat masyarakat. Telah disetujui dalam rapat komisi.',
        kategori: 'Kesehatan',
        prioritas: 'high',
        status: 'approved',
        lokasiPelaksanaan: '5 Puskesmas Kelurahan di Kota Bandung',
        targetPelaksanaan: now.add(const Duration(days: 30)).toIso8601String(),
        legislativeMemberId: 1,
        legislativeMemberName: 'Dr. Budi Santoso, S.H., M.H.',
        createdAt: now.subtract(const Duration(days: 20)).toIso8601String(),
        updatedAt: now.subtract(const Duration(days: 2)).toIso8601String(),
      ),
      PokirItem(
        id: 5,
        judul: 'Pelatihan Kewirausahaan untuk UMKM Bandung',
        deskripsi: 'Program pelatihan dan pendampingan kewirausahaan untuk 200 pelaku UMKM mencakup digital marketing, manajemen keuangan, dan akses permodalan.',
        kategori: 'Ekonomi',
        prioritas: 'medium',
        status: 'approved',
        lokasiPelaksanaan: 'Gedung Serbaguna Tegallega, Kota Bandung',
        targetPelaksanaan: now.add(const Duration(days: 45)).toIso8601String(),
        legislativeMemberId: 1,
        legislativeMemberName: 'Dr. Budi Santoso, S.H., M.H.',
        createdAt: now.subtract(const Duration(days: 15)).toIso8601String(),
        updatedAt: now.subtract(const Duration(days: 1)).toIso8601String(),
      ),

      // In Progress pokir
      PokirItem(
        id: 6,
        judul: 'Revitalisasi Pasar Tradisional Kosambi',
        deskripsi: 'Sedang dalam proses revitalisasi pasar tradisional dengan perbaikan kios, sistem sanitasi, dan pengadaan tempat parkir. Progress saat ini 45%.',
        kategori: 'Ekonomi',
        prioritas: 'high',
        status: 'in_progress',
        lokasiPelaksanaan: 'Pasar Kosambi, Kecamatan Bandung Barat',
        targetPelaksanaan: now.add(const Duration(days: 60)).toIso8601String(),
        legislativeMemberId: 1,
        legislativeMemberName: 'Dr. Budi Santoso, S.H., M.H.',
        createdAt: now.subtract(const Duration(days: 40)).toIso8601String(),
        updatedAt: now.toIso8601String(),
      ),
      PokirItem(
        id: 7,
        judul: 'Perbaikan Jalan dan Trotoar di Pasteur',
        deskripsi: 'Proyek perbaikan jalan berlubang sepanjang 2 km dan pembangunan trotoar ramah pejalan kaki di kawasan Pasteur. Saat ini dalam tahap pengerjaan fisik.',
        kategori: 'Infrastruktur',
        prioritas: 'high',
        status: 'in_progress',
        lokasiPelaksanaan: 'Jl. Dr. Djunjunan (Pasteur), Kota Bandung',
        targetPelaksanaan: now.add(const Duration(days: 30)).toIso8601String(),
        legislativeMemberId: 1,
        legislativeMemberName: 'Dr. Budi Santoso, S.H., M.H.',
        createdAt: now.subtract(const Duration(days: 30)).toIso8601String(),
        updatedAt: now.toIso8601String(),
      ),
      PokirItem(
        id: 8,
        judul: 'Program Posyandu Lansia Kota Bandung',
        deskripsi: 'Implementasi program posyandu lansia di 10 kelurahan dengan pemeriksaan kesehatan rutin, senam lansia, dan edukasi pola hidup sehat. Sudah berjalan di 6 kelurahan.',
        kategori: 'Kesehatan',
        prioritas: 'medium',
        status: 'in_progress',
        lokasiPelaksanaan: '10 Kelurahan di Kota Bandung',
        targetPelaksanaan: now.add(const Duration(days: 20)).toIso8601String(),
        legislativeMemberId: 1,
        legislativeMemberName: 'Dr. Budi Santoso, S.H., M.H.',
        createdAt: now.subtract(const Duration(days: 25)).toIso8601String(),
        updatedAt: now.subtract(const Duration(days: 1)).toIso8601String(),
      ),

      // Completed pokir
      PokirItem(
        id: 9,
        judul: 'Pengadaan Laptop untuk Sekolah di Bandung',
        deskripsi: 'Telah selesai pengadaan 100 unit laptop untuk 10 sekolah dasar negeri guna mendukung pembelajaran digital dan literasi teknologi siswa.',
        kategori: 'Pendidikan',
        prioritas: 'high',
        status: 'completed',
        lokasiPelaksanaan: '10 SDN di Kota Bandung',
        targetPelaksanaan: now.subtract(const Duration(days: 10)).toIso8601String(),
        legislativeMemberId: 1,
        legislativeMemberName: 'Dr. Budi Santoso, S.H., M.H.',
        createdAt: now.subtract(const Duration(days: 90)).toIso8601String(),
        updatedAt: now.subtract(const Duration(days: 10)).toIso8601String(),
      ),
      PokirItem(
        id: 10,
        judul: 'Pemasangan CCTV di Kawasan Alun-Alun Bandung',
        deskripsi: 'Telah terpasang 50 unit CCTV di titik-titik rawan kejahatan dan keramaian untuk meningkatkan keamanan dan ketertiban masyarakat.',
        kategori: 'Sosial',
        prioritas: 'high',
        status: 'completed',
        lokasiPelaksanaan: 'Kawasan Alun-Alun dan Braga, Kota Bandung',
        targetPelaksanaan: now.subtract(const Duration(days: 15)).toIso8601String(),
        legislativeMemberId: 1,
        legislativeMemberName: 'Dr. Budi Santoso, S.H., M.H.',
        createdAt: now.subtract(const Duration(days: 75)).toIso8601String(),
        updatedAt: now.subtract(const Duration(days: 15)).toIso8601String(),
      ),
      PokirItem(
        id: 11,
        judul: 'Renovasi GOR Pajajaran dan Lapangan Olahraga',
        deskripsi: 'Renovasi GOR Pajajaran dan 3 lapangan olahraga kelurahan telah selesai dilaksanakan. Fasilitas kini lebih layak dan nyaman untuk kegiatan olahraga masyarakat.',
        kategori: 'Sosial',
        prioritas: 'medium',
        status: 'completed',
        lokasiPelaksanaan: 'GOR Pajajaran dan lapangan kelurahan Kota Bandung',
        targetPelaksanaan: now.subtract(const Duration(days: 30)).toIso8601String(),
        legislativeMemberId: 1,
        legislativeMemberName: 'Dr. Budi Santoso, S.H., M.H.',
        createdAt: now.subtract(const Duration(days: 120)).toIso8601String(),
        updatedAt: now.subtract(const Duration(days: 30)).toIso8601String(),
      ),
      PokirItem(
        id: 12,
        judul: 'Bank Sampah Kelurahan Kota Bandung',
        deskripsi: 'Program bank sampah telah berhasil diimplementasikan di 8 kelurahan dengan partisipasi 500 keluarga. Mengurangi volume sampah hingga 30%.',
        kategori: 'Lingkungan',
        prioritas: 'medium',
        status: 'completed',
        lokasiPelaksanaan: '8 Kelurahan di Kota Bandung',
        targetPelaksanaan: now.subtract(const Duration(days: 45)).toIso8601String(),
        legislativeMemberId: 1,
        legislativeMemberName: 'Dr. Budi Santoso, S.H., M.H.',
        createdAt: now.subtract(const Duration(days: 150)).toIso8601String(),
        updatedAt: now.subtract(const Duration(days: 45)).toIso8601String(),
      ),

      // Rejected pokir
      PokirItem(
        id: 13,
        judul: 'Pembangunan Flyover di Kopo',
        deskripsi: 'Usulan pembangunan flyover ditolak karena keterbatasan anggaran dan dampak lingkungan. Alternatif solusi: optimalisasi traffic light dan rekayasa lalu lintas.',
        kategori: 'Infrastruktur',
        prioritas: 'low',
        status: 'rejected',
        lokasiPelaksanaan: 'Persimpangan Kopo, Kota Bandung',
        targetPelaksanaan: null,
        legislativeMemberId: 1,
        legislativeMemberName: 'Dr. Budi Santoso, S.H., M.H.',
        createdAt: now.subtract(const Duration(days: 60)).toIso8601String(),
        updatedAt: now.subtract(const Duration(days: 20)).toIso8601String(),
      ),
    ];
  }

  static Future<PokirResponse> getPokirList({String? kategori, String? status}) async {
    try {
      String endpoint = '/pokir';
      List<String> params = [];

      if (kategori != null && kategori.isNotEmpty) {
        params.add('kategori=$kategori');
      }
      if (status != null && status.isNotEmpty) {
        params.add('status=$status');
      }

      if (params.isNotEmpty) {
        endpoint += '?${params.join('&')}';
      }

      final response = await ApiService.get(endpoint);

      print('=== POKIR SERVICE: Response received ===');
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return PokirResponse.fromJson(jsonData);
      } else {
        // Return empty list if API fails
        print('=== POKIR SERVICE: API failed, returning empty list ===');
        return PokirResponse(
          success: false,
          message: 'Failed to load data',
          data: [],
        );
      }
    } catch (e) {
      print('=== POKIR SERVICE: Error, returning empty list ===');
      print('Error: $e');
      // Return empty list on error
      return PokirResponse(
        success: false,
        message: 'Error: $e',
        data: [],
      );
    }
  }

  static Future<PokirItem?> getPokirDetail(int id) async {
    try {
      final response = await ApiService.get('/pokir/$id');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return PokirItem.fromJson(jsonData['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error getting pokir detail: $e');
      return null;
    }
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

  static int getPrioritasColor(String prioritas) {
    switch (prioritas.toLowerCase()) {
      case 'high':
        return 0xFFF44336; // Red
      case 'medium':
        return 0xFFFF9800; // Orange
      case 'low':
        return 0xFF4CAF50; // Green
      default:
        return 0xFF9E9E9E; // Grey
    }
  }

  static String getPrioritasLabel(String prioritas) {
    switch (prioritas.toLowerCase()) {
      case 'high':
        return 'Tinggi';
      case 'medium':
        return 'Sedang';
      case 'low':
        return 'Rendah';
      default:
        return prioritas;
    }
  }

  static int getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'proposed':
        return 0xFF2196F3; // Blue
      case 'approved':
        return 0xFF4CAF50; // Green
      case 'in_progress':
        return 0xFFFF9800; // Orange
      case 'completed':
        return 0xFF009688; // Teal
      case 'rejected':
        return 0xFFF44336; // Red
      default:
        return 0xFF9E9E9E; // Grey
    }
  }

  static String getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'proposed':
        return 'Diusulkan';
      case 'approved':
        return 'Disetujui';
      case 'in_progress':
        return 'Dalam Proses';
      case 'completed':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  static int getCategoryColor(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'infrastruktur':
        return 0xFF795548; // Brown
      case 'pendidikan':
        return 0xFF2196F3; // Blue
      case 'kesehatan':
        return 0xFF4CAF50; // Green
      case 'ekonomi':
        return 0xFFFF9800; // Orange
      case 'sosial':
        return 0xFF9C27B0; // Purple
      case 'lingkungan':
        return 0xFF009688; // Teal
      default:
        return 0xFF607D8B; // Blue Grey
    }
  }

  static String getCategoryLabel(String kategori) {
    // Return the kategori as is, just capitalize first letter
    if (kategori.isEmpty) return kategori;
    return kategori[0].toUpperCase() + kategori.substring(1);
  }
}
