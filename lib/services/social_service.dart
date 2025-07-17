import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';
import 'bantuan_sosial_service.dart';

class SocialService {
  // Get social data
  static Future<Map<String, dynamic>?> getSocialData() async {
    try {
      final response = await ApiService.get('/social');
      final data = ApiService.parseResponse(response);
      
      return data['data'] as Map<String, dynamic>?;
    } catch (e) {
      print('Error getting social data: $e');
      if (e.toString().contains('404') || e.toString().contains('No data found')) {
        return null; // No data found is normal for first-time users
      }
      throw Exception('Gagal mengambil data sosial: $e');
    }
  }
  
  // Add or update social data
  static Future<Map<String, dynamic>> saveSocialData({
    String? organisasi,
    String? jabatanOrganisasi,
    required bool aktifKegiatanSosial,
    String? jenisKegiatanSosial,
    String? keahlianKhusus,
    String? minatKegiatan,
    String? ketersediaanWaktu,
  }) async {
    try {
      // Get bantuan sosial history
      final bantuanHistory = await getBantuanSosialHistory();
      
      final data = {
        'organisasi': organisasi,
        'jabatan_organisasi': jabatanOrganisasi,
        'aktif_kegiatan_sosial': aktifKegiatanSosial,
        'jenis_kegiatan_sosial': jenisKegiatanSosial,
        'pernah_dapat_bantuan': bantuanHistory['pernah_dapat_bantuan'],
        'jenis_bantuan_diterima': bantuanHistory['jenis_bantuan_terakhir'],
        'tanggal_bantuan_terakhir': bantuanHistory['tanggal_bantuan_terakhir'],
        'keahlian_khusus': keahlianKhusus,
        'minat_kegiatan': minatKegiatan,
        'ketersediaan_waktu': ketersediaanWaktu ?? 'Fleksibel',
      };
      
      final response = await ApiService.post('/social', data);
      return ApiService.parseResponse(response);
    } catch (e) {
      print('Error saving social data: $e');
      throw Exception('Gagal menyimpan data sosial: $e');
    }
  }
  
  // Update social data
  static Future<Map<String, dynamic>> updateSocialData({
    required int id,
    String? organisasi,
    String? jabatanOrganisasi,
    required bool aktifKegiatanSosial,
    String? jenisKegiatanSosial,
    String? keahlianKhusus,
    String? minatKegiatan,
    String? ketersediaanWaktu,
  }) async {
    try {
      // Get bantuan sosial history
      final bantuanHistory = await getBantuanSosialHistory();
      
      final data = {
        'organisasi': organisasi,
        'jabatan_organisasi': jabatanOrganisasi,
        'aktif_kegiatan_sosial': aktifKegiatanSosial,
        'jenis_kegiatan_sosial': jenisKegiatanSosial,
        'pernah_dapat_bantuan': bantuanHistory['pernah_dapat_bantuan'],
        'jenis_bantuan_diterima': bantuanHistory['jenis_bantuan_terakhir'],
        'tanggal_bantuan_terakhir': bantuanHistory['tanggal_bantuan_terakhir'],
        'keahlian_khusus': keahlianKhusus,
        'minat_kegiatan': minatKegiatan,
        'ketersediaan_waktu': ketersediaanWaktu ?? 'Fleksibel',
      };
      
      final response = await ApiService.post('/social/$id', data);
      return ApiService.parseResponse(response);
    } catch (e) {
      print('Error updating social data: $e');
      throw Exception('Gagal mengupdate data sosial: $e');
    }
  }
  
  // Get social statistics
  static Future<Map<String, dynamic>> getSocialStatistics() async {
    try {
      final response = await ApiService.get('/social/statistics');
      final data = ApiService.parseResponse(response);
      
      return data['data'] ?? {};
    } catch (e) {
      print('Error getting social statistics: $e');
      return {};
    }
  }

  // Get bantuan sosial history from existing service
  static Future<Map<String, dynamic>> getBantuanSosialHistory() async {
    try {
      final result = await BantuanSosialService.getUserApplications();
      if (result['success']) {
        final applications = result['data'] as List<dynamic>;
        
        // Filter only approved applications
        final approvedApplications = applications.where((app) => 
          app['status'] == 'disetujui' || app['status'] == 'approved' || app['status'] == 'selesai'
        ).toList();
        
        return {
          'pernah_dapat_bantuan': approvedApplications.isNotEmpty,
          'jumlah_bantuan': approvedApplications.length,
          'applications': approvedApplications,
          'jenis_bantuan_terakhir': approvedApplications.isNotEmpty ? 
            (approvedApplications.last['bantuan_sosial'] != null ? 
              approvedApplications.last['bantuan_sosial']['nama_program'] : null) : null,
          'tanggal_bantuan_terakhir': approvedApplications.isNotEmpty ? 
            approvedApplications.last['created_at'] : null,
        };
      }
      return {
        'pernah_dapat_bantuan': false,
        'jumlah_bantuan': 0,
        'applications': [],
        'jenis_bantuan_terakhir': null,
        'tanggal_bantuan_terakhir': null,
      };
    } catch (e) {
      print('Error getting bantuan sosial history: $e');
      return {
        'pernah_dapat_bantuan': false,
        'jumlah_bantuan': 0,
        'applications': [],
        'jenis_bantuan_terakhir': null,
        'tanggal_bantuan_terakhir': null,
      };
    }
  }

  // Helper method to get social activity options
  static List<String> getKegiatanSosialOptions() {
    return [
      'Kegiatan Keagamaan',
      'Gotong Royong',
      'Posyandu',
      'Karang Taruna',
      'PKK',
      'Relawan Bencana',
      'Bakti Sosial',
      'Donor Darah',
      'Kerja Bakti',
      'Lainnya',
    ];
  }


  // Helper method to get special skills options
  static List<String> getKeahlianKhususOptions() {
    return [
      'Mengajar',
      'Komputer/IT',
      'Kesehatan',
      'Pertanian',
      'Kerajinan',
      'Memasak',
      'Musik/Seni',
      'Olahraga',
      'Bahasa Asing',
      'Keterampilan Teknis',
      'Lainnya',
    ];
  }

  // Helper method to get interest options
  static List<String> getMinatKegiatanOptions() {
    return [
      'Kegiatan Sosial',
      'Kegiatan Keagamaan',
      'Kegiatan Pendidikan',
      'Kegiatan Kesehatan',
      'Kegiatan Lingkungan',
      'Kegiatan Ekonomi',
      'Kegiatan Budaya',
      'Kegiatan Olahraga',
      'Kegiatan Teknologi',
      'Lainnya',
    ];
  }

  // Helper method to get availability options
  static List<String> getKetersediaanWaktuOptions() {
    return [
      'Weekday',
      'Weekend', 
      'Fleksibel',
      'Terbatas',
    ];
  }

  // Helper method to get social engagement level
  static Map<String, dynamic> getSocialEngagementLevel(Map<String, dynamic> socialData) {
    int score = 0;
    String level = '';
    Color color = Colors.grey;
    IconData icon = Icons.info;
    
    // Calculate score based on social activities
    if (socialData['aktif_kegiatan_sosial'] == true) score += 40;
    if (socialData['organisasi'] != null && socialData['organisasi'].toString().isNotEmpty) score += 25;
    if (socialData['jabatan_organisasi'] != null && socialData['jabatan_organisasi'].toString().isNotEmpty) score += 20;
    if (socialData['keahlian_khusus'] != null && socialData['keahlian_khusus'].toString().isNotEmpty) score += 15;
    
    // Determine level based on score
    if (score >= 80) {
      level = 'Sangat Aktif';
      color = Colors.green;
      icon = Icons.volunteer_activism;
    } else if (score >= 60) {
      level = 'Aktif';
      color = Colors.blue;
      icon = Icons.groups;
    } else if (score >= 40) {
      level = 'Cukup Aktif';
      color = Colors.orange;
      icon = Icons.group;
    } else if (score >= 20) {
      level = 'Kurang Aktif';
      color = Colors.red;
      icon = Icons.person;
    } else {
      level = 'Tidak Aktif';
      color = Colors.grey;
      icon = Icons.person_outline;
    }
    
    return {
      'score': score,
      'level': level,
      'color': color,
      'icon': icon,
    };
  }

  // Helper method to get social recommendations
  static List<String> getSocialRecommendations(Map<String, dynamic> socialData) {
    List<String> recommendations = [];
    
    final engagement = getSocialEngagementLevel(socialData);
    final score = engagement['score'] as int;
    
    if (score < 40) {
      recommendations.add('Mulai dengan kegiatan sosial sederhana di lingkungan sekitar');
      recommendations.add('Ikuti kegiatan gotong royong atau kerja bakti');
      recommendations.add('Bergabung dengan organisasi kemasyarakatan');
    } else if (score < 60) {
      recommendations.add('Tingkatkan partisipasi dalam kegiatan organisasi');
      recommendations.add('Ambil peran aktif dalam kegiatan sosial');
      recommendations.add('Manfaatkan keahlian khusus untuk membantu masyarakat');
    } else if (score < 80) {
      recommendations.add('Pertimbangkan untuk mengambil posisi kepemimpinan');
      recommendations.add('Inisiasi kegiatan sosial baru di lingkungan');
      recommendations.add('Mentoring untuk relawan baru');
    } else {
      recommendations.add('Terus pertahankan kontribusi positif Anda');
      recommendations.add('Bagikan pengalaman dan pengetahuan kepada orang lain');
      recommendations.add('Kembangkan program sosial yang lebih besar');
    }
    
    // Add specific recommendations based on interests
    if (socialData['minat_kegiatan'] != null) {
      final minat = socialData['minat_kegiatan'].toString();
      if (minat.contains('Pendidikan')) {
        recommendations.add('Pertimbangkan untuk menjadi tutor atau mentor');
      }
      if (minat.contains('Kesehatan')) {
        recommendations.add('Dukung program kesehatan masyarakat');
      }
      if (minat.contains('Lingkungan')) {
        recommendations.add('Ikuti kegiatan pelestarian lingkungan');
      }
    }
    
    return recommendations;
  }


  // Helper method to check if user has complete social data
  static bool hasCompleteSocialData(Map<String, dynamic>? socialData) {
    if (socialData == null) return false;
    
    // Check required fields
    final requiredFields = [
      'aktif_kegiatan_sosial',
    ];
    
    for (String field in requiredFields) {
      if (socialData[field] == null) return false;
    }
    
    // Check conditional fields
    if (socialData['aktif_kegiatan_sosial'] == true) {
      if (socialData['jenis_kegiatan_sosial'] == null || 
          socialData['jenis_kegiatan_sosial'].toString().isEmpty) {
        return false;
      }
    }
    
    return true;
  }
}