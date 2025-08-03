import 'package:flutter/material.dart';
import '../services/complaint_service.dart';
import '../services/api_service.dart';
import '../widgets/reliable_network_image.dart';

class ComplaintDetailScreen extends StatefulWidget {
  final Map<String, dynamic> complaint;

  const ComplaintDetailScreen({
    super.key,
    required this.complaint,
  });

  @override
  State<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen> {
  late Map<String, dynamic> _complaint;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _complaint = widget.complaint;
  }

  Future<void> _refreshComplaint() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final updated = await ComplaintService.getComplaintById(_complaint['id']);
      if (updated != null) {
        setState(() {
          _complaint = updated;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat detail: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  void _showImageFullscreen(String imagePath) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(0),
        child: Stack(
          children: [
            // Background tap to close
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.transparent,
              ),
            ),
            // Image
            Center(
              child: Container(
                margin: const EdgeInsets.all(20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ReliableNetworkImage(
                    imagePath: imagePath,
                    fit: BoxFit.contain,
                    errorWidget: Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.broken_image_outlined,
                            color: Colors.grey[400],
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Gambar tidak dapat dimuat',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    placeholder: Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            color: Color(0xFFff5001),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Memuat gambar...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Close button
            Positioned(
              top: 40,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
            // Instructions
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Text(
                    'Ketuk di luar gambar atau tombol X untuk menutup',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusConfig = ComplaintService.getStatusConfig(_complaint['status'] ?? 'Baru');
    final priorityConfig = ComplaintService.getPriorityConfig(_complaint['prioritas'] ?? 'Sedang');
    final categoryConfig = ComplaintService.getCategoryConfig(_complaint['kategori'] ?? 'Lainnya');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Detail Pengaduan',
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
        actions: [
          IconButton(
            icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isLoading ? null : _refreshComplaint,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshComplaint,
        color: const Color(0xFFff5001),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
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
                    // Ticket number and status
                    Row(
                      children: [
                        Text(
                          _complaint['no_tiket'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFff5001),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(statusConfig['color']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
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
                    
                    const SizedBox(height: 16),
                    
                    // Title
                    Text(
                      _complaint['judul'] ?? '',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Category and Priority
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(categoryConfig['color']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _complaint['kategori'] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(categoryConfig['color']),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(priorityConfig['color']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
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
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Description Card
              Container(
                width: double.infinity,
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
                      'Deskripsi Masalah',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _complaint['deskripsi'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Image Card
              if (_complaint['image_path'] != null) ...[
                Container(
                  width: double.infinity,
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
                        'Foto Pengaduan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => _showImageFullscreen(_complaint['image_path']),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: ReliableNetworkImage(
                              imagePath: _complaint['image_path'],
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                              errorWidget: Container(
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image_outlined,
                                      color: Colors.grey[400],
                                      size: 48,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Gambar tidak dapat dimuat',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              placeholder: Container(
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const CircularProgressIndicator(
                                        color: Color(0xFFff5001),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Memuat gambar...',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ketuk gambar untuk melihat ukuran penuh',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Timeline Card
              Container(
                width: double.infinity,
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
                      'Timeline',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Created
                    _buildTimelineItem(
                      icon: Icons.create_outlined,
                      title: 'Pengaduan Dibuat',
                      subtitle: _formatDate(_complaint['created_at']),
                      color: const Color(0xFF2196F3),
                      isCompleted: true,
                    ),
                    
                    // Response
                    if (_complaint['tanggal_respon'] != null)
                      _buildTimelineItem(
                        icon: Icons.admin_panel_settings_outlined,
                        title: 'Tanggapan Admin',
                        subtitle: _formatDate(_complaint['tanggal_respon']),
                        color: const Color(0xFFff5001),
                        isCompleted: true,
                      ),
                    
                    // Completed
                    if (_complaint['status'] == 'Selesai')
                      _buildTimelineItem(
                        icon: Icons.check_circle_outline,
                        title: 'Pengaduan Selesai',
                        subtitle: _formatDate(_complaint['updated_at']),
                        color: const Color(0xFF4CAF50),
                        isCompleted: true,
                        isLast: true,
                      ),
                  ],
                ),
              ),

              // Admin Response Card
              if (_complaint['respon_admin'] != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.admin_panel_settings_outlined,
                            color: Colors.blue[600],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tanggapan Admin',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _complaint['respon_admin'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[800],
                          height: 1.5,
                        ),
                      ),
                      if (_complaint['tanggal_respon'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Direspon pada: ${_formatDate(_complaint['tanggal_respon'])}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              // Rating Card
              if (_complaint['rating'] != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.star_outline,
                            color: Colors.amber[600],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Rating Anda',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ...List.generate(5, (index) => Icon(
                            index < (_complaint['rating'] ?? 0) 
                                ? Icons.star 
                                : Icons.star_border,
                            size: 24,
                            color: Colors.amber[600],
                          )),
                          const SizedBox(width: 8),
                          Text(
                            '${_complaint['rating']}/5',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber[700],
                            ),
                          ),
                        ],
                      ),
                      if (_complaint['feedback'] != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Feedback:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _complaint['feedback'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.amber[800],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Action Button
              if (_complaint['status'] == 'Selesai' && _complaint['rating'] == null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showRatingDialog(),
                    icon: const Icon(Icons.star_outline),
                    label: const Text(
                      'Berikan Rating & Feedback',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFff5001),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isCompleted,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted ? color : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? color : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 8, bottom: isLast ? 0 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? const Color(0xFF2D3748) : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showRatingDialog() {
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          size: 40,
                          color: Colors.amber,
                        ),
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
                    id: _complaint['id'],
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
                    await _refreshComplaint();
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