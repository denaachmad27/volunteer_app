import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/bantuan_sosial_service.dart';

class BantuanSosialScreen extends StatefulWidget {
  const BantuanSosialScreen({super.key});

  @override
  State<BantuanSosialScreen> createState() => _BantuanSosialScreenState();
}

class _BantuanSosialScreenState extends State<BantuanSosialScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'Semua';
  bool _isLoadingPrograms = true;
  bool _isLoadingApplications = true;
  String? _errorMessage;
  
  final List<String> _categories = [
    'Semua',
    'Pendidikan',
    'Kesehatan',
    'Ekonomi',
    'Perumahan',
    'Pangan'
  ];

  // API data for bantuan sosial programs
  List<Map<String, dynamic>> _programs = [];
  List<Map<String, dynamic>> _userApplications = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadPrograms(),
      _loadUserApplications()
    ]);
  }

  Future<void> _loadPrograms() async {
    setState(() {
      _isLoadingPrograms = true;
      _errorMessage = null;
    });

    try {
      print('=== Loading programs for category: $_selectedCategory ===');
      
      final result = await BantuanSosialService.getAllPrograms(
        jenisFilter: _selectedCategory,
        limit: 50, // Increase limit to get more data
      );

      if (result['success']) {
        print('=== Programs loaded successfully ===');
        print('Total programs received: ${result['data'].length}');
        
        final programs = List<Map<String, dynamic>>.from(result['data'] ?? []);
        
        // Debug all program data
        for (int i = 0; i < programs.length; i++) {
          final program = programs[i];
          print('=== Program $i Debug ===');
          print('ID: ${program['id']}');
          print('Name: ${program['nama_bantuan']}');
          print('Type: ${program['jenis_bantuan']}');
          print('Status: ${program['status']}');
          print('Kuota: ${program['kuota']} (${program['kuota'].runtimeType})');
          print('Kuota Terpakai: ${program['kuota_terpakai']} (${program['kuota_terpakai'].runtimeType})');
          print('syarat_bantuan: ${program['syarat_bantuan']} (${program['syarat_bantuan'].runtimeType})');
          print('---');
        }
        
        setState(() {
          _programs = programs;
          _isLoadingPrograms = false;
        });
      } else {
        print('=== Failed to load programs ===');
        print('Error message: ${result['message']}');
        
        setState(() {
          _errorMessage = result['message'];
          _isLoadingPrograms = false;
        });
      }
    } catch (e) {
      print('=== Exception in _loadPrograms ===');
      print('Error: $e');
      
      setState(() {
        _errorMessage = 'Gagal memuat data program: $e';
        _isLoadingPrograms = false;
      });
    }
  }

  Future<void> _loadUserApplications() async {
    setState(() {
      _isLoadingApplications = true;
    });

    try {
      final result = await BantuanSosialService.getUserApplications(
        limit: 20,
      );

      if (result['success']) {
        setState(() {
          _userApplications = List<Map<String, dynamic>>.from(result['data'] ?? []);
          _isLoadingApplications = false;
        });
      } else {
        setState(() {
          _isLoadingApplications = false;
        });
        print('Error loading applications: ${result['message']}');
      }
    } catch (e) {
      setState(() {
        _isLoadingApplications = false;
      });
      print('Error loading applications: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredPrograms {
    if (_selectedCategory == 'Semua') {
      return _programs;
    }
    return _programs.where((program) => 
        program['jenis_bantuan'] == _selectedCategory).toList();
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  List<Widget> _getSyaratBantuanWidgets(dynamic syaratBantuan) {
    print('=== Processing syarat bantuan ===');
    print('Input: $syaratBantuan');
    print('Type: ${syaratBantuan.runtimeType}');
    
    List<String> syaratList = [];
    
    try {
      if (syaratBantuan == null || syaratBantuan == '') {
        syaratList = ['Tidak ada syarat khusus'];
      } else if (syaratBantuan is String) {
        if (syaratBantuan.trim().isEmpty) {
          syaratList = ['Tidak ada syarat khusus'];
        } else {
          // Try to parse as JSON first
          try {
            final decoded = jsonDecode(syaratBantuan);
            if (decoded is List) {
              syaratList = decoded.cast<String>();
            } else {
              // If it's a comma-separated string
              syaratList = syaratBantuan.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
            }
          } catch (e) {
            // If JSON parsing fails, treat as comma-separated string
            syaratList = syaratBantuan.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
          }
        }
      } else if (syaratBantuan is List) {
        syaratList = syaratBantuan.cast<String>().where((s) => s.trim().isNotEmpty).toList();
      } else {
        syaratList = ['Tidak ada syarat khusus'];
      }
      
      // Ensure we have at least one item
      if (syaratList.isEmpty) {
        syaratList = ['Tidak ada syarat khusus'];
      }
      
      print('Processed syarat list: $syaratList');
      
    } catch (e) {
      print('Error processing syarat bantuan: $e');
      syaratList = ['Gagal memuat syarat bantuan'];
    }

    return syaratList.map<Widget>((syarat) => 
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 20,
              color: Color(0xFF4CAF50),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                syarat,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Bantuan Sosial',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF667eea),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Program Tersedia'),
            Tab(text: 'Pengajuan Saya'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAvailablePrograms(),
          _buildMyApplications(),
        ],
      ),
    );
  }

  Widget _buildAvailablePrograms() {
    return Column(
      children: [
        // Category Filter
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category;
              
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                    _loadPrograms();
                  },
                  backgroundColor: Colors.white,
                  selectedColor: const Color(0xFF667eea).withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color(0xFF667eea) : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF667eea) : Colors.grey[300]!,
                  ),
                ),
              );
            },
          ),
        ),
        
        // Programs List
        Expanded(
          child: _isLoadingPrograms
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Memuat program bantuan...',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadPrograms,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF667eea),
                            ),
                            child: const Text(
                              'Coba Lagi',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _filteredPrograms.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tidak ada program bantuan tersedia',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Silakan periksa kategori lain atau coba lagi nanti',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _refreshData,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredPrograms.length,
                            itemBuilder: (context, index) {
                              final program = _filteredPrograms[index];
                              return _buildProgramCard(program);
                            },
                          ),
                        ),
        ),
      ],
    );
  }

  Widget _buildProgramCard(Map<String, dynamic> program) {
    final kuotaSisa = BantuanSosialService.getRemainingQuota(program);
    final persentaseKuota = BantuanSosialService.getQuotaPercentage(program);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(program['jenis_bantuan']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        program['jenis_bantuan'],
                        style: TextStyle(
                          fontSize: 12,
                          color: _getCategoryColor(program['jenis_bantuan']),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        program['status'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Title
                Text(
                  program['nama_bantuan'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Description
                Text(
                  program['deskripsi'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Amount
                Row(
                  children: [
                    Icon(
                      Icons.monetization_on_outlined,
                      size: 20,
                      color: Colors.green[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      BantuanSosialService.formatCurrency(program['nominal']),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[600],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Quota Progress
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kuota Tersedia',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '$kuotaSisa dari ${program['kuota'] ?? 'Tidak terbatas'}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: persentaseKuota / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        persentaseKuota > 80 ? Colors.red : const Color(0xFF667eea),
                      ),
                      minHeight: 6,
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Period
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${BantuanSosialService.formatDate(program['tanggal_mulai'])} - ${BantuanSosialService.formatDate(program['tanggal_selesai'])}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Action Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: ElevatedButton(
              onPressed: BantuanSosialService.isQuotaAvailable(program) ? () {
                _showProgramDetails(program);
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                BantuanSosialService.isQuotaAvailable(program) ? 'Lihat Detail & Ajukan' : 'Kuota Habis',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyApplications() {
    if (_isLoadingApplications) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
            ),
            SizedBox(height: 16),
            Text(
              'Memuat aplikasi Anda...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_userApplications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada pengajuan bantuan',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ajukan bantuan dari tab "Program Tersedia"',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _tabController.animateTo(0);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Lihat Program Tersedia',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _userApplications.length,
        itemBuilder: (context, index) {
          final application = _userApplications[index];
          return _buildApplicationCard(application);
        },
      ),
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> application) {
    final statusConfig = BantuanSosialService.getStatusConfig(application['status'] ?? 'pending');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Header
          Row(
            children: [
              Text(
                'ID: ${application['id']}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF667eea),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(application['status']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusConfig['label'],
                  style: TextStyle(
                    fontSize: 12,
                    color: _getStatusColor(application['status']),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Program Name
          Text(
            application['bantuan_sosial']?['nama_bantuan'] ?? 'Program tidak tersedia',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Date
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                'Diajukan: ${BantuanSosialService.formatDate(application['created_at'])}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          
          if (application['updated_at'] != null && 
              application['status'] == 'Disetujui') ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: Colors.green[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'Disetujui: ${BantuanSosialService.formatDate(application['updated_at'])}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
          ],
          
          // Show special message for "Perlu Dilengkapi" status
          if (application['status'] == 'Perlu Dilengkapi') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_outlined,
                        size: 16,
                        color: Colors.orange[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Perlu Dilengkapi',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Aplikasi Anda memerlukan dokumen atau informasi tambahan. Silakan lengkapi persyaratan yang diminta untuk melanjutkan proses.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange[800],
                    ),
                  ),
                  // Show admin notes for Perlu Dilengkapi status
                  if (application['catatan_admin'] != null && 
                      application['catatan_admin'].toString().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Catatan Admin:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            application['catatan_admin'],
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  // Resubmission button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _handleResubmission(application);
                      },
                      icon: Icon(
                        Icons.refresh_outlined,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Ajukan Kembali',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Show admin notes for all other statuses (except Perlu Dilengkapi)
          if (application['catatan_admin'] != null && 
              application['catatan_admin'].toString().isNotEmpty &&
              application['status'] != 'Perlu Dilengkapi') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.admin_panel_settings_outlined,
                        size: 16,
                        color: Colors.blue[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Catatan Admin:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    application['catatan_admin'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[800],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Pendidikan':
        return const Color(0xFF2196F3);
      case 'Kesehatan':
        return const Color(0xFF4CAF50);
      case 'Ekonomi':
        return const Color(0xFFFF9800);
      case 'Perumahan':
        return const Color(0xFF9C27B0);
      case 'Pangan':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF667eea);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFFF9800);
      case 'Diproses':
      case 'Under Review':
        return const Color(0xFF2196F3);
      case 'Disetujui':
        return const Color(0xFF4CAF50);
      case 'Ditolak':
        return const Color(0xFFF44336);
      case 'Perlu Dilengkapi':
        return const Color(0xFFFF9800); // Orange untuk "Belum Lengkap"
      case 'Selesai':
        return const Color(0xFF607D8B);
      default:
        return const Color(0xFF667eea);
    }
  }


  void _showProgramDetails(Map<String, dynamic> program, {bool isResubmission = false, Map<String, dynamic>? existingApplication}) {
    print('=== Showing program details ===');
    print('Program ID: ${program['id']}');
    print('Program name: ${program['nama_bantuan']}');
    print('Syarat bantuan: ${program['syarat_bantuan']}');
    print('Syarat bantuan type: ${program['syarat_bantuan'].runtimeType}');
    print('Is resubmission: $isResubmission');
    print('Existing application: $existingApplication');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        program['nama_bantuan'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Description
                      Text(
                        program['deskripsi'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Requirements
                      const Text(
                        'Syarat Pengajuan:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      ..._getSyaratBantuanWidgets(program['syarat_bantuan']),
                      
                      const SizedBox(height: 32),
                      
                      // Apply Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showApplicationForm(program, isResubmission: isResubmission, existingApplication: existingApplication);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF667eea),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Ajukan Bantuan',
                            style: TextStyle(
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
            ],
          ),
        ),
      ),
    );
  }

  void _showApplicationForm(Map<String, dynamic> program, {bool isResubmission = false, Map<String, dynamic>? existingApplication}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildApplicationFormSheet(program, isResubmission: isResubmission, existingApplication: existingApplication),
    );
  }

  Widget _buildApplicationFormSheet(Map<String, dynamic> program, {bool isResubmission = false, Map<String, dynamic>? existingApplication}) {
    final TextEditingController notesController = TextEditingController(
      text: isResubmission && existingApplication != null 
        ? existingApplication!['alasan_pengajuan']?.toString() ?? ''
        : ''
    );
    bool isSubmitting = false;

    return StatefulBuilder(
      builder: (context, setState) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        isResubmission ? 'Ajukan Kembali' : 'Ajukan Bantuan',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isResubmission ? Colors.orange[600] : Color(0xFF2D3748),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Program Info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF667eea).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF667eea).withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              program['nama_bantuan'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF667eea),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Nominal: ${BantuanSosialService.formatCurrency(program['nominal'])}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              program['deskripsi'] ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Resubmission info
                      if (isResubmission && existingApplication != null) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 18,
                                    color: Colors.orange[600],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Pengajuan Ulang',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'ID Pengajuan: ${existingApplication!['id']}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.orange[700],
                                ),
                              ),
                              if (existingApplication!['catatan_admin'] != null && 
                                  existingApplication!['catatan_admin'].toString().isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Catatan Admin: ${existingApplication!['catatan_admin']}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.orange[800],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Notes
                      const Row(
                        children: [
                          Text(
                            'Alasan Pengajuan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          Text(
                            ' *',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      TextField(
                        controller: notesController,
                        maxLines: 4,
                        maxLength: 500,
                        decoration: InputDecoration(
                          hintText: 'Jelaskan alasan mengapa Anda membutuhkan bantuan ini...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF667eea),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Warning Info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: Colors.orange[600],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Pastikan data profil Anda sudah lengkap sebelum mengajukan bantuan. Pengajuan akan diverifikasi oleh admin.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : () async {
                            // Validate input
                            if (notesController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Alasan pengajuan wajib diisi'),
                                  backgroundColor: Colors.orange,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                              return;
                            }
                            
                            setState(() {
                              isSubmitting = true;
                            });
                            
                            try {
                              Map<String, dynamic> result;
                              
                              if (isResubmission && existingApplication != null) {
                                print('=== Resubmitting application ===');
                                print('Application ID: ${existingApplication!['id']}');
                                print('Alasan: ${notesController.text.trim()}');
                                
                                result = await BantuanSosialService.resubmitApplication(
                                  applicationId: existingApplication!['id'],
                                  catatanTambahan: notesController.text.trim(),
                                );
                              } else {
                                print('=== Submitting new application ===');
                                print('Program ID: ${program['id']}');
                                print('Alasan: ${notesController.text.trim()}');
                                
                                result = await BantuanSosialService.submitApplication(
                                  bantuanSosialId: program['id'],
                                  catatanTambahan: notesController.text.trim(),
                                );
                              }
                              
                              if (result['success']) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result['message'] ?? 'Pengajuan berhasil disubmit'),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                                
                                // Switch to applications tab and refresh
                                _tabController.animateTo(1);
                                await _loadUserApplications();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result['message'] ?? 'Gagal mengajukan bantuan'),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            } finally {
                              setState(() {
                                isSubmitting = false;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF667eea),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: isSubmitting
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Mengirim...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  isResubmission ? 'Ajukan Kembali' : 'Ajukan Bantuan',
                                  style: TextStyle(
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
            ],
          ),
        ),
      ),
    );
  }

  void _handleResubmission(Map<String, dynamic> application) {
    // Get the original program details
    final bantuanSosial = application['bantuan_sosial'];
    
    if (bantuanSosial == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data program tidak ditemukan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show resubmission dialog
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.refresh_outlined,
                      color: Colors.orange[600],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Ajukan Kembali',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Program info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bantuanSosial['nama_bantuan'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ID Pengajuan: ${application['id']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Admin notes
                if (application['catatan_admin'] != null && 
                    application['catatan_admin'].toString().isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Catatan Admin:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          application['catatan_admin'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Information
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: Colors.blue[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Informasi Pengajuan Ulang',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Lengkapi semua persyaratan yang diminta admin\n'
                        '• Pastikan dokumen yang diupload sesuai dan jelas\n'
                        '• Status pengajuan akan berubah menjadi "Menunggu" setelah disubmit\n'
                        '• Pengajuan akan diverifikasi ulang oleh admin',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue[700],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[600],
                          side: BorderSide(color: Colors.grey[300]!),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Show the application form with pre-filled data
                          _showProgramDetails(bantuanSosial, isResubmission: true, existingApplication: application);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Lanjutkan'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}