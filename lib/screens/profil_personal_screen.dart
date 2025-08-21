import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../services/profile_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_dropdown_field.dart';
import '../widgets/custom_date_field.dart';
import '../widgets/profile_photo_picker.dart';

class ProfilPersonalScreen extends StatefulWidget {
  const ProfilPersonalScreen({super.key});

  @override
  State<ProfilPersonalScreen> createState() => _ProfilPersonalScreenState();
}

class _ProfilPersonalScreenState extends State<ProfilPersonalScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Form controllers
  final _nikController = TextEditingController();
  final _namaLengkapController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  final _alamatController = TextEditingController();
  final _kelurahanController = TextEditingController();
  final _kecamatanController = TextEditingController();
  final _kotaController = TextEditingController();
  final _provinsiController = TextEditingController();
  final _kodePosController = TextEditingController();
  final _pekerjaanController = TextEditingController();

  // Dropdown values
  String? _jenisKelamin;
  String? _agama;
  String? _statusPernikahan;
  String? _pendidikanTerakhir;

  // Other state
  File? _selectedPhoto;
  bool _isLoading = false;
  bool _isSaving = false;
  Map<String, dynamic>? _existingProfile;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadExistingProfile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh profile data when returning to this screen
    if (mounted) {
      _loadExistingProfile();
    }
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  Future<void> _loadExistingProfile() async {
    setState(() => _isLoading = true);

    try {
      final profile = await ProfileService.getProfile();
      if (profile != null && mounted) {
        print('ProfilPersonal: Profile loaded with foto_profil: ${profile['foto_profil']}');
        _populateFormWithExistingData(profile);
      }
    } catch (e) {
      if (mounted) {
        print('Profile not found or error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _populateFormWithExistingData(Map<String, dynamic> profile) {
    setState(() {
      _existingProfile = profile;
      _nikController.text = profile['nik'] ?? '';
      _namaLengkapController.text = profile['nama_lengkap'] ?? '';
      _jenisKelamin = profile['jenis_kelamin'];
      _tempatLahirController.text = profile['tempat_lahir'] ?? '';
      _tanggalLahirController.text = profile['tanggal_lahir'] ?? '';
      _alamatController.text = profile['alamat'] ?? '';
      _kelurahanController.text = profile['kelurahan'] ?? '';
      _kecamatanController.text = profile['kecamatan'] ?? '';
      _kotaController.text = profile['kota'] ?? '';
      _provinsiController.text = profile['provinsi'] ?? '';
      _kodePosController.text = profile['kode_pos'] ?? '';
      _agama = profile['agama'];
      _statusPernikahan = profile['status_pernikahan'];
      _pendidikanTerakhir = profile['pendidikan_terakhir'];
      _pekerjaanController.text = profile['pekerjaan'] ?? '';
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // Save profile data
      await ProfileService.createOrUpdateProfile(
        nik: _nikController.text,
        namaLengkap: _namaLengkapController.text,
        jenisKelamin: _jenisKelamin!,
        tempatLahir: _tempatLahirController.text,
        tanggalLahir: _tanggalLahirController.text,
        alamat: _alamatController.text,
        kelurahan: _kelurahanController.text,
        kecamatan: _kecamatanController.text,
        kota: _kotaController.text,
        provinsi: _provinsiController.text,
        kodePos: _kodePosController.text,
        agama: _agama!,
        statusPernikahan: _statusPernikahan!,
        pendidikanTerakhir: _pendidikanTerakhir!,
        pekerjaan: _pekerjaanController.text,
      );

      // Upload photo if selected
      if (_selectedPhoto != null) {
        await ProfileService.uploadProfilePhoto(_selectedPhoto!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back or to next step
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan profil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nikController.dispose();
    _namaLengkapController.dispose();
    _tempatLahirController.dispose();
    _tanggalLahirController.dispose();
    _alamatController.dispose();
    _kelurahanController.dispose();
    _kecamatanController.dispose();
    _kotaController.dispose();
    _provinsiController.dispose();
    _kodePosController.dispose();
    _pekerjaanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Profil Personal',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFff5001),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFff5001)),
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildForm(),
              ),
            ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  _buildHeaderSection(),
                  const SizedBox(height: 32),

                  // Profile Photo
                  Center(
                    child: ProfilePhotoPicker(
                      currentPhotoUrl: _existingProfile?['foto_profil'],
                      currentPhotoUpdatedAt: _existingProfile?['updated_at']?.toString(),
                      onPhotoSelected: (photo) {
                        setState(() {
                          _selectedPhoto = photo;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Form Fields
                  _buildFormFields(),
                ],
              ),
            ),
          ),

          // Save Button
          _buildSaveButton(),
        ],
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
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFff5001).withOpacity(0.3),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lengkapi Profil Personal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Isi data pribadi Anda dengan lengkap dan akurat',
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
                  'Step 1 dari 4',
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

  Widget _buildFormFields() {
    return Column(
      children: [
        // NIK & Nama Lengkap
        CustomTextField(
          label: 'NIK',
          controller: _nikController,
          validator: ProfileService.validateNik,
          keyboardType: TextInputType.number,
          prefixIcon: Icons.credit_card,
          isRequired: true,
          maxLength: 16,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 20),

        CustomTextField(
          label: 'Nama Lengkap',
          controller: _namaLengkapController,
          validator: (value) => ProfileService.validateRequired(value, 'Nama lengkap'),
          prefixIcon: Icons.person,
          isRequired: true,
        ),
        const SizedBox(height: 20),

        // Jenis Kelamin
        CustomDropdownField<String>(
          label: 'Jenis Kelamin',
          value: _jenisKelamin,
          items: ProfileService.jenisKelaminOptions,
          onChanged: (value) => setState(() => _jenisKelamin = value),
          validator: (value) => ProfileService.validateRequired(value, 'Jenis kelamin'),
          prefixIcon: Icons.person_outline,
          isRequired: true,
        ),
        const SizedBox(height: 20),

        // Tempat & Tanggal Lahir
        CustomTextField(
          label: 'Tempat Lahir',
          controller: _tempatLahirController,
          validator: (value) => ProfileService.validateRequired(value, 'Tempat lahir'),
          prefixIcon: Icons.location_on,
          isRequired: true,
        ),
        const SizedBox(height: 20),

        CustomDateField(
          label: 'Tanggal Lahir',
          controller: _tanggalLahirController,
          validator: ProfileService.validateDate,
          isRequired: true,
          lastDate: DateTime.now(),
        ),
        const SizedBox(height: 20),

        // Alamat
        CustomTextField(
          label: 'Alamat Lengkap',
          controller: _alamatController,
          validator: (value) => ProfileService.validateRequired(value, 'Alamat'),
          prefixIcon: Icons.home,
          isRequired: true,
          maxLines: 3,
        ),
        const SizedBox(height: 20),

        // Kelurahan & Kecamatan
        CustomTextField(
          label: 'Kelurahan',
          controller: _kelurahanController,
          validator: (value) => ProfileService.validateRequired(value, 'Kelurahan'),
          prefixIcon: Icons.map,
          isRequired: true,
        ),
        const SizedBox(height: 20),

        CustomTextField(
          label: 'Kecamatan',
          controller: _kecamatanController,
          validator: (value) => ProfileService.validateRequired(value, 'Kecamatan'),
          prefixIcon: Icons.map,
          isRequired: true,
        ),
        const SizedBox(height: 20),

        // Kota & Provinsi
        CustomTextField(
          label: 'Kota',
          controller: _kotaController,
          validator: (value) => ProfileService.validateRequired(value, 'Kota'),
          prefixIcon: Icons.location_city,
          isRequired: true,
        ),
        const SizedBox(height: 20),

        CustomTextField(
          label: 'Provinsi',
          controller: _provinsiController,
          validator: (value) => ProfileService.validateRequired(value, 'Provinsi'),
          prefixIcon: Icons.map,
          isRequired: true,
        ),
        const SizedBox(height: 20),

        // Kode Pos
        CustomTextField(
          label: 'Kode Pos',
          controller: _kodePosController,
          validator: ProfileService.validateKodePos,
          keyboardType: TextInputType.number,
          prefixIcon: Icons.mail,
          isRequired: true,
          maxLength: 10,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 20),

        // Agama
        CustomDropdownField<String>(
          label: 'Agama',
          value: _agama,
          items: ProfileService.agamaOptions,
          onChanged: (value) => setState(() => _agama = value),
          validator: (value) => ProfileService.validateRequired(value, 'Agama'),
          prefixIcon: Icons.mosque,
          isRequired: true,
        ),
        const SizedBox(height: 20),

        // Status Pernikahan
        CustomDropdownField<String>(
          label: 'Status Pernikahan',
          value: _statusPernikahan,
          items: ProfileService.statusPernikahanOptions,
          onChanged: (value) => setState(() => _statusPernikahan = value),
          validator: (value) => ProfileService.validateRequired(value, 'Status pernikahan'),
          prefixIcon: Icons.favorite,
          isRequired: true,
        ),
        const SizedBox(height: 20),

        // Pendidikan Terakhir
        CustomDropdownField<String>(
          label: 'Pendidikan Terakhir',
          value: _pendidikanTerakhir,
          items: ProfileService.pendidikanOptions,
          onChanged: (value) => setState(() => _pendidikanTerakhir = value),
          validator: (value) => ProfileService.validateRequired(value, 'Pendidikan terakhir'),
          prefixIcon: Icons.school,
          isRequired: true,
        ),
        const SizedBox(height: 20),

        // Pekerjaan
        CustomTextField(
          label: 'Pekerjaan',
          controller: _pekerjaanController,
          validator: (value) => ProfileService.validateRequired(value, 'Pekerjaan'),
          prefixIcon: Icons.work,
          isRequired: true,
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFff5001),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Simpan Profil Personal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
