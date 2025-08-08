import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/social_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_dropdown_field.dart';
import '../widgets/custom_switch_field.dart';
import '../widgets/custom_date_field.dart';

class SocialFormScreen extends StatefulWidget {
  final Map<String, dynamic>? socialData;

  const SocialFormScreen({super.key, this.socialData});

  @override
  State<SocialFormScreen> createState() => _SocialFormScreenState();
}

class _SocialFormScreenState extends State<SocialFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _organisasiController = TextEditingController();
  final _jabatanController = TextEditingController();
  final _keahlianController = TextEditingController();
  
  bool _aktifKegiatanSosial = false;
  String? _jenisKegiatanSosial;
  String? _minatKegiatan;
  String? _ketersediaanWaktu;
  
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.socialData != null;
    _loadExistingData();
  }

  void _loadExistingData() {
    if (widget.socialData != null) {
      final data = widget.socialData!;
      
      _organisasiController.text = data['organisasi'] ?? '';
      _jabatanController.text = data['jabatan_organisasi'] ?? '';
      _keahlianController.text = data['keahlian_khusus'] ?? '';
      
      _aktifKegiatanSosial = data['aktif_kegiatan_sosial'] ?? false;
      _jenisKegiatanSosial = data['jenis_kegiatan_sosial'];
      _minatKegiatan = data['minat_kegiatan'];
      _ketersediaanWaktu = data['ketersediaan_waktu'] ?? 'Fleksibel';
    }
  }

  Future<void> _saveSocialData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        await SocialService.updateSocialData(
          id: widget.socialData!['id'],
          organisasi: _organisasiController.text.trim().isEmpty ? null : _organisasiController.text.trim(),
          jabatanOrganisasi: _jabatanController.text.trim().isEmpty ? null : _jabatanController.text.trim(),
          aktifKegiatanSosial: _aktifKegiatanSosial,
          jenisKegiatanSosial: _jenisKegiatanSosial,
          keahlianKhusus: _keahlianController.text.trim().isEmpty ? null : _keahlianController.text.trim(),
          minatKegiatan: _minatKegiatan,
          ketersediaanWaktu: _ketersediaanWaktu,
        );
      } else {
        await SocialService.saveSocialData(
          organisasi: _organisasiController.text.trim().isEmpty ? null : _organisasiController.text.trim(),
          jabatanOrganisasi: _jabatanController.text.trim().isEmpty ? null : _jabatanController.text.trim(),
          aktifKegiatanSosial: _aktifKegiatanSosial,
          jenisKegiatanSosial: _jenisKegiatanSosial,
          keahlianKhusus: _keahlianController.text.trim().isEmpty ? null : _keahlianController.text.trim(),
          minatKegiatan: _minatKegiatan,
          ketersediaanWaktu: _ketersediaanWaktu,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Data sosial berhasil diperbarui' : 'Data sosial berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan data sosial: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _organisasiController.dispose();
    _jabatanController.dispose();
    _keahlianController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Data Sosial' : 'Tambah Data Sosial',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFff5001),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeaderSection(),
              
              const SizedBox(height: 24),
              
              // Social Activity Section
              _buildSocialActivitySection(),
              
              const SizedBox(height: 24),
              
              // Organization Section
              _buildOrganizationSection(),
              
              const SizedBox(height: 24),
              
              // Skills & Interests Section
              _buildSkillsInterestsSection(),
              
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveSocialData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFff5001),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _isEditing ? 'Perbarui Data Sosial' : 'Simpan Data Sosial',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFff5001), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.groups,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEditing ? 'Edit Data Sosial' : 'Tambah Data Sosial',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Isi informasi aktivitas sosial dan keterlibatan masyarakat',
                      style: TextStyle(
                        color: Color(0xE6FFFFFF),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  'Step 4 dari 4',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialActivitySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.volunteer_activism,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Aktivitas Sosial',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          CustomSwitchField(
            label: 'Aktif dalam kegiatan sosial',
            value: _aktifKegiatanSosial,
            onChanged: (value) {
              setState(() {
                _aktifKegiatanSosial = value;
                if (!value) {
                  _jenisKegiatanSosial = null;
                }
              });
            },
          ),
          
          if (_aktifKegiatanSosial) ...[
            const SizedBox(height: 16),
            CustomDropdownField(
              label: 'Jenis Kegiatan Sosial',
              value: _jenisKegiatanSosial,
              items: SocialService.getKegiatanSosialOptions(),
              onChanged: (value) {
                setState(() {
                  _jenisKegiatanSosial = value;
                });
              },
              validator: (value) {
                if (_aktifKegiatanSosial && (value == null || value.isEmpty)) {
                  return 'Pilih jenis kegiatan sosial';
                }
                return null;
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrganizationSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFff5001).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.business,
                  color: Color(0xFFff5001),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Organisasi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _organisasiController,
            label: 'Nama Organisasi',
            hint: 'Masukkan nama organisasi (opsional)',
            prefixIcon: Icons.group,
          ),
          
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _jabatanController,
            label: 'Jabatan dalam Organisasi',
            hint: 'Masukkan jabatan (opsional)',
            prefixIcon: Icons.badge,
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsInterestsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.purple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Keahlian & Minat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _keahlianController,
            label: 'Keahlian Khusus',
            hint: 'Masukkan keahlian khusus (opsional)',
            prefixIcon: Icons.star,
            maxLines: 2,
          ),
          
          const SizedBox(height: 16),
          
          CustomDropdownField(
            label: 'Minat Kegiatan',
            value: _minatKegiatan,
            items: SocialService.getMinatKegiatanOptions(),
            onChanged: (value) {
              setState(() {
                _minatKegiatan = value;
              });
            },
            hint: 'Pilih minat kegiatan (opsional)',
          ),
          
          const SizedBox(height: 16),
          
          CustomDropdownField(
            label: 'Ketersediaan Waktu',
            value: _ketersediaanWaktu,
            items: SocialService.getKetersediaanWaktuOptions(),
            onChanged: (value) {
              setState(() {
                _ketersediaanWaktu = value;
              });
            },
            hint: 'Pilih ketersediaan waktu',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Pilih ketersediaan waktu';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}