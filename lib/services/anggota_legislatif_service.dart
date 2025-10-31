import 'api_service.dart';

class AnggotaLegislatif {
  final int id;
  final String kodeAleg;
  final String namaLengkap;
  final String? jabatanSaatIni;
  final String? fotoProfil;
  final String? partaiPolitik;
  final String? daerahPemilihan;

  AnggotaLegislatif({
    required this.id,
    required this.kodeAleg,
    required this.namaLengkap,
    this.jabatanSaatIni,
    this.fotoProfil,
    this.partaiPolitik,
    this.daerahPemilihan,
  });

  factory AnggotaLegislatif.fromJson(Map<String, dynamic> json) {
    return AnggotaLegislatif(
      id: json['id'] as int,
      kodeAleg: json['kode_aleg'] as String,
      namaLengkap: json['nama_lengkap'] as String,
      jabatanSaatIni: json['jabatan_saat_ini'] as String?,
      fotoProfil: json['foto_profil'] as String?,
      partaiPolitik: json['partai_politik'] as String?,
      daerahPemilihan: json['daerah_pemilihan'] as String?,
    );
  }

  String get displayName {
    if (jabatanSaatIni != null && jabatanSaatIni!.isNotEmpty) {
      return '$namaLengkap - $jabatanSaatIni';
    }
    return namaLengkap;
  }
}

class AnggotaLegislatifService {
  /// Get list of active anggota legislatif for dropdown options
  static Future<List<AnggotaLegislatif>> getOptions() async {
    try {
      print('=== Fetching Anggota Legislatif Options ===');
      final response = await ApiService.get('/anggota-legislatif/options');
      final data = ApiService.parseResponse(response);

      print('Response Status: ${data['status']}');

      if (data['status'] == 'success') {
        final List<dynamic> alegList = data['data'] as List<dynamic>;
        print('Found ${alegList.length} anggota legislatif');

        return alegList
            .map((json) => AnggotaLegislatif.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch anggota legislatif');
      }
    } catch (e) {
      print('Error fetching anggota legislatif options: $e');
      rethrow;
    }
  }

  /// Get single anggota legislatif by ID
  static Future<AnggotaLegislatif?> getById(int id) async {
    try {
      final response = await ApiService.get('/anggota-legislatif/$id');
      final data = ApiService.parseResponse(response);

      if (data['status'] == 'success' && data['data'] != null) {
        return AnggotaLegislatif.fromJson(data['data'] as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error fetching anggota legislatif by ID: $e');
      return null;
    }
  }
}
