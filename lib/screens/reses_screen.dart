import 'package:flutter/material.dart';
import '../services/reses_service.dart';
import '../widgets/reliable_network_image.dart';

class ResesScreen extends StatefulWidget {
  const ResesScreen({super.key});

  @override
  State<ResesScreen> createState() => _ResesScreenState();
}

class _ResesScreenState extends State<ResesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<ResesItem> _allReses = [];
  List<ResesItem> _scheduledReses = [];
  List<ResesItem> _ongoingReses = [];
  List<ResesItem> _completedReses = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadResesData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadResesData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ResesService.getResesList();

      if (response.success && mounted) {
        setState(() {
          _allReses = response.data;
          _scheduledReses = response.data.where((r) => r.status.toLowerCase() == 'scheduled').toList();
          _ongoingReses = response.data.where((r) => r.status.toLowerCase() == 'ongoing').toList();
          _completedReses = response.data.where((r) => r.status.toLowerCase() == 'completed').toList();
          _isLoading = false;
        });
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFff5001),
        title: const Text(
          'Reses',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          isScrollable: true,
          tabs: [
            Tab(text: 'Semua (${_allReses.length})'),
            Tab(text: 'Dijadwalkan (${_scheduledReses.length})'),
            Tab(text: 'Berlangsung (${_ongoingReses.length})'),
            Tab(text: 'Selesai (${_completedReses.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFff5001)),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildResesList(_allReses),
                _buildResesList(_scheduledReses),
                _buildResesList(_ongoingReses),
                _buildResesList(_completedReses),
              ],
            ),
    );
  }

  Widget _buildResesList(List<ResesItem> resesList) {
    if (resesList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada data reses',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadResesData,
              child: const Text('Muat Ulang'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadResesData,
      color: const Color(0xFFff5001),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: resesList.length,
        itemBuilder: (context, index) {
          return _buildResesCard(resesList[index]);
        },
      ),
    );
  }

  Widget _buildResesCard(ResesItem reses) {
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
          onTap: () => _showResesDetail(reses),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              if (reses.fotoKegiatan != null && reses.fotoKegiatan!.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: ReliableNetworkImage(
                    imagePath: ResesService.getImageUrl(reses.fotoKegiatan),
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    placeholder: Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFff5001)),
                        ),
                      ),
                    ),
                    errorWidget: Container(
                      height: 180,
                      color: Colors.grey[100],
                      child: const Center(
                        child: Icon(
                          Icons.image_outlined,
                          color: Colors.grey,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),

              // Content section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(ResesService.getStatusColor(reses.status)).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 8,
                                color: Color(ResesService.getStatusColor(reses.status)),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                ResesService.getStatusLabel(reses.status),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(ResesService.getStatusColor(reses.status)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Title
                    Text(
                      reses.judul,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Description
                    Text(
                      reses.deskripsi,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 12),

                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            reses.lokasi,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Date range
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${ResesService.formatDate(reses.tanggalMulai)} - ${ResesService.formatDate(reses.tanggalSelesai)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    // Legislative member
                    if (reses.legislativeMemberName != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 18,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              reses.legislativeMemberName!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResesDetail(ResesItem reses) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
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
                      // Image
                      if (reses.fotoKegiatan != null && reses.fotoKegiatan!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: ReliableNetworkImage(
                            imagePath: ResesService.getImageUrl(reses.fotoKegiatan),
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            placeholder: Container(
                              height: 200,
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFff5001)),
                                ),
                              ),
                            ),
                            errorWidget: Container(
                              height: 200,
                              color: Colors.grey[100],
                              child: const Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  color: Colors.grey,
                                  size: 48,
                                ),
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(ResesService.getStatusColor(reses.status)).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 8,
                              color: Color(ResesService.getStatusColor(reses.status)),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              ResesService.getStatusLabel(reses.status),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(ResesService.getStatusColor(reses.status)),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Title
                      Text(
                        reses.judul,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Description
                      const Text(
                        'Deskripsi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        reses.deskripsi,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Details
                      _buildDetailRow(
                        icon: Icons.location_on_outlined,
                        label: 'Lokasi',
                        value: reses.lokasi,
                      ),

                      const SizedBox(height: 12),

                      _buildDetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Tanggal Mulai',
                        value: ResesService.formatDate(reses.tanggalMulai),
                      ),

                      const SizedBox(height: 12),

                      _buildDetailRow(
                        icon: Icons.event_outlined,
                        label: 'Tanggal Selesai',
                        value: ResesService.formatDate(reses.tanggalSelesai),
                      ),

                      if (reses.legislativeMemberName != null) ...[
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          icon: Icons.person_outline,
                          label: 'Anggota Legislatif',
                          value: reses.legislativeMemberName!,
                        ),
                      ],
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

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFff5001).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFFff5001),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF2D3748),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
