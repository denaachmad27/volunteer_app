import 'package:flutter/material.dart';
import '../services/news_service.dart';
import '../services/auth_service.dart';
import '../widgets/reliable_network_image.dart';
import 'add_news_screen.dart';
import 'edit_news_screen.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  String _selectedCategory = 'Semua';
  final TextEditingController _searchController = TextEditingController();
  List<NewsItem> _news = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  User? _currentUser;

  final List<String> _categories = NewsService.getCategories();

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadNews();
  }

  Future<void> _loadCurrentUser() async {
    final user = await AuthService.getCurrentUser();
    setState(() {
      _currentUser = user;
    });
  }

  // Load news from API
  Future<void> _loadNews() async {
    print('=== Loading News ===');
    print('Category: $_selectedCategory');
    print('Search: ${_searchController.text}');
    
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await NewsService.getPublishedNews(
        kategori: _selectedCategory != 'Semua' ? _selectedCategory : null,
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
      );

      print('News Response: success=${response.success}, data_length=${response.data.length}');

      if (response.success) {
        setState(() {
          _news = response.data;
          _isLoading = false;
        });
        print('News loaded successfully: ${_news.length} items');
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = response.message ?? 'Gagal memuat berita';
          _isLoading = false;
        });
        print('News loading failed: ${response.message}');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
      print('News loading exception: $e');
    }
  }

  List<NewsItem> get _filteredNews {
    return _news; // Filtering is now done by the API
  }

  Future<void> _navigateToAddNews() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddNewsScreen(),
      ),
    );

    // Reload news if a new news was added
    if (result == true) {
      _loadNews();
    }
  }

  Future<void> _navigateToEditNews(NewsItem news) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNewsScreen(news: news),
      ),
    );

    // Reload news if the news was updated
    if (result == true) {
      _loadNews();
    }
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
        backgroundColor: const Color(0xFFff5001),
        elevation: 0,
      ),
      floatingActionButton: _currentUser != null && _currentUser!.isAdmin
          ? FloatingActionButton.extended(
              onPressed: _navigateToAddNews,
              backgroundColor: const Color(0xFFff5001),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Tambah Berita',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                // Debounce search to avoid too many API calls
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_searchController.text == value) {
                    _loadNews();
                  }
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari berita...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFFff5001)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadNews();
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
                  borderSide: const BorderSide(color: Color(0xFFff5001), width: 2),
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
                      _loadNews();
                    },
                    backgroundColor: Colors.grey[100],
                    selectedColor: const Color(0xFFff5001).withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFFff5001) : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFFff5001) : Colors.grey[300]!,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // News List
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _hasError
                    ? _buildErrorState()
                    : _filteredNews.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _loadNews,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredNews.length,
                              itemBuilder: (context, index) {
                                final news = _filteredNews[index];
                                return _buildNewsCard(news);
                              },
                            ),
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
                _loadNews();
              },
              child: const Text(
                'Hapus pencarian',
                style: TextStyle(
                  color: Color(0xFFff5001),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (_searchController.text.isEmpty)
            Column(
              children: [
                const SizedBox(height: 16),
                Text(
                  'Tips: Pastikan Anda terhubung ke internet\ndan server backend sedang berjalan',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadNews,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFff5001),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Muat Ulang'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFff5001)),
          ),
          SizedBox(height: 16),
          Text(
            'Memuat berita...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak dapat memuat berita',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Text(
                _errorMessage,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red[700],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            if (_errorMessage.contains('Connection refused') || _errorMessage.contains('terhubung'))
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'Tips Troubleshooting:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Pastikan Laravel backend berjalan di port 8000\n• Jalankan: php artisan serve --host=0.0.0.0\n• Pastikan menggunakan Android Emulator\n• Cek firewall/antivirus tidak memblokir',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[600],
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _loadNews,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFff5001),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: () {
                    // Test connection
                    _testConnection();
                  },
                  icon: const Icon(Icons.network_check),
                  label: const Text('Test Koneksi'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _testImageConnectivity,
              icon: const Icon(Icons.image),
              label: const Text('Test Gambar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testConnection() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Testing koneksi ke server...'),
        duration: Duration(seconds: 1),
      ),
    );
    
    try {
      final response = await NewsService.getPublishedNews();
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Koneksi berhasil!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadNews(); // Reload if connection is successful
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Koneksi gagal: ${response.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _testImageConnectivity() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Testing koneksi gambar...'),
        duration: Duration(seconds: 1),
      ),
    );
    
    if (_news.isNotEmpty) {
      // Test first news item with image
      final firstNewsWithImage = _news.firstWhere(
        (news) => news.gambarUtama != null && news.gambarUtama!.isNotEmpty,
        orElse: () => _news.first,
      );
      
      final testResult = await NewsService.testImageConnectivity(firstNewsWithImage.gambarUtama);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(testResult 
            ? '✅ Gambar dapat diakses!' 
            : '❌ Gambar tidak dapat diakses'),
          backgroundColor: testResult ? Colors.green : Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Tidak ada berita untuk ditest'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Widget _buildNewsCard(NewsItem news) {
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
                        color: const Color(0xFFff5001).withOpacity(0.1),
                        child: const Icon(
                          Icons.image_outlined,
                          size: 50,
                          color: Color(0xFFff5001),
                        ),
                      ),
                      // Category badge
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(NewsService.getCategoryColor(news.kategori)).withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            news.kategori,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      // Edit button for admin
                      if (_currentUser != null && _currentUser!.isAdmin)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => _navigateToEditNews(news),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: const Icon(
                                  Icons.edit,
                                  size: 20,
                                  color: Color(0xFFff5001),
                                ),
                              ),
                            ),
                          ),
                        ),
                      // Real image or placeholder
                      Positioned.fill(
                        child: ReliableNetworkImage(
                          imagePath: news.gambarUtama,
                          fit: BoxFit.cover,
                          placeholder: Container(
                            color: const Color(0xFFff5001).withOpacity(0.1),
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFff5001)),
                              ),
                            ),
                          ),
                          errorWidget: Container(
                            color: const Color(0xFFff5001).withOpacity(0.1),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image_outlined,
                                  size: 40,
                                  color: Color(0xFFff5001),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Gambar tidak dapat dimuat',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFFff5001),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Periksa koneksi server',
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
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
                      news.judul,
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
                      news.excerpt ?? news.konten,
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
                          news.author ?? 'Unknown',
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
                          NewsService.formatDate(news.tanggalPublikasi),
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
                              news.views.toString(),
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



  void _showNewsDetail(NewsItem news) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsDetailScreen(news: news),
      ),
    );
  }
}

class NewsDetailScreen extends StatelessWidget {
  final NewsItem news;

  const NewsDetailScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Detail Berita',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFff5001),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: ReliableNetworkImage(
                    imagePath: news.gambarUtama,
                    fit: BoxFit.cover,
                    placeholder: Container(
                      color: const Color(0xFFff5001).withOpacity(0.1),
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFff5001)),
                        ),
                      ),
                    ),
                    errorWidget: Container(
                      color: const Color(0xFFff5001).withOpacity(0.1),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              size: 80,
                              color: Color(0xFFff5001),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Gambar tidak dapat dimuat',
                              style: TextStyle(
                                color: Color(0xFFff5001),
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

              // Content Container
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      news.judul,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Tags Chips Row
                    if (news.tags.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: news.tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFff5001).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFff5001).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.local_offer,
                                  size: 14,
                                  color: Color(0xFFff5001),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  tag,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFFff5001),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                    if (news.tags.isNotEmpty) const SizedBox(height: 16),

                    // Meta Info Row
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          news.author ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          NewsService.formatDate(news.tanggalPublikasi),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(NewsService.getCategoryColor(news.kategori)).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bookmark,
                            size: 14,
                            color: Color(NewsService.getCategoryColor(news.kategori)),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            news.kategori,
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(NewsService.getCategoryColor(news.kategori)),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Content Text
                    Text(
                      news.konten,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2D3748),
                        height: 1.7,
                      ),
                      textAlign: TextAlign.justify,
                    ),

                    const SizedBox(height: 32),

                    // Share Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fitur berbagi akan segera tersedia'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.share_outlined),
                        label: const Text('Bagikan Berita'),
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

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}