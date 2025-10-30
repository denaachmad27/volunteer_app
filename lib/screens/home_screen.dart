import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'bantuan_sosial_screen.dart';
import 'news_screen.dart';
import 'complaint_screen.dart';
import 'aleg_dashboard_screen.dart';
import 'relawan_warga_screen.dart';
import 'reses_screen.dart';
import 'pokir_screen.dart';
import '../services/auth_service.dart';
import '../services/news_service.dart';
import '../services/profile_completion_service.dart';
import '../services/profile_service.dart';
import '../services/legislative_service.dart';
import '../services/relawan_service.dart';
import '../services/bantuan_sosial_service.dart';
import '../services/complaint_service.dart';
import '../widgets/reliable_network_image.dart';
import '../widgets/profile_completion_card.dart';
import '../widgets/legislative_member_card.dart';
import 'legislative_member_detail_screen.dart';

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
  LegislativeMember? _userLegislativeMember;
  bool _legislativeLoading = true;
  int? _wargaCount;
  bool _wargaCountLoading = false;
  int? _bantuanAktifCount;
  bool _bantuanLoading = false;
  int? _pengaduanCount;
  bool _pengaduanLoading = false;
  List<LegislativeMember> _allLegislativeMembers = [];
  int _currentLegislativeIndex = 0;
  bool _allLegislativeLoading = false;

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
    _loadUserLegislativeMember();
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
      _loadUserLegislativeMember();
    }
  }

  Future<void> _loadUserData() async {
    try {
      final user = await AuthService.getCurrentUser();
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
      // Load warga count if the user is relawan
      await _loadRelawanWargaCount();
      // Load stats data if the user is admin
      if (user?.role == 'admin') {
        await _loadAdminStats();
        await _loadAllLegislativeMembers();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRelawanWargaCount() async {
    final role = _currentUser?.role;
    if (role != 'relawan' && role != 'user') return;
    setState(() { _wargaCountLoading = true; });
    try {
      final page = await RelawanService.listWarga(page: 1, perPage: 1);
      if (!mounted) return;
      setState(() {
        _wargaCount = page.total;
        _wargaCountLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _wargaCountLoading = false; });
    }
  }

  Future<void> _loadLatestNews() async {
    print('=== HOME SCREEN: Starting to load latest news ===');
    try {
      // Use different endpoint for admin to get all news without id_aleg filter
      NewsResponse response;
      if (_currentUser?.role == 'admin') {
        // Test with debug endpoint first
        print('=== HOME SCREEN: Testing debug endpoint ===');
        final testResponse = await NewsService.getAllNewsTest();
        print('Test response keys: ${testResponse.keys}');
        if (testResponse['success'] == true) {
          print('Test total news: ${testResponse['data']['total']}');
        }

        response = await NewsService.getAllNewsForAdmin();
      } else {
        response = await NewsService.getPublishedNews();
      }
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

  Future<void> _loadAdminStats() async {
    setState(() {
      _bantuanLoading = true;
      _pengaduanLoading = true;
    });

    try {
      // Load bantuan aktif count
      final bantuanResponse = await BantuanSosialService.getUserApplications();
      final bantuanCount = bantuanResponse['success'] == true
          ? (bantuanResponse['data'] as List).length
          : 0;

      // Load pengaduan count
      final pengaduanResponse = await ComplaintService.getUserComplaints();
      final pengaduanCount = pengaduanResponse.length;

      if (mounted) {
        setState(() {
          _bantuanAktifCount = bantuanCount;
          _pengaduanCount = pengaduanCount;
          _bantuanLoading = false;
          _pengaduanLoading = false;
        });
      }
    } catch (e) {
      print('Error loading admin stats: $e');
      if (mounted) {
        setState(() {
          _bantuanAktifCount = 0;
          _pengaduanCount = 0;
          _bantuanLoading = false;
          _pengaduanLoading = false;
        });
      }
    }
  }

  Future<void> _loadAllLegislativeMembers() async {
    if (_currentUser?.role != 'admin') return;

    setState(() {
      _allLegislativeLoading = true;
    });

    try {
      final response = await LegislativeService.getAllLegislativeMembers(limit: 100);

      if (response['success'] == true && response['data'] != null) {
        final members = response['data'] as List<LegislativeMember>;

        if (mounted) {
          setState(() {
            _allLegislativeMembers = members;
            _allLegislativeLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _allLegislativeMembers = [];
            _allLegislativeLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading all legislative members: $e');
      if (mounted) {
        setState(() {
          _allLegislativeMembers = [];
          _allLegislativeLoading = false;
        });
      }
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

  Future<void> _loadUserLegislativeMember() async {
    try {
      print('=== HOME SCREEN: Loading user\'s legislative member ===');
      final member = await LegislativeService.getUserLegislativeMember();
      
      setState(() {
        _userLegislativeMember = member;
        _legislativeLoading = false;
      });
      
      if (member != null) {
        print('=== HOME SCREEN: User legislative member loaded: ${member.namaLengkap} ===');
      } else {
        print('=== HOME SCREEN: No legislative member associated with user ===');
      }
    } catch (e) {
      print('=== HOME SCREEN: Error loading user legislative member: $e ===');
      setState(() {
        _legislativeLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Expose a safe refresh method for parent widgets
  void refreshProfile() {
    if (mounted) {
      _loadProfileData();
    }
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
                        child: !_profileDataLoading && _profileData != null && _profileData!['foto_profil'] != null
                            ? ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: ProfileService.getProfilePhotoUrl(
                                    _profileData!['foto_profil'],
                                    version: _profileData!['updated_at']?.toString(),
                                  ),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.white.withValues(alpha: 0.2),
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
                                color: Colors.white.withValues(alpha: 0.8),
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
                                    value: _currentUser?.role == 'admin'
                                        ? (_bantuanLoading ? '...' : '${_bantuanAktifCount ?? 0}')
                                        : '2',
                                    icon: Icons.volunteer_activism_rounded,
                                    color: const Color(0xFF4CAF50),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildStatCard(
                                    title: 'Pengaduan',
                                    value: _currentUser?.role == 'admin'
                                        ? (_pengaduanLoading ? '...' : '${_pengaduanCount ?? 0}')
                                        : '1',
                                    icon: Icons.report_problem_rounded,
                                    color: const Color(0xFFFF9800),
                                  ),
                                ),
                                if (_currentUser?.role == 'relawan' || _currentUser?.role == 'user') ...[
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildStatCard(
                                      title: 'Warga',
                                      value: _wargaCountLoading ? '...' : '${_wargaCount ?? 0}',
                                      icon: Icons.groups_rounded,
                                      color: const Color(0xFF009688),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Profile Completion Reminder - only show if profile is not complete and user is not admin
                            if (!_profileCompletionLoading && _profileCompletion != null && !_profileCompletion!['is_complete'] && _currentUser?.role != 'admin')
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
                            
                            // Horizontal scrollable row of services
                            SizedBox(
                              height: 100,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                children: [
                                  // Admin features (only for admin)
                                  if (_currentUser?.role == 'admin') ...[
                                    _buildCompactServiceCard(
                                      icon: Icons.groups_2_rounded,
                                      title: 'Warga Binaan',
                                      color: const Color(0xFF009688),
                                      onTap: () => _navigateToScreen(const RelawanWargaScreen()),
                                    ),
                                    const SizedBox(width: 16),
                                  ],
                                  // Aleg dashboard (only for aleg/admin_aleg)
                                  if (_currentUser?.role == 'aleg' || _currentUser?.role == 'admin_aleg') ...[
                                    _buildCompactServiceCard(
                                      icon: Icons.dashboard_customize_rounded,
                                      title: 'Dashboard Aleg',
                                      color: const Color(0xFF795548),
                                      onTap: () => _navigateToScreen(const AlegDashboardScreen()),
                                    ),
                                    const SizedBox(width: 16),
                                  ],
                                  // Relawan warga (only for relawan/user)
                                  if (_currentUser?.role == 'relawan' || _currentUser?.role == 'user') ...[
                                    _buildCompactServiceCard(
                                      icon: Icons.groups_2_rounded,
                                      title: 'Warga Binaan',
                                      color: const Color(0xFF009688),
                                      onTap: () => _navigateToScreen(const RelawanWargaScreen()),
                                    ),
                                    const SizedBox(width: 16),
                                  ],
                                  _buildCompactServiceCard(
                                    icon: Icons.volunteer_activism_rounded,
                                    title: 'Bantuan Sosial',
                                    color: (_isProfileComplete() || _currentUser?.role == 'admin') ? const Color(0xFFff5001) : Colors.grey,
                                    onTap: (_isProfileComplete() || _currentUser?.role == 'admin') ? () => _navigateToScreen(const BantuanSosialScreen()) : _showProfileIncompleteDialog,
                                  ),
                                  const SizedBox(width: 16),
                                  _buildCompactServiceCard(
                                    icon: Icons.article_rounded,
                                    title: 'Berita Terbaru',
                                    color: const Color(0xFF2196F3),
                                    onTap: () => _navigateToScreen(const NewsScreen()),
                                  ),
                                  const SizedBox(width: 16),
                                  _buildCompactServiceCard(
                                    icon: Icons.report_problem_rounded,
                                    title: 'Buat Pengaduan',
                                    color: const Color(0xFFFF9800),
                                    onTap: () => _navigateToScreen(const ComplaintScreen()),
                                  ),
                                  const SizedBox(width: 16),
                                  _buildCompactServiceCard(
                                    icon: Icons.event_note_rounded,
                                    title: 'Reses',
                                    color: const Color(0xFF00BCD4),
                                    onTap: () => _navigateToScreen(const ResesScreen()),
                                  ),
                                  const SizedBox(width: 16),
                                  _buildCompactServiceCard(
                                    icon: Icons.lightbulb_outline_rounded,
                                    title: 'Pokir',
                                    color: const Color(0xFF673AB7),
                                    onTap: () => _navigateToScreen(const PokirScreen()),
                                  ),
                                  const SizedBox(width: 16),
                                  _buildCompactServiceCard(
                                    icon: Icons.settings_rounded,
                                    title: 'Pengaturan',
                                    color: const Color(0xFF9C27B0),
                                    onTap: () => _navigateToTab(4), // Navigate to Settings tab
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Legislative Member Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Anggota Legislatif',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D3748),
                                  ),
                                ),
                                if (_currentUser?.role == 'admin' && _allLegislativeMembers.isNotEmpty)
                                  Text(
                                    '${_currentLegislativeIndex + 1} / ${_allLegislativeMembers.length}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Legislative Member Card - Separate container for admin
                            if (_currentUser?.role == 'admin') ...[
                              // Fixed height container for swipeable cards
                              SizedBox(
                                height: 280,
                                child: _buildAdminSwipeableCard(),
                              ),
                            ] else ...[
                              // Non-admin legislative member display
                              _legislativeLoading
                                  ? const LegislativeMemberCardSkeleton()
                                  : _userLegislativeMember == null
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
                                                Icons.account_balance_outlined,
                                                size: 48,
                                                color: Colors.grey[400],
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                'Belum ada anggota legislatif yang dipilih',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              TextButton(
                                                onPressed: _loadUserLegislativeMember,
                                                child: const Text('Coba Lagi'),
                                              ),
                                            ],
                                          ),
                                        )
                                      : LegislativeMemberCard(
                                          member: _userLegislativeMember!,
                                          onTap: () => _navigateToLegislativeMemberDetail(_userLegislativeMember!.id),
                                        ),
                            ],
                            
                            const SizedBox(height: 32),

                            // Recent News Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Berita Terbaru',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2D3748),
                                      ),
                                    ),
                                    if (_currentUser?.role == 'admin') ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFff5001).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: const Color(0xFFff5001).withValues(alpha: 0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          'Semua Aleg',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: const Color(0xFFff5001),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                TextButton(
                                  onPressed: () => _navigateToScreen(const NewsScreen()),
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFFff5001),
                                  ),
                                  child: Text(
                                    _currentUser?.role == 'admin' ? 'Kelola Berita' : 'Lihat Semua',
                                  ),
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

  Widget _buildAdminSwipeableCard() {
    if (_allLegislativeLoading) {
      return const LegislativeMemberCardSkeleton();
    }

    if (_allLegislativeMembers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(
              Icons.account_balance_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'Tidak ada data anggota legislatif',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadAllLegislativeMembers,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    final currentMember = _allLegislativeMembers[_currentLegislativeIndex];

    return Column(
      children: [
        // Swipeable card with flexible height
        Expanded(
          child: Dismissible(
            key: Key('legislative_${currentMember.id}'),
            direction: DismissDirection.horizontal,
            onDismissed: (direction) {
              if (direction == DismissDirection.endToStart) {
                // Swipe left - next member
                _nextLegislativeMember();
              } else if (direction == DismissDirection.startToEnd) {
                // Swipe right - previous member
                _previousLegislativeMember();
              }
            },
            child: LegislativeMemberCard(
              member: currentMember,
              onTap: () => _navigateToLegislativeMemberDetail(currentMember.id),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Navigation hints
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.swipe,
              size: 14,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              'Swipe kiri/kanan untuk ganti anggota',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),

        // Dot indicators
        if (_allLegislativeMembers.length > 1) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _allLegislativeMembers.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: 5,
                width: _currentLegislativeIndex == index ? 16 : 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: _currentLegislativeIndex == index
                      ? const Color(0xFFff5001)
                      : Colors.grey[300],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _nextLegislativeMember() {
    if (_allLegislativeMembers.isNotEmpty) {
      setState(() {
        _currentLegislativeIndex = (_currentLegislativeIndex + 1) % _allLegislativeMembers.length;
      });
    }
  }

  void _previousLegislativeMember() {
    if (_allLegislativeMembers.isNotEmpty) {
      setState(() {
        _currentLegislativeIndex = (_currentLegislativeIndex - 1 + _allLegislativeMembers.length) % _allLegislativeMembers.length;
      });
    }
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: color,
                size: 22,
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactServiceCard({
    required IconData icon,
    required String title,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 80,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2D3748),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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
          color: Colors.grey.withValues(alpha: 0.2),
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
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFff5001)),
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
                              color: Color(NewsService.getCategoryColor(category)).withValues(alpha: 0.1),
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
          color: Colors.grey.withValues(alpha: 0.2),
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

  void _navigateToLegislativeMemberDetail(int memberId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LegislativeMemberDetailScreen(memberId: memberId),
      ),
    );
  }

  bool _isProfileComplete() {
    return _profileCompletion != null && _profileCompletion!['is_complete'] == true;
  }

  void _showProfileIncompleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_outlined,
                color: Colors.orange[600],
                size: 28,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Lengkapi Data Diri Anda',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Untuk mengakses fitur Bantuan Sosial, Anda perlu melengkapi data profil terlebih dahulu.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Data yang diperlukan: Profil Personal, Data Keluarga, Data Ekonomi, dan Data Sosial',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Nanti',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to profile page
                _navigateToTab(3); // Assuming profile tab is at index 3
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFff5001),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Lengkapi Data',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
