import 'package:flutter/material.dart';

class BantuanSosialScreen extends StatefulWidget {
  const BantuanSosialScreen({super.key});

  @override
  State<BantuanSosialScreen> createState() => _BantuanSosialScreenState();
}

class _BantuanSosialScreenState extends State<BantuanSosialScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'Semua';
  
  final List<String> _categories = [
    'Semua',
    'Pendidikan',
    'Kesehatan',
    'Ekonomi',
    'Perumahan',
    'Pangan'
  ];

  // Mock data for bantuan sosial programs
  final List<Map<String, dynamic>> _programs = [
    {
      'id': 1,
      'nama_bantuan': 'Bantuan Pendidikan Anak Tidak Mampu',
      'jenis_bantuan': 'Pendidikan',
      'nominal': 2000000,
      'deskripsi': 'Bantuan biaya sekolah untuk anak-anak dari keluarga tidak mampu',
      'kuota': 100,
      'kuota_terpakai': 75,
      'tanggal_mulai': '2024-01-01',
      'tanggal_selesai': '2024-12-31',
      'status': 'Aktif',
      'syarat_bantuan': ['KTP', 'KK', 'Surat Keterangan Tidak Mampu', 'Rapor Anak'],
    },
    {
      'id': 2,
      'nama_bantuan': 'Program Bantuan Kesehatan Gratis',
      'jenis_bantuan': 'Kesehatan',
      'nominal': 1500000,
      'deskripsi': 'Bantuan pengobatan gratis untuk masyarakat kurang mampu',
      'kuota': 200,
      'kuota_terpakai': 150,
      'tanggal_mulai': '2024-01-01',
      'tanggal_selesai': '2024-12-31',
      'status': 'Aktif',
      'syarat_bantuan': ['KTP', 'KK', 'Surat Keterangan Sakit', 'Surat Keterangan Tidak Mampu'],
    },
    {
      'id': 3,
      'nama_bantuan': 'Bantuan Modal Usaha Mikro',
      'jenis_bantuan': 'Ekonomi',
      'nominal': 5000000,
      'deskripsi': 'Bantuan modal untuk pengembangan usaha mikro',
      'kuota': 50,
      'kuota_terpakai': 45,
      'tanggal_mulai': '2024-02-01',
      'tanggal_selesai': '2024-11-30',
      'status': 'Aktif',
      'syarat_bantuan': ['KTP', 'KK', 'Proposal Usaha', 'NPWP'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredPrograms.length,
            itemBuilder: (context, index) {
              final program = _filteredPrograms[index];
              return _buildProgramCard(program);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProgramCard(Map<String, dynamic> program) {
    final kuotaSisa = program['kuota'] - program['kuota_terpakai'];
    final persentaseKuota = (program['kuota_terpakai'] / program['kuota']) * 100;
    
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
                      'Rp ${_formatCurrency(program['nominal'])}',
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
                          '$kuotaSisa dari ${program['kuota']}',
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
                      '${program['tanggal_mulai']} - ${program['tanggal_selesai']}',
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
              onPressed: kuotaSisa > 0 ? () {
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
                kuotaSisa > 0 ? 'Lihat Detail & Ajukan' : 'Kuota Habis',
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
    // Mock data for user applications
    final applications = [
      {
        'id': 1,
        'no_pendaftaran': 'BST-2024-001',
        'nama_bantuan': 'Bantuan Pendidikan Anak Tidak Mampu',
        'status': 'Diproses',
        'tanggal_pengajuan': '2024-01-15',
        'catatan_admin': '',
      },
      {
        'id': 2,
        'no_pendaftaran': 'BST-2024-002',
        'nama_bantuan': 'Program Bantuan Kesehatan Gratis',
        'status': 'Disetujui',
        'tanggal_pengajuan': '2024-01-10',
        'tanggal_persetujuan': '2024-01-20',
        'catatan_admin': 'Berkas lengkap, bantuan akan disalurkan minggu depan',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: applications.length,
      itemBuilder: (context, index) {
        final application = applications[index];
        return _buildApplicationCard(application);
      },
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> application) {
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
                application['no_pendaftaran'],
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
                  application['status'],
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
            application['nama_bantuan'],
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
                'Diajukan: ${application['tanggal_pengajuan']}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          
          if (application['tanggal_persetujuan'] != null) ...[
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
                  'Disetujui: ${application['tanggal_persetujuan']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
          ],
          
          if (application['catatan_admin'] != null && 
              application['catatan_admin'].isNotEmpty) ...[
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
        return const Color(0xFF2196F3);
      case 'Disetujui':
        return const Color(0xFF4CAF50);
      case 'Ditolak':
        return const Color(0xFFF44336);
      case 'Selesai':
        return const Color(0xFF607D8B);
      default:
        return const Color(0xFF667eea);
    }
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.',
    );
  }

  void _showProgramDetails(Map<String, dynamic> program) {
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
                      
                      ...program['syarat_bantuan'].map<Widget>((syarat) => 
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
                      ).toList(),
                      
                      const SizedBox(height: 32),
                      
                      // Apply Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showApplicationForm(program);
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

  void _showApplicationForm(Map<String, dynamic> program) {
    // This would navigate to application form screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Form pengajuan untuk ${program['nama_bantuan']} akan dibuka'),
        backgroundColor: const Color(0xFF667eea),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}