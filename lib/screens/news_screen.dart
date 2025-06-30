import 'package:flutter/material.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  String _selectedCategory = 'Semua';
  final TextEditingController _searchController = TextEditingController();
  
  final List<String> _categories = [
    'Semua',
    'Pemberdayaan',
    'Kesehatan',
    'Pendidikan',
    'Laporan',
    'Pengumuman'
  ];

  // Mock data for news
  final List<Map<String, dynamic>> _news = [
    {
      'id': 1,
      'judul': 'Program Bantuan Sosial Terbaru 2024 Diluncurkan',
      'slug': 'program-bantuan-sosial-terbaru-2024',
      'konten': 'Pemerintah daerah meluncurkan program bantuan sosial baru untuk masyarakat kurang mampu. Program ini mencakup bantuan pendidikan, kesehatan, dan ekonomi...',
      'kategori': 'Pengumuman',
      'gambar_utama': 'https://via.placeholder.com/400x200',
      'tanggal_publikasi': '2024-01-25',
      'views': 1250,
      'author': 'Admin Dinas Sosial',
      'is_published': true,
    },
    {
      'id': 2,
      'judul': 'Pelatihan Keterampilan Gratis untuk Masyarakat',
      'slug': 'pelatihan-keterampilan-gratis',
      'konten': 'Dibuka pendaftaran pelatihan keterampilan gratis untuk meningkatkan kemampuan masyarakat dalam berbagai bidang seperti teknologi, kerajinan, dan wirausaha...',
      'kategori': 'Pemberdayaan',
      'gambar_utama': 'https://via.placeholder.com/400x200',
      'tanggal_publikasi': '2024-01-23',
      'views': 890,
      'author': 'Tim Pemberdayaan',
      'is_published': true,
    },
    {
      'id': 3,
      'judul': 'Posyandu Balita: Jadwal dan Layanan Kesehatan',
      'slug': 'posyandu-balita-jadwal-layanan',
      'konten': 'Informasi terbaru mengenai jadwal posyandu balita dan layanan kesehatan yang tersedia untuk ibu dan anak di seluruh wilayah...',
      'kategori': 'Kesehatan',
      'gambar_utama': 'https://via.placeholder.com/400x200',
      'tanggal_publikasi': '2024-01-20',
      'views': 567,
      'author': 'Puskesmas Setempat',
      'is_published': true,
    },
    {
      'id': 4,
      'judul': 'Laporan Penyaluran Bantuan Bulan Januari 2024',
      'slug': 'laporan-penyaluran-bantuan-januari-2024',
      'konten': 'Laporan lengkap penyaluran bantuan sosial bulan Januari 2024 yang telah disalurkan kepada 1,245 keluarga penerima manfaat...',
      'kategori': 'Laporan',
      'gambar_utama': 'https://via.placeholder.com/400x200',
      'tanggal_publikasi': '2024-01-18',
      'views': 432,
      'author': 'Tim Monitoring',
      'is_published': true,
    },
    {
      'id': 5,
      'judul': 'Beasiswa Pendidikan untuk Siswa Berprestasi',
      'slug': 'beasiswa-pendidikan-siswa-berprestasi',
      'konten': 'Program beasiswa pendidikan untuk siswa berprestasi dari keluarga tidak mampu. Pendaftaran dibuka hingga akhir bulan...',
      'kategori': 'Pendidikan',
      'gambar_utama': 'https://via.placeholder.com/400x200',
      'tanggal_publikasi': '2024-01-15',
      'views': 1089,
      'author': 'Dinas Pendidikan',
      'is_published': true,
    },
  ];

  List<Map<String, dynamic>> get _filteredNews {
    var filtered = _news.where((news) => news['is_published']).toList();
    
    if (_selectedCategory != 'Semua') {
      filtered = filtered.where((news) => 
          news['kategori'] == _selectedCategory).toList();
    }
    
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered.where((news) =>
          news['judul'].toLowerCase().contains(searchTerm) ||
          news['konten'].toLowerCase().contains(searchTerm)).toList();
    }
    
    // Sort by date (newest first)
    filtered.sort((a, b) => b['tanggal_publikasi'].compareTo(a['tanggal_publikasi']));
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Berita & Artikel',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF667eea),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Cari berita...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF667eea)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
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
                  borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          
          // Category Filter
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.white,
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
                    backgroundColor: Colors.grey[100],
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
          
          // News List
          Expanded(
            child: _filteredNews.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredNews.length,
                    itemBuilder: (context, index) {
                      final news = _filteredNews[index];
                      return _buildNewsCard(news);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isNotEmpty
                ? 'Tidak ada berita yang sesuai dengan pencarian'
                : 'Belum ada berita tersedia',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (_searchController.text.isNotEmpty)
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() {});
              },
              child: const Text(
                'Hapus pencarian',
                style: TextStyle(
                  color: Color(0xFF667eea),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(Map<String, dynamic> news) {
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
          onTap: () => _showNewsDetail(news),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: const Color(0xFF667eea).withOpacity(0.1),
                        child: const Icon(
                          Icons.image_outlined,
                          size: 50,
                          color: Color(0xFF667eea),
                        ),
                      ),
                      // Category badge
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(news['kategori']).withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            news['kategori'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      news['judul'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Content preview
                    Text(
                      news['konten'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Meta information
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          news['author'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(news['tanggal_publikasi']),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              Icons.visibility_outlined,
                              size: 16,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              news['views'].toString(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Pemberdayaan':
        return const Color(0xFF4CAF50);
      case 'Kesehatan':
        return const Color(0xFF2196F3);
      case 'Pendidikan':
        return const Color(0xFFFF9800);
      case 'Laporan':
        return const Color(0xFF9C27B0);
      case 'Pengumuman':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF667eea);
    }
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Hari ini';
    } else if (difference == 1) {
      return 'Kemarin';
    } else if (difference < 7) {
      return '$difference hari lalu';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showNewsDetail(Map<String, dynamic> news) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsDetailScreen(news: news),
      ),
    );
  }
}

class NewsDetailScreen extends StatelessWidget {
  final Map<String, dynamic> news;

  const NewsDetailScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: const Color(0xFF667eea),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: const Color(0xFF667eea).withOpacity(0.1),
                child: const Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 80,
                    color: Color(0xFF667eea),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(news['kategori']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        news['kategori'],
                        style: TextStyle(
                          fontSize: 14,
                          color: _getCategoryColor(news['kategori']),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Title
                    Text(
                      news['judul'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                        height: 1.3,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Meta information
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 18,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          news['author'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(news['tanggal_publikasi']),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              Icons.visibility_outlined,
                              size: 18,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              news['views'].toString(),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    const Divider(),
                    
                    const SizedBox(height: 24),
                    
                    // Content
                    Text(
                      news['konten'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2D3748),
                        height: 1.6,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Share button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Handle share functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fitur berbagi akan segera tersedia'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.share_outlined),
                        label: const Text('Bagikan Artikel'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF667eea),
                          side: const BorderSide(color: Color(0xFF667eea)),
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
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Pemberdayaan':
        return const Color(0xFF4CAF50);
      case 'Kesehatan':
        return const Color(0xFF2196F3);
      case 'Pendidikan':
        return const Color(0xFFFF9800);
      case 'Laporan':
        return const Color(0xFF9C27B0);
      case 'Pengumuman':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF667eea);
    }
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
  }
}