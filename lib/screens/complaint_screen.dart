import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/complaint_service.dart';
import '../services/api_service.dart';
import '../widgets/reliable_network_image.dart';
import 'complaint_detail_screen.dart';

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _complaints = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadComplaints();
  }

  void _onTabChanged() {
    if (_tabController.index == 1) {
      _loadComplaints();
    }
  }

  Future<void> _loadComplaints() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final complaints = await ComplaintService.getUserComplaints();
      
      if (mounted) {
        setState(() {
          _complaints = complaints;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Pengaduan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFff5001),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Buat Pengaduan'),
            Tab(text: 'Riwayat Pengaduan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCreateComplaint(),
          _buildComplaintHistory(),
        ],
      ),
    );
  }

  Widget _buildCreateComplaint() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue[600],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informasi Pengaduan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sampaikan keluhan Anda dengan jelas dan lengkap. Kami akan menanggapi dalam 1x24 jam.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Quick Complaint Categories
            const Text(
              'Kategori Pengaduan Cepat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            
            const SizedBox(height: 16),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _buildQuickComplaintCard(
                  icon: Icons.construction_rounded,
                  title: 'Infrastruktur',
                  subtitle: 'Jalan, jembatan, drainase',
                  color: const Color(0xFFFF9800),
                ),
                _buildQuickComplaintCard(
                  icon: Icons.lightbulb_outline,
                  title: 'Penerangan',
                  subtitle: 'Lampu jalan, listrik',
                  color: const Color(0xFFFFC107),
                ),
                _buildQuickComplaintCard(
                  icon: Icons.water_drop_outlined,
                  title: 'Sanitasi',
                  subtitle: 'Air bersih, limbah',
                  color: const Color(0xFF2196F3),
                ),
                _buildQuickComplaintCard(
                  icon: Icons.eco_outlined,
                  title: 'Lingkungan',
                  subtitle: 'Sampah, polusi',
                  color: const Color(0xFF4CAF50),
                ),
                _buildQuickComplaintCard(
                  icon: Icons.security_outlined,
                  title: 'Keamanan',
                  subtitle: 'Ketertiban, kriminal',
                  color: const Color(0xFFF44336),
                ),
                _buildQuickComplaintCard(
                  icon: Icons.more_horiz,
                  title: 'Lainnya',
                  subtitle: 'Pengaduan umum',
                  color: const Color(0xFF9C27B0),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Manual Form
            Container(
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
                  const Text(
                    'Atau Buat Pengaduan Manual',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    'Jika kategori di atas tidak sesuai, Anda dapat membuat pengaduan dengan form lengkap.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showComplaintForm();
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Buat Pengaduan Manual'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFff5001),
                        side: const BorderSide(color: Color(0xFFff5001)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickComplaintCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showQuickComplaintForm(title);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComplaintHistory() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFff5001)),
              ),
              SizedBox(height: 16),
              Text(
                'Memuat riwayat pengaduan...',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
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
                'Gagal memuat data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadComplaints,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFff5001),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_complaints.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              const Text(
                'Belum ada pengaduan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Buat pengaduan pertama Anda di tab "Buat Pengaduan"',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  _tabController.animateTo(0);
                },
                icon: const Icon(Icons.add),
                label: const Text('Buat Pengaduan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFff5001),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadComplaints,
      color: const Color(0xFFff5001),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _complaints.length,
        itemBuilder: (context, index) {
          final complaint = _complaints[index];
          return _buildComplaintHistoryCard(complaint);
        },
      ),
    );
  }

  Widget _buildComplaintHistoryCard(Map<String, dynamic> complaint) {
    final statusConfig = ComplaintService.getStatusConfig(complaint['status'] ?? 'Baru');
    final priorityConfig = ComplaintService.getPriorityConfig(complaint['prioritas'] ?? 'Sedang');
    final categoryConfig = ComplaintService.getCategoryConfig(complaint['kategori'] ?? 'Lainnya');
    
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showComplaintDetail(complaint),
          borderRadius: BorderRadius.circular(16),
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
                        Text(
                          complaint['no_tiket'] ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFff5001),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(statusConfig['color']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusConfig['label'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(statusConfig['color']),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Title and Image
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            complaint['judul'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ),
                        // Image thumbnail
                        if (complaint['image_path'] != null) ...[
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: ReliableNetworkImage(
                                imagePath: complaint['image_path'],
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorWidget: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    color: Colors.grey[400],
                                    size: 20,
                                  ),
                                ),
                                placeholder: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.grey[400]!,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Category and Priority
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(categoryConfig['color']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            complaint['kategori'] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(categoryConfig['color']),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(priorityConfig['color']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            priorityConfig['label'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(priorityConfig['color']),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Description preview
                    if (complaint['deskripsi'] != null)
                      Text(
                        complaint['deskripsi'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
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
                        const SizedBox(width: 4),
                        Text(
                          'Dibuat: ${_formatDate(complaint['created_at'])}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    
                    // Response indicator
                    if (complaint['respon_admin'] != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.admin_panel_settings_outlined,
                            size: 16,
                            color: Colors.blue[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Ada tanggapan admin',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    // Rating (if completed)
                    if (complaint['rating'] != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text(
                            'Rating: ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          ...List.generate(5, (index) => Icon(
                            index < (complaint['rating'] ?? 0) 
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
              
              // Action buttons
              if (complaint['status'] == 'Selesai' && complaint['rating'] == null)
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
                    onPressed: () {
                      _showRatingDialog(complaint);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFff5001),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Berikan Rating',
                      style: TextStyle(
                        fontSize: 14,
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

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  void _showComplaintDetail(Map<String, dynamic> complaint) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComplaintDetailScreen(complaint: complaint),
      ),
    ).then((_) {
      // Refresh data when returning from detail
      _loadComplaints();
    });
  }

  void _showQuickComplaintForm(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComplaintFormScreen(category: category),
      ),
    ).then((_) {
      // Refresh data when returning from form
      _loadComplaints();
    });
  }

  void _showComplaintForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ComplaintFormScreen(),
      ),
    ).then((_) {
      // Refresh data when returning from form
      _loadComplaints();
    });
  }

  void _showRatingDialog(Map<String, dynamic> complaint) {
    int rating = 0;
    String feedback = '';
    final feedbackController = TextEditingController();
    bool isSubmitting = false;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Berikan Rating & Feedback',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bagaimana kepuasan Anda terhadap penanganan pengaduan ini?',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) => 
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          rating = index + 1;
                        });
                      },
                      child: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        size: 40,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: feedbackController,
                  decoration: const InputDecoration(
                    labelText: 'Feedback (Opsional)',
                    hintText: 'Berikan komentar Anda...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onChanged: (value) {
                    feedback = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: (rating > 0 && !isSubmitting) ? () async {
                setState(() {
                  isSubmitting = true;
                });
                
                try {
                  await ComplaintService.giveFeedback(
                    id: complaint['id'],
                    rating: rating,
                    feedback: feedback.isNotEmpty ? feedback : null,
                  );
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Terima kasih atas rating dan feedback Anda!'),
                        backgroundColor: Color(0xFF4CAF50),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    _loadComplaints();
                  }
                } catch (e) {
                  if (context.mounted) {
                    setState(() {
                      isSubmitting = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal mengirim rating: ${e.toString().replaceAll('Exception: ', '')}'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFff5001),
                foregroundColor: Colors.white,
              ),
              child: isSubmitting 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Kirim'),
            ),
          ],
        ),
      ),
    );
  }
}

class ComplaintFormScreen extends StatefulWidget {
  final String? category;

  const ComplaintFormScreen({super.key, this.category});

  @override
  State<ComplaintFormScreen> createState() => _ComplaintFormScreenState();
}

class _ComplaintFormScreenState extends State<ComplaintFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _imagePicker = ImagePicker();
  
  String _selectedCategory = 'Infrastruktur';
  String _selectedPriority = 'Sedang';
  bool _isLoading = false;
  File? _selectedImage;

  late List<String> _categories;
  late List<String> _priorities;

  @override
  void initState() {
    super.initState();
    _categories = ComplaintService.getCategories();
    _priorities = ComplaintService.getPriorities();
    
    if (widget.category != null && _categories.contains(widget.category!)) {
      _selectedCategory = widget.category!;
    } else {
      _selectedCategory = _categories.first;
    }
    _selectedPriority = _priorities[1]; // Default to 'Sedang'
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buat Pengaduan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFff5001),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category
              const Text(
                'Kategori Pengaduan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: _categories.map((category) => 
                  DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  ),
                ).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              
              const SizedBox(height: 20),
              
              // Priority
              const Text(
                'Prioritas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: _priorities.map((priority) => 
                  DropdownMenuItem(
                    value: priority,
                    child: Text(priority),
                  ),
                ).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPriority = value!;
                  });
                },
              ),
              
              const SizedBox(height: 20),
              
              // Title
              const Text(
                'Judul Pengaduan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _judulController,
                decoration: InputDecoration(
                  hintText: 'Masukkan judul pengaduan...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul pengaduan harus diisi';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Description
              const Text(
                'Deskripsi Masalah',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _deskripsiController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Jelaskan masalah secara detail...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi masalah harus diisi';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Photo Upload
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _selectedImage != null 
                    ? Column(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.file(
                              _selectedImage!,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Foto terpilih: ${_selectedImage!.path.split('/').last}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedImage = null;
                                    });
                                  },
                                  child: const Text(
                                    'Hapus',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tambahkan Foto (Opsional)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Foto akan membantu kami memahami masalah',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _pickImage(ImageSource.camera),
                                    icon: const Icon(Icons.camera_alt),
                                    label: const Text('Kamera'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFFff5001),
                                      side: const BorderSide(color: Color(0xFFff5001)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _pickImage(ImageSource.gallery),
                                    icon: const Icon(Icons.photo_library),
                                    label: const Text('Galeri'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFFff5001),
                                      side: const BorderSide(color: Color(0xFFff5001)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
              ),
              
              const SizedBox(height: 32),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitComplaint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFff5001),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Kirim Pengaduan',
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
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Request permissions first
      bool hasPermission = false;
      
      if (source == ImageSource.camera) {
        final cameraStatus = await Permission.camera.request();
        hasPermission = cameraStatus.isGranted;
        
        if (!hasPermission) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Izin kamera diperlukan untuk mengambil foto'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return;
        }
      } else {
        // For gallery, try different permission approaches
        var storageStatus = await Permission.storage.status;
        if (storageStatus.isDenied) {
          storageStatus = await Permission.storage.request();
        }
        
        if (!storageStatus.isGranted) {
          // Try photos permission as fallback
          var photosStatus = await Permission.photos.status;
          if (photosStatus.isDenied) {
            photosStatus = await Permission.photos.request();
          }
          hasPermission = photosStatus.isGranted;
        } else {
          hasPermission = true;
        }
        
        if (!hasPermission) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Izin akses galeri diperlukan untuk memilih foto'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return;
        }
      }

      // Try to pick image
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto berhasil dipilih'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('Error picking image: $e'); // Debug log
      if (mounted) {
        String errorMessage = 'Gagal mengambil gambar';
        
        // Handle specific error types
        if (e.toString().contains('camera_access_denied')) {
          errorMessage = 'Akses kamera ditolak. Silakan berikan izin di pengaturan aplikasi.';
        } else if (e.toString().contains('photo_access_denied')) {
          errorMessage = 'Akses galeri ditolak. Silakan berikan izin di pengaturan aplikasi.';
        } else if (e.toString().contains('network')) {
          errorMessage = 'Masalah jaringan. Periksa koneksi internet Anda.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _submitComplaint() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final complaint = await ComplaintService.createComplaint(
          judul: _judulController.text,
          kategori: _selectedCategory,
          deskripsi: _deskripsiController.text,
          prioritas: _selectedPriority,
          imageFile: _selectedImage,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Pengaduan berhasil dikirim! Nomor tiket: ${complaint['no_tiket'] ?? 'N/A'}'
              ),
              backgroundColor: const Color(0xFF4CAF50),
              behavior: SnackBarBehavior.floating,
            ),
          );
          
          // Navigate back
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal mengirim pengaduan: ${e.toString().replaceAll('Exception: ', '')}'
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}