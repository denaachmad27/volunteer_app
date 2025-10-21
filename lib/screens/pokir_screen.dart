import 'package:flutter/material.dart';
import '../services/pokir_service.dart';

class PokirScreen extends StatefulWidget {
  const PokirScreen({super.key});

  @override
  State<PokirScreen> createState() => _PokirScreenState();
}

class _PokirScreenState extends State<PokirScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<PokirItem> _allPokir = [];
  List<PokirItem> _proposedPokir = [];
  List<PokirItem> _approvedPokir = [];
  List<PokirItem> _inProgressPokir = [];
  List<PokirItem> _completedPokir = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadPokirData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPokirData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await PokirService.getPokirList();

      if (response.success && mounted) {
        setState(() {
          _allPokir = response.data;
          _proposedPokir = response.data.where((p) => p.status.toLowerCase() == 'proposed').toList();
          _approvedPokir = response.data.where((p) => p.status.toLowerCase() == 'approved').toList();
          _inProgressPokir = response.data.where((p) => p.status.toLowerCase() == 'in_progress').toList();
          _completedPokir = response.data.where((p) => p.status.toLowerCase() == 'completed').toList();
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
          'Pokok Pikiran (Pokir)',
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
            Tab(text: 'Semua (${_allPokir.length})'),
            Tab(text: 'Diusulkan (${_proposedPokir.length})'),
            Tab(text: 'Disetujui (${_approvedPokir.length})'),
            Tab(text: 'Proses (${_inProgressPokir.length})'),
            Tab(text: 'Selesai (${_completedPokir.length})'),
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
                _buildPokirList(_allPokir),
                _buildPokirList(_proposedPokir),
                _buildPokirList(_approvedPokir),
                _buildPokirList(_inProgressPokir),
                _buildPokirList(_completedPokir),
              ],
            ),
    );
  }

  Widget _buildPokirList(List<PokirItem> pokirList) {
    if (pokirList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb_outline_rounded,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada data pokir',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadPokirData,
              child: const Text('Muat Ulang'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPokirData,
      color: const Color(0xFFff5001),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pokirList.length,
        itemBuilder: (context, index) {
          return _buildPokirCard(pokirList[index]);
        },
      ),
    );
  }

  Widget _buildPokirCard(PokirItem pokir) {
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
          onTap: () => _showPokirDetail(pokir),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status and Priority badges
                Row(
                  children: [
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(PokirService.getStatusColor(pokir.status)).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: Color(PokirService.getStatusColor(pokir.status)),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            PokirService.getStatusLabel(pokir.status),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(PokirService.getStatusColor(pokir.status)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Priority badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(PokirService.getPrioritasColor(pokir.prioritas)).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.flag,
                            size: 12,
                            color: Color(PokirService.getPrioritasColor(pokir.prioritas)),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            PokirService.getPrioritasLabel(pokir.prioritas),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(PokirService.getPrioritasColor(pokir.prioritas)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(PokirService.getCategoryColor(pokir.kategori)).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        PokirService.getCategoryLabel(pokir.kategori),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(PokirService.getCategoryColor(pokir.kategori)),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Title
                Text(
                  pokir.judul,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),

                const SizedBox(height: 8),

                // Description
                Text(
                  pokir.deskripsi,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                // Location (if available)
                if (pokir.lokasiPelaksanaan != null && pokir.lokasiPelaksanaan!.isNotEmpty) ...[
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
                          pokir.lokasiPelaksanaan!,
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
                ],

                // Target date (if available)
                if (pokir.targetPelaksanaan != null && pokir.targetPelaksanaan!.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Target: ${PokirService.formatDate(pokir.targetPelaksanaan)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                // Legislative member
                if (pokir.legislativeMemberName != null) ...[
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
                          pokir.legislativeMemberName!,
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
        ),
      ),
    );
  }

  void _showPokirDetail(PokirItem pokir) {
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
                      // Badges row
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Color(PokirService.getStatusColor(pokir.status)).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: Color(PokirService.getStatusColor(pokir.status)),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  PokirService.getStatusLabel(pokir.status),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(PokirService.getStatusColor(pokir.status)),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Priority badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Color(PokirService.getPrioritasColor(pokir.prioritas)).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.flag,
                                  size: 12,
                                  color: Color(PokirService.getPrioritasColor(pokir.prioritas)),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  PokirService.getPrioritasLabel(pokir.prioritas),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(PokirService.getPrioritasColor(pokir.prioritas)),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Category badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Color(PokirService.getCategoryColor(pokir.kategori)).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.category_outlined,
                                  size: 12,
                                  color: Color(PokirService.getCategoryColor(pokir.kategori)),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  PokirService.getCategoryLabel(pokir.kategori),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(PokirService.getCategoryColor(pokir.kategori)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Title
                      Text(
                        pokir.judul,
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
                        pokir.deskripsi,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Details
                      if (pokir.lokasiPelaksanaan != null && pokir.lokasiPelaksanaan!.isNotEmpty) ...[
                        _buildDetailRow(
                          icon: Icons.location_on_outlined,
                          label: 'Lokasi Pelaksanaan',
                          value: pokir.lokasiPelaksanaan!,
                        ),
                        const SizedBox(height: 12),
                      ],

                      if (pokir.targetPelaksanaan != null && pokir.targetPelaksanaan!.isNotEmpty) ...[
                        _buildDetailRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Target Pelaksanaan',
                          value: PokirService.formatDate(pokir.targetPelaksanaan),
                        ),
                        const SizedBox(height: 12),
                      ],

                      if (pokir.legislativeMemberName != null) ...[
                        _buildDetailRow(
                          icon: Icons.person_outline,
                          label: 'Anggota Legislatif',
                          value: pokir.legislativeMemberName!,
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
