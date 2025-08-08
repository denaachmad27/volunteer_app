import 'package:flutter/material.dart';
import '../services/economic_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_dropdown_field.dart';
import '../widgets/custom_currency_field.dart';
import '../widgets/custom_switch_field.dart';
import '../widgets/economic_status_card.dart';

class EconomicFormScreen extends StatefulWidget {
  final Map<String, dynamic>? economicData;

  const EconomicFormScreen({super.key, this.economicData});

  @override
  State<EconomicFormScreen> createState() => _EconomicFormScreenState();
}

class _EconomicFormScreenState extends State<EconomicFormScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Form controllers
  final _penghasilanController = TextEditingController();
  final _pengeluaranController = TextEditingController();
  final _jenisRumahController = TextEditingController();
  final _jenisKendaraanController = TextEditingController();
  final _jumlahTabunganController = TextEditingController();
  final _jumlahHutangController = TextEditingController();
  final _sumberPenghasilanLainController = TextEditingController();

  // Dropdown values
  String? _statusRumah;

  // Switch values
  bool _punyaKendaraan = false;
  bool _punyaTabungan = false;
  bool _punyaHutang = false;

  // State
  bool _isSaving = false;
  bool _isEditing = false;
  bool _showPreview = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.economicData != null;
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
    if (_isEditing && widget.economicData != null) {
      final data = widget.economicData!;
      
      final penghasilan = double.tryParse(data['penghasilan_bulanan']?.toString() ?? '0') ?? 0.0;
      final pengeluaran = double.tryParse(data['pengeluaran_bulanan']?.toString() ?? '0') ?? 0.0;
      final jumlahTabungan = double.tryParse(data['jumlah_tabungan']?.toString() ?? '0') ?? 0.0;
      final jumlahHutang = double.tryParse(data['jumlah_hutang']?.toString() ?? '0') ?? 0.0;
      
      if (penghasilan > 0.0) {
        _penghasilanController.text = EconomicService.formatCurrency(penghasilan).replaceAll('Rp ', '');
      }
      if (pengeluaran > 0.0) {
        _pengeluaranController.text = EconomicService.formatCurrency(pengeluaran).replaceAll('Rp ', '');
      }
      if (jumlahTabungan > 0.0) {
        _jumlahTabunganController.text = EconomicService.formatCurrency(jumlahTabungan).replaceAll('Rp ', '');
      }
      if (jumlahHutang > 0.0) {
        _jumlahHutangController.text = EconomicService.formatCurrency(jumlahHutang).replaceAll('Rp ', '');
      }
      
      _statusRumah = data['status_rumah'];
      _jenisRumahController.text = data['jenis_rumah'] ?? '';
      _punyaKendaraan = data['punya_kendaraan'] == true || data['punya_kendaraan'] == 1;
      _jenisKendaraanController.text = data['jenis_kendaraan'] ?? '';
      _punyaTabungan = data['punya_tabungan'] == true || data['punya_tabungan'] == 1;
      _punyaHutang = data['punya_hutang'] == true || data['punya_hutang'] == 1;
      _sumberPenghasilanLainController.text = data['sumber_penghasilan_lain'] ?? '';
    }
  }

  void _updatePreview() {
    final penghasilan = EconomicService.parseCurrency(_penghasilanController.text);
    final pengeluaran = EconomicService.parseCurrency(_pengeluaranController.text);
    
    setState(() {
      _showPreview = penghasilan > 0.0 && pengeluaran > 0.0;
    });
  }

  Future<void> _saveEconomicData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final penghasilan = EconomicService.parseCurrency(_penghasilanController.text);
      final pengeluaran = EconomicService.parseCurrency(_pengeluaranController.text);
      
      // Validasi untuk tabungan dan hutang
      final jumlahTabungan = _punyaTabungan 
        ? EconomicService.parseCurrency(_jumlahTabunganController.text)
        : null;
      final jumlahHutang = _punyaHutang 
        ? EconomicService.parseCurrency(_jumlahHutangController.text) 
        : null;
      
      // Validasi khusus untuk backend requirements
      if (_punyaTabungan && (jumlahTabungan == null || jumlahTabungan <= 0)) {
        throw Exception('Jumlah tabungan harus diisi dan lebih dari 0 jika memiliki tabungan');
      }
      
      if (_punyaHutang && (jumlahHutang == null || jumlahHutang <= 0)) {
        throw Exception('Jumlah hutang harus diisi dan lebih dari 0 jika memiliki hutang');
      }

      await EconomicService.createOrUpdateEconomicData(
        penghasilanBulanan: penghasilan,
        pengeluaranBulanan: pengeluaran,
        statusRumah: _statusRumah!,
        jenisRumah: _jenisRumahController.text,
        punyaKendaraan: _punyaKendaraan,
        jenisKendaraan: _punyaKendaraan ? _jenisKendaraanController.text : null,
        punyaTabungan: _punyaTabungan,
        jumlahTabungan: jumlahTabungan,
        punyaHutang: _punyaHutang,
        jumlahHutang: jumlahHutang,
        sumberPenghasilanLain: _sumberPenghasilanLainController.text.isEmpty 
          ? null : _sumberPenghasilanLainController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing 
                ? 'Data ekonomi berhasil diupdate!' 
                : 'Data ekonomi berhasil disimpan!',
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
    _penghasilanController.dispose();
    _pengeluaranController.dispose();
    _jenisRumahController.dispose();
    _jenisKendaraanController.dispose();
    _jumlahTabunganController.dispose();
    _jumlahHutangController.dispose();
    _sumberPenghasilanLainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Data Ekonomi' : 'Isi Data Ekonomi',
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

                  // Preview if available
                  if (_showPreview) ...[
                    EconomicStatusCard(
                      penghasilan: EconomicService.parseCurrency(_penghasilanController.text),
                      pengeluaran: EconomicService.parseCurrency(_pengeluaranController.text),
                      showDetails: false,
                    ),
                    const SizedBox(height: 24),
                  ],

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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.analytics,
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
                  _isEditing ? 'Edit Data Ekonomi' : 'Isi Data Ekonomi',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Informasi kondisi keuangan dan aset Anda',
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Income & Expenses Section
        const Text(
          'Penghasilan & Pengeluaran',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        
        CustomCurrencyField(
          label: 'Penghasilan Bulanan',
          controller: _penghasilanController,
          validator: (value) => EconomicService.validateCurrency(value, 'Penghasilan bulanan'),
          isRequired: true,
        ),
        const SizedBox(height: 20),

        CustomCurrencyField(
          label: 'Pengeluaran Bulanan',
          controller: _pengeluaranController,
          validator: (value) => EconomicService.validateCurrency(value, 'Pengeluaran bulanan'),
          isRequired: true,
        ),
        
        const SizedBox(height: 12),
        Center(
          child: TextButton.icon(
            onPressed: _updatePreview,
            icon: const Icon(Icons.preview, size: 18),
            label: const Text('Lihat Preview Status'),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFff5001)),
          ),
        ),
        
        const SizedBox(height: 32),

        // Property Section
        const Text(
          'Properti & Tempat Tinggal',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        
        CustomDropdownField<String>(
          label: 'Status Rumah',
          value: _statusRumah,
          items: EconomicService.statusRumahOptions,
          onChanged: (value) => setState(() => _statusRumah = value),
          validator: (value) => EconomicService.validateRequired(value, 'Status rumah'),
          prefixIcon: Icons.home,
          isRequired: true,
        ),
        const SizedBox(height: 20),

        CustomTextField(
          label: 'Jenis Rumah',
          controller: _jenisRumahController,
          validator: (value) => EconomicService.validateRequired(value, 'Jenis rumah'),
          prefixIcon: Icons.home_outlined,
          hint: 'Contoh: Rumah Permanen, Apartemen, dll',
          isRequired: true,
        ),
        
        const SizedBox(height: 32),

        // Vehicle Section
        const Text(
          'Kendaraan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        
        CustomSwitchField(
          label: 'Memiliki Kendaraan',
          subtitle: 'Apakah Anda memiliki kendaraan pribadi?',
          value: _punyaKendaraan,
          onChanged: (value) {
            setState(() {
              _punyaKendaraan = value;
              if (!value) {
                _jenisKendaraanController.clear();
              }
            });
          },
          icon: Icons.directions_car,
        ),
        
        if (_punyaKendaraan) ...[
          const SizedBox(height: 20),
          CustomTextField(
            label: 'Jenis Kendaraan',
            controller: _jenisKendaraanController,
            validator: _punyaKendaraan 
              ? (value) => EconomicService.validateRequired(value, 'Jenis kendaraan')
              : null,
            prefixIcon: Icons.motorcycle,
            hint: 'Contoh: Motor, Mobil, Motor dan Mobil',
          ),
        ],
        
        const SizedBox(height: 32),

        // Savings Section
        const Text(
          'Tabungan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        
        CustomSwitchField(
          label: 'Memiliki Tabungan',
          subtitle: 'Apakah Anda memiliki tabungan?',
          value: _punyaTabungan,
          onChanged: (value) {
            setState(() {
              _punyaTabungan = value;
              if (!value) {
                _jumlahTabunganController.clear();
              }
            });
          },
          icon: Icons.savings,
        ),
        
        if (_punyaTabungan) ...[
          const SizedBox(height: 20),
          CustomCurrencyField(
            label: 'Jumlah Tabungan',
            controller: _jumlahTabunganController,
            validator: _punyaTabungan 
              ? (value) => EconomicService.validateCurrency(value, 'Jumlah tabungan')
              : null,
            isRequired: true,
          ),
        ],
        
        const SizedBox(height: 32),

        // Debt Section
        const Text(
          'Hutang',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        
        CustomSwitchField(
          label: 'Memiliki Hutang',
          subtitle: 'Apakah Anda memiliki hutang?',
          value: _punyaHutang,
          onChanged: (value) {
            setState(() {
              _punyaHutang = value;
              if (!value) {
                _jumlahHutangController.clear();
              }
            });
          },
          icon: Icons.money_off,
        ),
        
        if (_punyaHutang) ...[
          const SizedBox(height: 20),
          CustomCurrencyField(
            label: 'Jumlah Hutang',
            controller: _jumlahHutangController,
            validator: _punyaHutang 
              ? (value) => EconomicService.validateCurrency(value, 'Jumlah hutang')
              : null,
            isRequired: true,
          ),
        ],
        
        const SizedBox(height: 32),

        // Additional Income
        const Text(
          'Sumber Penghasilan Lain (Opsional)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        
        CustomTextField(
          label: 'Sumber Penghasilan Lain',
          controller: _sumberPenghasilanLainController,
          prefixIcon: Icons.add_business,
          hint: 'Contoh: Freelance, usaha sampingan, dll',
          maxLines: 3,
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
            onPressed: _isSaving ? null : _saveEconomicData,
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
                : Text(
                    _isEditing ? 'Update Data Ekonomi' : 'Simpan Data Ekonomi',
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