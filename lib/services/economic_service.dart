import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';

class EconomicService {
  // Get economic data
  static Future<Map<String, dynamic>?> getEconomicData() async {
    try {
      final response = await ApiService.get('/economic');
      final data = ApiService.parseResponse(response);
      
      return data['data'];
    } catch (e) {
      print('Error getting economic data: $e');
      
      // If it's 404, it means no data exists yet (not an error)
      if (e.toString().contains('404') || e.toString().contains('not found')) {
        return null; // Return null for no data, don't throw error
      }
      
      // For other errors, still throw
      throw Exception('Gagal mengambil data ekonomi: $e');
    }
  }
  
  // Create or update economic data
  static Future<Map<String, dynamic>> createOrUpdateEconomicData({
    required double penghasilanBulanan,
    required double pengeluaranBulanan,
    required String statusRumah,
    required String jenisRumah,
    required bool punyaKendaraan,
    String? jenisKendaraan,
    required bool punyaTabungan,
    double? jumlahTabungan,
    required bool punyaHutang,
    double? jumlahHutang,
    String? sumberPenghasilanLain,
  }) async {
    try {
      final data = {
        'penghasilan_bulanan': penghasilanBulanan,
        'pengeluaran_bulanan': pengeluaranBulanan,
        'status_rumah': statusRumah,
        'jenis_rumah': jenisRumah,
        'punya_kendaraan': punyaKendaraan,
        'jenis_kendaraan': jenisKendaraan,
        'punya_tabungan': punyaTabungan,
        'jumlah_tabungan': jumlahTabungan,
        'punya_hutang': punyaHutang,
        'jumlah_hutang': jumlahHutang,
        'sumber_penghasilan_lain': sumberPenghasilanLain,
      };
      
      final response = await ApiService.post('/economic', data);
      return ApiService.parseResponse(response);
    } catch (e) {
      print('Error creating/updating economic data: $e');
      throw Exception('Gagal menyimpan data ekonomi: $e');
    }
  }
  
  // Get economic analysis
  static Future<Map<String, dynamic>> getEconomicAnalysis() async {
    try {
      final response = await ApiService.get('/economic/analysis');
      final data = ApiService.parseResponse(response);
      
      return data['data'] ?? {};
    } catch (e) {
      print('Error getting economic analysis: $e');
      throw Exception('Gagal mengambil analisis ekonomi: $e');
    }
  }
  
  // Calculate economic status
  static Map<String, dynamic> calculateEconomicStatus(double penghasilan, double pengeluaran) {
    final sisa = penghasilan - pengeluaran;
    String status;
    Color statusColor;
    IconData statusIcon;
    
    if (sisa > 0) {
      status = 'Surplus';
      statusColor = const Color(0xFF10B981); // Green
      statusIcon = Icons.trending_up;
    } else if (sisa == 0) {
      status = 'Seimbang';
      statusColor = const Color(0xFFF59E0B); // Yellow
      statusIcon = Icons.trending_flat;
    } else {
      status = 'Defisit';
      statusColor = const Color(0xFFEF4444); // Red
      statusIcon = Icons.trending_down;
    }
    
    return {
      'status': status,
      'sisa_penghasilan': sisa,
      'color': statusColor,
      'icon': statusIcon,
      'percentage': penghasilan > 0.0 ? (sisa / penghasilan * 100.0) : 0.0,
    };
  }
  
  // Validation helpers
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName harus diisi';
    }
    return null;
  }
  
  static String? validateCurrency(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName harus diisi';
    }
    
    final amount = parseCurrency(value);
    if (amount < 0) {
      return '$fieldName tidak boleh negatif';
    }
    
    if (amount == 0) {
      return '$fieldName harus lebih dari 0';
    }
    
    return null;
  }
  
  static String? validateOptionalCurrency(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    
    final amount = parseCurrency(value);
    if (amount < 0) {
      return '$fieldName tidak boleh negatif';
    }
    
    return null;
  }
  
  // Format currency for display
  static String formatCurrency(double amount) {
    if (amount == 0) return 'Rp 0';
    
    final formatter = NumberFormat('#,###', 'id_ID');
    return 'Rp ${formatter.format(amount)}';
  }
  
  // Parse currency from string
  static double parseCurrency(String value) {
    if (value.isEmpty) return 0.0;
    
    // Remove currency symbols and keep only digits and separators
    String cleanValue = value.replaceAll(RegExp(r'[^\d,.]'), '');
    
    // Handle Indonesian format where dots are used as thousand separators
    // Example: "3.000.000" should become "3000000"
    // Remove all dots and commas as they are thousand separators
    cleanValue = cleanValue.replaceAll('.', '').replaceAll(',', '');
    
    final result = double.tryParse(cleanValue) ?? 0.0;
    print('Currency parsing: "$value" -> cleaned: "$cleanValue" -> result: $result');
    return result;
  }
  
  // Format percentage
  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }
  
  // Get status message
  static String getStatusMessage(String status, double percentage) {
    switch (status) {
      case 'Surplus':
        if (percentage > 50) {
          return 'Kondisi keuangan sangat baik! Anda memiliki surplus yang tinggi.';
        } else if (percentage > 20) {
          return 'Kondisi keuangan baik. Anda memiliki sisa penghasilan yang cukup.';
        } else {
          return 'Kondisi keuangan cukup baik, namun surplus masih kecil.';
        }
      case 'Seimbang':
        return 'Penghasilan dan pengeluaran seimbang. Pertimbangkan untuk menabung.';
      case 'Defisit':
        if (percentage.abs() > 50) {
          return 'Kondisi keuangan perlu perhatian serius. Defisit sangat tinggi.';
        } else if (percentage.abs() > 20) {
          return 'Kondisi keuangan kurang baik. Perlu mengurangi pengeluaran.';
        } else {
          return 'Sedikit defisit. Pertimbangkan untuk mengatur ulang anggaran.';
        }
      default:
        return 'Status ekonomi tidak diketahui.';
    }
  }
  
  // Get financial advice
  static List<String> getFinancialAdvice(Map<String, dynamic> economicStatus, Map<String, dynamic> economicData) {
    final List<String> advice = [];
    final status = economicStatus['status'];
    final percentage = economicStatus['percentage'];
    
    // Based on economic status
    if (status == 'Surplus') {
      advice.add('💰 Alokasikan sebagian surplus untuk tabungan dan investasi');
      if (!(economicData['punya_tabungan'] ?? false)) {
        advice.add('🏦 Pertimbangkan untuk membuka rekening tabungan');
      }
    } else if (status == 'Defisit') {
      advice.add('⚠️ Evaluasi pengeluaran bulanan dan cari area yang bisa dikurangi');
      advice.add('💼 Pertimbangkan mencari sumber penghasilan tambahan');
    }
    
    // Based on assets
    if (economicData['status_rumah'] == 'Sewa' || economicData['status_rumah'] == 'Kontrak') {
      advice.add('🏠 Pertimbangkan untuk menabung untuk rumah sendiri di masa depan');
    }
    
    // Based on debt
    if (economicData['punya_hutang'] == true) {
      advice.add('📉 Prioritaskan pelunasan hutang untuk mengurangi beban finansial');
    }
    
    // Based on savings
    if (!(economicData['punya_tabungan'] ?? false)) {
      advice.add('💳 Mulai menabung minimal 10% dari penghasilan bulanan');
    }
    
    // General advice
    if (advice.isEmpty) {
      advice.add('📊 Terus pantau kondisi keuangan Anda secara berkala');
      advice.add('📈 Pertimbangkan untuk membuat rencana keuangan jangka panjang');
    }
    
    return advice;
  }
  
  // Dropdown options
  static const List<String> statusRumahOptions = [
    'Milik Sendiri', 'Sewa', 'Kontrak', 'Menumpang', 'Dinas'
  ];
  
  static const List<String> jenisRumahOptions = [
    'Rumah Permanen', 'Rumah Semi Permanen', 'Rumah Kayu', 
    'Apartemen', 'Kontrakan', 'Kos', 'Lainnya'
  ];
  
  static const List<String> jenisKendaraanOptions = [
    'Motor', 'Mobil', 'Motor dan Mobil', 'Sepeda', 'Lainnya'
  ];
  
  // Get status icon
  static IconData getStatusIcon(String status) {
    switch (status) {
      case 'Surplus':
        return Icons.trending_up;
      case 'Seimbang':
        return Icons.trending_flat;
      case 'Defisit':
        return Icons.trending_down;
      default:
        return Icons.help_outline;
    }
  }
  
  // Get status color
  static Color getStatusColor(String status) {
    switch (status) {
      case 'Surplus':
        return const Color(0xFF10B981); // Green
      case 'Seimbang':
        return const Color(0xFFF59E0B); // Yellow
      case 'Defisit':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }
  
  // Get asset icon
  static IconData getAssetIcon(String type) {
    switch (type.toLowerCase()) {
      case 'rumah':
      case 'milik sendiri':
        return Icons.home;
      case 'sewa':
      case 'kontrak':
        return Icons.home_outlined;
      case 'kendaraan':
      case 'motor':
        return Icons.motorcycle;
      case 'mobil':
        return Icons.directions_car;
      case 'tabungan':
        return Icons.savings;
      case 'hutang':
        return Icons.money_off;
      default:
        return Icons.account_balance_wallet;
    }
  }
}