import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/legislative_service.dart';

class LegislativeMemberDetailScreen extends StatefulWidget {
  final int memberId;

  const LegislativeMemberDetailScreen({
    super.key,
    required this.memberId,
  });

  @override
  State<LegislativeMemberDetailScreen> createState() => _LegislativeMemberDetailScreenState();
}

class _LegislativeMemberDetailScreenState extends State<LegislativeMemberDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  LegislativeMemberDetail? _memberDetail;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _loadMemberDetail();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadMemberDetail() async {
    try {
      final response = await LegislativeService.getLegislativeMemberDetail(widget.memberId);
      if (response.success) {
        setState(() {
          _memberDetail = response.data;
          _isLoading = false;
        });
        _animationController.forward();
      } else {
        setState(() {
          _error = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat detail anggota legislatif: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? _buildLoadingState()
          : _error.isNotEmpty
              ? _buildErrorState()
              : _buildDetailContent(),
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
            'Memuat detail anggota legislatif...',
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Terjadi Kesalahan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadMemberDetail,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFff5001),
              foregroundColor: Colors.white,
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailContent() {
    if (_memberDetail == null) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildProfileSection(),
                const SizedBox(height: 16),
                _buildContactSection(),
                const SizedBox(height: 16),
                _buildAddressSection(),
                const SizedBox(height: 16),
                _buildPoliticalInfoSection(),
                if (_memberDetail!.riwayatJabatan != null && _memberDetail!.riwayatJabatan!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildHistorySection(),
                ],
                if (_memberDetail!.volunteers != null && _memberDetail!.volunteers!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildVolunteersSection(),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFFff5001),
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
        title: Text(
          'Profil Anggota Legislatif',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFff5001),
                Color(0xFF764ba2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFff5001).withOpacity(0.1),
                      const Color(0xFFe64100).withOpacity(0.1),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFFff5001).withOpacity(0.2),
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: _memberDetail!.profilePhotoUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: _memberDetail!.profilePhotoUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: const Color(0xFFff5001).withOpacity(0.1),
                            child: const Icon(
                              Icons.person_outline,
                              color: Color(0xFFff5001),
                              size: 50,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: const Color(0xFFff5001).withOpacity(0.1),
                            child: const Icon(
                              Icons.person_outline,
                              color: Color(0xFFff5001),
                              size: 50,
                            ),
                          ),
                        )
                      : Container(
                          color: const Color(0xFFff5001).withOpacity(0.1),
                          child: const Icon(
                            Icons.person_outline,
                            color: Color(0xFFff5001),
                            size: 50,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(width: 20),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _memberDetail!.namaLengkap,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _memberDetail!.jabatanSaatIni,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _memberDetail!.status == 'Aktif'
                            ? const Color(0xFF4CAF50).withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _memberDetail!.status == 'Aktif'
                              ? const Color(0xFF4CAF50).withOpacity(0.3)
                              : Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _memberDetail!.status == 'Aktif'
                                  ? const Color(0xFF4CAF50)
                                  : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _memberDetail!.status,
                            style: TextStyle(
                              fontSize: 14,
                              color: _memberDetail!.status == 'Aktif'
                                  ? const Color(0xFF4CAF50)
                                  : Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: _buildInfoTile(
                  icon: Icons.cake_outlined,
                  title: 'Tempat, Tanggal Lahir',
                  value: '${_memberDetail!.tempatLahir}, ${_memberDetail!.formattedBirthDate}',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildInfoTile(
                  icon: Icons.person_outline,
                  title: 'Jenis Kelamin',
                  value: _memberDetail!.jenisKelamin,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoTile(
                  icon: Icons.badge_outlined,
                  title: 'Kode Anggota',
                  value: _memberDetail!.kodeAleg,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.contact_phone_outlined,
                color: const Color(0xFFff5001),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Informasi Kontak',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildContactTile(
            icon: Icons.phone_outlined,
            title: 'Nomor Telepon',
            value: _memberDetail!.formattedPhoneNumber,
            onTap: () => _launchPhone(_memberDetail!.noTelepon),
          ),
          
          const SizedBox(height: 12),
          
          _buildContactTile(
            icon: Icons.email_outlined,
            title: 'Email',
            value: _memberDetail!.email,
            onTap: () => _launchEmail(_memberDetail!.email),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: const Color(0xFFff5001),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Alamat',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            _memberDetail!.fullAddress,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoliticalInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_outlined,
                color: const Color(0xFFff5001),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Informasi Politik',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildInfoTile(
            icon: Icons.groups_outlined,
            title: 'Partai Politik',
            value: _memberDetail!.partaiPolitik,
          ),
          
          const SizedBox(height: 12),
          
          _buildInfoTile(
            icon: Icons.map_outlined,
            title: 'Daerah Pemilihan',
            value: _memberDetail!.daerahPemilihan,
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history_outlined,
                color: const Color(0xFFff5001),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Riwayat Jabatan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            _memberDetail!.riwayatJabatan!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolunteersSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.people_outline,
                color: const Color(0xFFff5001),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Volunteer Terdaftar (${_memberDetail!.volunteers!.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _memberDetail!.volunteers!.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final volunteer = _memberDetail!.volunteers![index];
              return _buildVolunteerTile(volunteer);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVolunteerTile(Volunteer volunteer) {
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
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFff5001).withOpacity(0.1),
            ),
            child: volunteer.profilePhotoUrl != null
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: volunteer.profilePhotoUrl!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Icon(
                        Icons.person_outline,
                        color: Color(0xFFff5001),
                        size: 25,
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person_outline,
                        color: Color(0xFFff5001),
                        size: 25,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.person_outline,
                    color: Color(0xFFff5001),
                    size: 25,
                  ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  volunteer.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  volunteer.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.grey[600],
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2D3748),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFFff5001),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFFff5001),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.launch,
                color: Colors.grey[400],
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}