import 'dart:convert';
import 'api_service.dart';

class AlegDashboardStats {
  final int totalRelawan;
  final int totalWarga;
  final List<Map<String, dynamic>> wargaPerRelawan;

  AlegDashboardStats({
    required this.totalRelawan,
    required this.totalWarga,
    required this.wargaPerRelawan,
  });

  factory AlegDashboardStats.fromJson(Map<String, dynamic> json) {
    return AlegDashboardStats(
      totalRelawan: json['total_relawan'] ?? 0,
      totalWarga: json['total_warga'] ?? 0,
      wargaPerRelawan: (json['warga_per_relawan'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          [],
    );
  }
}

class AlegDashboardService {
  static Future<AlegDashboardStats> getStats() async {
    final response = await ApiService.get('/dashboard/aleg');
    final parsed = ApiService.parseResponse(response);
    if (parsed['status'] == 'success') {
      return AlegDashboardStats.fromJson(parsed['data'] ?? {});
    }
    throw Exception(parsed['message'] ?? 'Gagal memuat data dashboard aleg');
  }
}

