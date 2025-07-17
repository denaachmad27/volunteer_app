import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'bantuan_sosial_screen.dart';
import 'news_screen.dart';
import 'complaint_screen.dart';
import '../services/auth_service.dart';
import '../services/news_service.dart';
import '../services/profile_completion_service.dart';
import '../services/profile_service.dart';
import '../widgets/robust_network_image.dart';
import '../widgets/reliable_network_image.dart';
import '../widgets/profile_completion_card.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onTabChange;
  
  const HomeScreen({super.key, this.onTabChange});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  User? _currentUser;
  bool _isLoading = true;
  List<NewsItem> _latestNews = [];
  bool _newsLoading = true;
  Map<String, dynamic>? _profileCompletion;
  bool _profileCompletionLoading = true;
  Map<String, dynamic>? _profileData;
  bool _profileDataLoading = true;

  @override
  void initState() {
    super.initState();
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

    _loadUserData();
    _loadLatestNews();
    _loadProfileCompletion();
    _loadProfileData();
    _animationController.forward();
    
    // Retry loading news after a short delay if needed
    Future.delayed(const Duration(seconds: 2), () {
      if (_latestNews.isEmpty && !_newsLoading) {
        print('=== HOME SCREEN: Retrying news load after delay ===');
        _loadLatestNews();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh profile completion when returning to home screen
    if (mounted) {
      _loadProfileCompletion();
      _loadProfileData();
    }
  }

  Future<void> _loadUserData() async {
    try {
      final user = await AuthService.getCurrentUser();
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadLatestNews() async {
    print('=== HOME SCREEN: Starting to load latest news ===');
    try {
      final response = await NewsService.getPublishedNews();
      print('=== HOME SCREEN: News response received ===');
      print('Success: ${response.success}');
      print('Data count: ${response.data.length}');
      print('Message: ${response.message}');
      
      if (response.success && response.data.isNotEmpty) {
        print('=== HOME SCREEN: Processing ${response.data.length} news items ===');
        
        // Show all news items for debugging
        for (int i = 0; i < response.data.length; i++) {
          final news = response.data[i];
          print('News ${i + 1}: ${news.judul}');
          print('  - Published: ${news.tanggalPublikasi}');
          print('  - Image: ${news.gambarUtama}');
          print('  - Category: ${news.kategori}');
        }
        
        setState(() {
          // Sort by date and take only 2 latest news
          _latestNews = response.data
              .where((news) => news.tanggalPublikasi != null)
              .toList()
            ..sort((a, b) {
              final dateA = DateTime.tryParse(a.tanggalPublikasi!) ?? DateTime(1970);
              final dateB = DateTime.tryParse(b.tanggalPublikasi!) ?? DateTime(1970);
              return dateB.compareTo(dateA); // Newest first
            });
          
          if (_latestNews.length > 2) {
            _latestNews = _latestNews.take(2).toList();
          }
          
          print('=== HOME SCREEN: Final news count: ${_latestNews.length} ===');
          _newsLoading = false;
        });
      } else {
        print('=== HOME SCREEN: No news available or failed response ===');
        setState(() {
          _newsLoading = false;
        });
      }
    } catch (e) {
      print('=== HOME SCREEN: Error loading latest news ===');
      print('Error: $e');
      print('Stack trace: ${StackTrace.current}');
      setState(() {
        _newsLoading = false;
      });
    }
  }

  Future<void> _loadProfileCompletion() async {
    try {
      final completionData = await ProfileCompletionService.getProfileCompletionStatus();
      final completion = ProfileCompletionService.calculateCompletion(completionData);
      
      setState(() {
        _profileCompletion = completion;
        _profileCompletionLoading = false;
      });
    } catch (e) {
      print('Error loading profile completion: $e');
      setState(() {
        _profileCompletionLoading = false;
      });
    }
  }

  Future<void> _loadProfileData() async {
    try {
      final profileData = await ProfileService.getProfile();
      setState(() {
        _profileData = profileData;
        _profileDataLoading = false;
      });
    } catch (e) {
      print('Error loading profile data: $e');
      setState(() {
        _profileDataLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToTab(int tabIndex) {
    if (widget.onTabChange != null) {
      widget.onTabChange!(tabIndex);
    }
  }

  void _navigateToScreen(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
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
              Color(0xFF667eea),
              Color(0xFF764ba2),
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
                          color: Colors.white.withOpacity(0.2),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: !_profileDataLoading && _profileData != null && _profileData!['foto_profil'] != null
                            ? ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: ProfileService.getProfilePhotoUrl(_profileData!['foto_profil']),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.white.withOpacity(0.2),
                                    child: const Icon(
                                      Icons.person_outline,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => const Icon(
                                    Icons.person_outline,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.person_outline,
                                color: Colors.white,
                                size: 24,
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selamat Datang',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _isLoading 
                                  ? 'Loading...' 
                                  : _currentUser?.name ?? 'Volunteer User',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // Handle notifications
                        },
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Main Content
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Quick Stats
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    title: 'Bantuan Aktif',
                                    value: '2',
                                    icon: Icons.volunteer_activism_rounded,
                                    color: const Color(0xFF4CAF50),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildStatCard(
                                    title: 'Pengaduan',
                                    value: '1',
                                    icon: Icons.report_problem_rounded,
                                    color: const Color(0xFFFF9800),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Profile Completion Reminder
                            if (!_profileCompletionLoading && _profileCompletion != null)
                              ProfileCompletionCard(
                                percentage: _profileCompletion!['percentage'],
                                completedSections: _profileCompletion!['completed_sections'],
                                totalSections: _profileCompletion!['total_sections'],
                                nextStep: _profileCompletion!['next_step'],
                                nextRoute: _profileCompletion!['next_route'],
                                isComplete: _profileCompletion!['is_complete'],
                                message: ProfileCompletionService.getCompletionMessage(_profileCompletion!['percentage']),
                                onRefresh: _loadProfileCompletion,
                              ),
                            
                            // Quick Actions
                            const Text(
                              'Layanan Utama',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.1,
                              children: [
                                _buildQuickActionCard(
                                  icon: Icons.volunteer_activism_rounded,
                                  title: 'Bantuan Sosial',
                                  subtitle: 'Ajukan bantuan',
                                  color: const Color(0xFF667eea),
                                  onTap: () => _navigateToScreen(const BantuanSosialScreen()),
                                ),
                                _buildQuickActionCard(
                                  icon: Icons.article_rounded,
                                  title: 'Berita Terbaru',
                                  subtitle: 'Informasi terkini',
                                  color: const Color(0xFF2196F3),
                                  onTap: () => _navigateToScreen(const NewsScreen()),
                                ),
                                _buildQuickActionCard(
                                  icon: Icons.report_problem_rounded,
                                  title: 'Buat Pengaduan',
                                  subtitle: 'Laporkan masalah',
                                  color: const Color(0xFFFF9800),
                                  onTap: () => _navigateToScreen(const ComplaintScreen()),
                                ),
                                _buildQuickActionCard(
                                  icon: Icons.settings_rounded,
                                  title: 'Pengaturan',
                                  subtitle: 'Kelola aplikasi',
                                  color: const Color(0xFF9C27B0),
                                  onTap: () => _navigateToTab(4), // Navigate to Settings tab
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Recent News Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Berita Terbaru',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D3748),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => _navigateToScreen(const NewsScreen()),
                                  child: const Text('Lihat Semua'),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // News Cards
                            _newsLoading 
                              ? Column(
                                  children: [
                                    _buildNewsCardSkeleton(),
                                    const SizedBox(height: 12),
                                    _buildNewsCardSkeleton(),
                                  ],
                                )
                              : _latestNews.isEmpty
                                  ? Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey[200]!),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.article_outlined,
                                            size: 48,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Belum ada berita terbaru',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          TextButton(
                                            onPressed: _loadLatestNews,
                                            child: const Text('Coba Lagi'),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Column(
                                      children: _latestNews.map((news) => 
                                        Column(
                                          children: [
                                            _buildNewsCard(
                                              news: news,
                                              title: news.judul,
                                              summary: news.excerpt ?? (news.konten.isNotEmpty ? '${news.konten.substring(0, news.konten.length > 120 ? 120 : news.konten.length)}...' : ''),
                                              date: NewsService.formatDate(news.tanggalPublikasi),
                                              category: news.kategori,
                                              imageUrl: NewsService.getImageUrl(news.gambarUtama),
                                            ),
                                            if (_latestNews.indexOf(news) < _latestNews.length - 1)
                                              const SizedBox(height: 12),
                                          ],
                                        )
                                      ).toList(),
                                    ),
                          ],
                        ),
                      ),
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Container(
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
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
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

  Widget _buildNewsCard({
    required String title,
    required String summary,
    required String date,
    required String category,
    String? imageUrl,
    NewsItem? news,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: news != null ? () => _navigateToNewsDetail(news) : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image thumbnail
                if (imageUrl != null)
                  Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ReliableNetworkImage(
                        imagePath: imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                              ),
                            ),
                          ),
                        ),
                        errorWidget: Container(
                          color: Colors.grey[100],
                          child: const Center(
                            child: Icon(
                              Icons.image_outlined,
                              color: Colors.grey,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Color(NewsService.getCategoryColor(category)).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(NewsService.getCategoryColor(category)),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            date,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        summary,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewsCardSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image skeleton
            Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
            ),
            
            // Content skeleton
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 80,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity * 0.7,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(7),
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

  void _navigateToNewsDetail(NewsItem news) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsDetailScreen(news: news),
      ),
    );
  }
}