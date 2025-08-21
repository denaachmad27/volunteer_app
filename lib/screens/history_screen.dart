import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFff5001),
              Color(0xFFe64100),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.2),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.history_rounded,
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
                              'Riwayat Aktivitas',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Lihat semua aktivitas Anda',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Tab Bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    indicator: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.volunteer_activism_rounded, size: 20),
                        text: 'Bantuan Sosial',
                      ),
                      Tab(
                        icon: Icon(Icons.report_problem_rounded, size: 20),
                        text: 'Pengaduan',
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Main Content
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildBantuanHistory(),
                        _buildComplaintHistory(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBantuanHistory() {
    // Mock data for bantuan history
    final bantuanHistory = [
      {
        'id': 1,
        'no_pendaftaran': 'BST-2024-001',
        'nama_bantuan': 'Bantuan Pendidikan Anak Tidak Mampu',
        'status': 'Disetujui',
        'tanggal_pengajuan': '2024-01-15',
        'tanggal_persetujuan': '2024-01-20',
        'nominal': 2000000,
        'catatan_admin': 'Bantuan telah disetujui, pencairan akan dilakukan minggu depan.',
      },
      {
        'id': 2,
        'no_pendaftaran': 'BST-2024-002',
        'nama_bantuan': 'Program Bantuan Kesehatan Gratis',
        'status': 'Diproses',
        'tanggal_pengajuan': '2024-01-20',
        'nominal': 1500000,
        'catatan_admin': 'Berkas sedang dalam tahap verifikasi.',
      },
      {
        'id': 3,
        'no_pendaftaran': 'BST-2024-003',
        'nama_bantuan': 'Bantuan Modal Usaha Mikro',
        'status': 'Ditolak',
        'tanggal_pengajuan': '2024-01-10',
        'tanggal_penolakan': '2024-01-18',
        'nominal': 5000000,
        'catatan_admin': 'Berkas tidak lengkap, silakan ajukan kembali dengan melengkapi persyaratan.',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bantuanHistory.length,
      itemBuilder: (context, index) {
        final item = bantuanHistory[index];
        return _buildBantuanHistoryCard(item);
      },
    );
  }

  Widget _buildBantuanHistoryCard(Map<String, dynamic> item) {
    Color statusColor = _getStatusColor(item['status']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  item['no_pendaftaran'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item['status'],
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Program Name
            Text(
              item['nama_bantuan'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Amount
            Row(
              children: [
                Icon(
                  Icons.monetization_on_outlined,
                  size: 18,
                  color: Colors.green[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'Rp ${_formatCurrency(item['nominal'])}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600],
                  ),
                ),
              ],
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
                  'Diajukan: ${item['tanggal_pengajuan']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            if (item['tanggal_persetujuan'] != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: Colors.green[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Disetujui: ${item['tanggal_persetujuan']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green[600],
                    ),
                  ),
                ],
              ),
            ],
            
            if (item['tanggal_penolakan'] != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.cancel_outlined,
                    size: 16,
                    color: Colors.red[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ditolak: ${item['tanggal_penolakan']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red[600],
                    ),
                  ),
                ],
              ),
            ],
            
            // Admin Note
            if (item['catatan_admin'] != null && item['catatan_admin'].isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.admin_panel_settings_outlined,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Catatan Admin:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['catatan_admin'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintHistory() {
    // Mock data for complaint history
    final complaintHistory = [
      {
        'id': 1,
        'no_tiket': 'TKT-2024-001',
        'judul': 'Lampu Jalan Mati di Jl. Merdeka',
        'kategori': 'Penerangan',
        'prioritas': 'Sedang',
        'status': 'Selesai',
        'tanggal_pengaduan': '2024-01-25',
        'tanggal_selesai': '2024-01-28',
        'respon_admin': 'Lampu jalan telah diperbaiki dan berfungsi normal kembali.',
        'lokasi': 'Jl. Merdeka No. 15',
        'rating': 5,
      },
      {
        'id': 2,
        'no_tiket': 'TKT-2024-002',
        'judul': 'Drainase Tersumbat Menyebabkan Banjir',
        'kategori': 'Infrastruktur',
        'prioritas': 'Tinggi',
        'status': 'Diproses',
        'tanggal_pengaduan': '2024-01-20',
        'respon_admin': 'Tim sudah turun ke lokasi untuk pembersihan drainase.',
        'lokasi': 'Jl. Sudirman Km. 5',
      },
      {
        'id': 3,
        'no_tiket': 'TKT-2024-003',
        'judul': 'Sampah Menumpuk di Taman Kota',
        'kategori': 'Lingkungan',
        'prioritas': 'Rendah',
        'status': 'Baru',
        'tanggal_pengaduan': '2024-01-28',
        'lokasi': 'Taman Kota Blok A',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: complaintHistory.length,
      itemBuilder: (context, index) {
        final item = complaintHistory[index];
        return _buildComplaintHistoryCard(item);
      },
    );
  }

  Widget _buildComplaintHistoryCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  item['no_tiket'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getComplaintStatusColor(item['status']).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item['status'],
                    style: TextStyle(
                      fontSize: 12,
                      color: _getComplaintStatusColor(item['status']),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Title
            Text(
              item['judul'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Category and Priority
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(item['kategori']).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item['kategori'],
                    style: TextStyle(
                      fontSize: 12,
                      color: _getCategoryColor(item['kategori']),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(item['prioritas']).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item['prioritas'],
                    style: TextStyle(
                      fontSize: 12,
                      color: _getPriorityColor(item['prioritas']),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Location and Date
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item['lokasi'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 4),
            
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Diajukan: ${item['tanggal_pengaduan']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            if (item['tanggal_selesai'] != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: Colors.green[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Selesai: ${item['tanggal_selesai']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green[600],
                    ),
                  ),
                ],
              ),
            ],
            
            // Admin Response
            if (item['respon_admin'] != null && item['respon_admin'].isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.admin_panel_settings_outlined,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tanggapan Admin:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['respon_admin'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Rating (if completed)
            if (item['rating'] != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text(
                    'Rating Anda: ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  ...List.generate(5, (index) => Icon(
                    index < item['rating'] 
                        ? Icons.star 
                        : Icons.star_border,
                    size: 16,
                    color: Colors.amber,
                  )),
                ],
              ),
            ],
          ],
        ),
      ),
    );
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
        return Theme.of(context).colorScheme.primary;
    }
  }

  Color _getComplaintStatusColor(String status) {
    switch (status) {
      case 'Baru':
        return const Color(0xFF2196F3);
      case 'Diproses':
        return const Color(0xFFFF9800);
      case 'Selesai':
        return const Color(0xFF4CAF50);
      case 'Ditutup':
        return const Color(0xFF607D8B);
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Infrastruktur':
        return const Color(0xFFFF9800);
      case 'Penerangan':
        return const Color(0xFFFFC107);
      case 'Sanitasi':
        return const Color(0xFF2196F3);
      case 'Lingkungan':
        return const Color(0xFF4CAF50);
      case 'Keamanan':
        return const Color(0xFFF44336);
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Rendah':
        return const Color(0xFF4CAF50);
      case 'Sedang':
        return const Color(0xFFFF9800);
      case 'Tinggi':
        return const Color(0xFFF44336);
      case 'Urgent':
        return const Color(0xFF9C27B0);
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.',
    );
  }
}
