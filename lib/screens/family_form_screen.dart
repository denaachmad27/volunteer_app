import 'package:flutter/material.dart';
import '../services/family_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_dropdown_field.dart';
import '../widgets/custom_date_field.dart';
import '../widgets/custom_currency_field.dart';
import '../widgets/custom_switch_field.dart';

class FamilyFormScreen extends StatefulWidget {
  final Map<String, dynamic>? familyMember;

  const FamilyFormScreen({Key? key, this.familyMember}) : super(key: key);

  @override
  State<FamilyFormScreen> createState() => _FamilyFormScreenState();
}

class _FamilyFormScreenState extends State<FamilyFormScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Form controllers
  final _namaController = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  final _pekerjaanController = TextEditingController();
  final _penghasilanController = TextEditingController();

  // Dropdown values
  String? _hubungan;
  String? _jenisKelamin;
  String? _pendidikan;

  // Switch values
  bool _tanggungan = false;

  // State
  bool _isSaving = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.familyMember != null;
    _initializeAnimations();
    _populateFormIfEditing();
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

  void _populateFormIfEditing() {
    if (_isEditing && widget.familyMember != null) {
      final member = widget.familyMember!;
      _namaController.text = member['nama_anggota'] ?? '';
      _hubungan = member['hubungan'];
      _jenisKelamin = member['jenis_kelamin'];
      _tanggalLahirController.text = member['tanggal_lahir'] ?? '';
      _pekerjaanController.text = member['pekerjaan'] ?? '';
      _pendidikan = member['pendidikan'];
      
      final penghasilan = double.tryParse(member['penghasilan']?.toString() ?? '0') ?? 0;
      if (penghasilan > 0) {
        _penghasilanController.text = FamilyService.formatCurrency(penghasilan).replaceAll('Rp ', '');
      }
      
      _tanggungan = member['tanggungan'] == true || member['tanggungan'] == 1;
    }
  }

  Future<void> _saveFamily() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final penghasilan = FamilyService.parseCurrency(_penghasilanController.text);

      if (_isEditing) {
        await FamilyService.updateFamilyMember(
          id: widget.familyMember!['id'],
          namaAnggota: _namaController.text,
          hubungan: _hubungan!,
          jenisKelamin: _jenisKelamin!,
          tanggalLahir: _tanggalLahirController.text,
          pekerjaan: _pekerjaanController.text,
          pendidikan: _pendidikan!,
          penghasilan: penghasilan,
          tanggungan: _tanggungan,
        );
      } else {
        await FamilyService.addFamilyMember(
          namaAnggota: _namaController.text,
          hubungan: _hubungan!,
          jenisKelamin: _jenisKelamin!,
          tanggalLahir: _tanggalLahirController.text,
          pekerjaan: _pekerjaanController.text,
          pendidikan: _pendidikan!,
          penghasilan: penghasilan,
          tanggungan: _tanggungan,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing 
                ? 'Anggota keluarga berhasil diupdate!' 
                : 'Anggota keluarga berhasil ditambahkan!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan data: $e'),
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
    _namaController.dispose();
    _tanggalLahirController.dispose();
    _pekerjaanController.dispose();
    _penghasilanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Anggota Keluarga' : 'Tambah Anggota Keluarga',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: FadeTransition(
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
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_add,
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
                  _isEditing ? 'Edit Data Keluarga' : 'Tambah Anggota Keluarga',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Isi data anggota keluarga dengan lengkap',
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
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        // Nama Anggota
        CustomTextField(
          label: 'Nama Anggota Keluarga',
          controller: _namaController,
          validator: (value) => FamilyService.validateRequired(value, 'Nama anggota'),
          prefixIcon: Icons.person,
          isRequired: true,
        ),
        const SizedBox(height: 20),

        // Hubungan
        CustomDropdownField<String>(
          label: 'Hubungan Keluarga',
          value: _hubungan,
          items: FamilyService.hubunganOptions,
          onChanged: (value) => setState(() => _hubungan = value),
          validator: (value) => FamilyService.validateRequired(value, 'Hubungan keluarga'),
          prefixIcon: Icons.family_restroom,
          isRequired: true,
        ),
        const SizedBox(height: 20),

        // Jenis Kelamin
        CustomDropdownField<String>(
          label: 'Jenis Kelamin',
          value: _jenisKelamin,
          items: FamilyService.jenisKelaminOptions,
          onChanged: (value) => setState(() => _jenisKelamin = value),
          validator: (value) => FamilyService.validateRequired(value, 'Jenis kelamin'),
          prefixIcon: Icons.person_outline,
          isRequired: true,
        ),
        const SizedBox(height: 20),

        // Tanggal Lahir
        CustomDateField(
          label: 'Tanggal Lahir',
          controller: _tanggalLahirController,
          validator: FamilyService.validateDate,
          isRequired: true,
          lastDate: DateTime.now(),
        ),
        const SizedBox(height: 20),

        // Pekerjaan
        CustomTextField(
          label: 'Pekerjaan',
          controller: _pekerjaanController,
          validator: (value) => FamilyService.validateRequired(value, 'Pekerjaan'),
          prefixIcon: Icons.work,
          isRequired: true,
        ),
        const SizedBox(height: 20),

        // Pendidikan
        CustomDropdownField<String>(
          label: 'Pendidikan Terakhir',
          value: _pendidikan,
          items: FamilyService.pendidikanOptions,
          onChanged: (value) => setState(() => _pendidikan = value),
          validator: (value) => FamilyService.validateRequired(value, 'Pendidikan'),
          prefixIcon: Icons.school,
          isRequired: true,
        ),
        const SizedBox(height: 20),

        // Penghasilan
        CustomCurrencyField(
          label: 'Penghasilan Bulanan',
          controller: _penghasilanController,
          validator: FamilyService.validatePenghasilan,
          isRequired: true,
        ),
        const SizedBox(height: 20),

        // Tanggungan Switch
        CustomSwitchField(
          label: 'Menjadi Tanggungan',
          subtitle: 'Apakah anggota keluarga ini menjadi tanggungan Anda?',
          value: _tanggungan,
          onChanged: (value) => setState(() => _tanggungan = value),
          icon: Icons.family_restroom,
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
            onPressed: _isSaving ? null : _saveFamily,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
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
                : Text(
                    _isEditing ? 'Update Anggota Keluarga' : 'Simpan Anggota Keluarga',
                    style: const TextStyle(
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