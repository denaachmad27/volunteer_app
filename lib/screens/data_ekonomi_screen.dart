import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/economic_service.dart';
import '../widgets/economic_status_card.dart';
import '../widgets/asset_card.dart';
import '../widgets/financial_advice_card.dart';
import 'economic_form_screen.dart';

class DataEkonomiScreen extends StatefulWidget {
  const DataEkonomiScreen({Key? key}) : super(key: key);

  @override
  State<DataEkonomiScreen> createState() => _DataEkonomiScreenState();
}

class _DataEkonomiScreenState extends State<DataEkonomiScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Map<String, dynamic>? _economicData;
  bool _isLoading = true;
  bool _hasData = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadEconomicData();
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

  Future<void> _loadEconomicData() async {
    setState(() => _isLoading = true);

    try {
      final data = await EconomicService.getEconomicData();
      
      if (mounted) {
        setState(() {
          _economicData = data;
          _hasData = data != null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _economicData = null;
          _hasData = false;
          _isLoading = false;
        });
        
        // Show error message for actual errors (not 404/no data)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data ekonomi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateToForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EconomicFormScreen(economicData: _economicData),
      ),
    );

    if (result == true) {
      _loadEconomicData();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Data Ekonomi',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFff5001),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadEconomicData,
            icon: const Icon(Icons.refresh),
          ),
          if (_hasData)
            IconButton(
              onPressed: _navigateToForm,
              icon: const Icon(Icons.edit),
            ),
        ],
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
                child: _hasData ? _buildDataView() : _buildEmptyState(),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToForm,
        backgroundColor: const Color(0xFFff5001),
        child: Icon(_hasData ? Icons.edit : Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDataView() {
    if (_economicData == null) return _buildEmptyState();

    final penghasilan = double.tryParse(_economicData!['penghasilan_bulanan']?.toString() ?? '0') ?? 0.0;
    final pengeluaran = double.tryParse(_economicData!['pengeluaran_bulanan']?.toString() ?? '0') ?? 0.0;
    final statusData = EconomicService.calculateEconomicStatus(penghasilan, pengeluaran);
    final adviceList = EconomicService.getFinancialAdvice(statusData, _economicData!);

    return Column(
      children: [
        // Header Section
        _buildHeaderSection(statusData),
        
        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Economic Status Card
                EconomicStatusCard(
                  penghasilan: penghasilan,
                  pengeluaran: pengeluaran,
                ),
                
                const SizedBox(height: 24),
                
                // Assets Section
                const Text(
                  'Aset & Kepemilikan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Assets List
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: AssetCards.buildPropertyCard(_economicData!)),
                        const SizedBox(width: 12),
                        Expanded(child: AssetCards.buildVehicleCard(_economicData!)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: AssetCards.buildSavingsCard(_economicData!)),
                        const SizedBox(width: 12),
                        Expanded(child: AssetCards.buildDebtCard(_economicData!)),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Additional Income Source
                if (_economicData!['sumber_penghasilan_lain'] != null && 
                    _economicData!['sumber_penghasilan_lain'].toString().isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
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
                                Icons.add_business,
                                color: Color(0xFFff5001),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Sumber Penghasilan Lain',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _economicData!['sumber_penghasilan_lain'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                ],
                
                // Financial Advice
                FinancialAdviceCard(adviceList: adviceList),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection(Map<String, dynamic> statusData) {
    final status = statusData['status'];
    final statusColor = statusData['color'];
    final statusIcon = statusData['icon'];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFff5001), Color(0xFF764ba2)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
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
                  Icons.analytics,
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
                      'Data Ekonomi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Informasi kondisi keuangan dan aset',
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
          const SizedBox(height: 20),
          
          // Quick Status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(
                  statusIcon,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status Keuangan',
                        style: TextStyle(
                          color: Color(0xE6FFFFFF),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                  'Step 3 dari 4',
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFff5001).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.analytics,
                size: 60,
                color: Color(0xFFff5001),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum Ada Data Ekonomi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Isi data ekonomi untuk analisis kondisi keuangan Anda',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _navigateToForm,
              icon: const Icon(Icons.add),
              label: const Text('Isi Data Ekonomi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFff5001),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}