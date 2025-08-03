import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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

    _animationController.forward();
  }

  @override
  void dispose() {
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
                          color: Colors.white.withOpacity(0.2),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.notifications_rounded,
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
                              'Notifikasi',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Update terbaru untuk Anda',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Mark all as read button
                      TextButton(
                        onPressed: () => _markAllAsRead(),
                        child: const Text(
                          'Tandai Dibaca',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
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
                    child: _buildNotificationsList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    // Mock notification data
    final notifications = [
      {
        'id': 1,
        'type': 'bantuan_approved',
        'title': 'Bantuan Sosial Disetujui',
        'message': 'Pengajuan bantuan pendidikan Anda telah disetujui. Silakan kunjungi kantor untuk proses pencairan.',
        'time': '2 jam yang lalu',
        'isRead': false,
        'icon': Icons.check_circle_rounded,
        'color': const Color(0xFF4CAF50),
      },
      {
        'id': 2,
        'type': 'complaint_responded',
        'title': 'Pengaduan Ditanggapi',
        'message': 'Pengaduan lampu jalan mati di Jl. Merdeka telah ditanggapi oleh admin.',
        'time': '5 jam yang lalu',
        'isRead': false,
        'icon': Icons.reply_rounded,
        'color': const Color(0xFF2196F3),
      },
      {
        'id': 3,
        'type': 'news_published',
        'title': 'Berita Baru',
        'message': 'Program pelatihan keterampilan gratis telah dibuka. Daftar sekarang!',
        'time': '1 hari yang lalu',
        'isRead': true,
        'icon': Icons.article_rounded,
        'color': const Color(0xFFFF9800),
      },
      {
        'id': 4,
        'type': 'complaint_completed',
        'title': 'Pengaduan Selesai',
        'message': 'Drainase tersumbat di Jl. Sudirman telah selesai diperbaiki. Berikan rating Anda.',
        'time': '2 hari yang lalu',
        'isRead': true,
        'icon': Icons.task_alt_rounded,
        'color': const Color(0xFF4CAF50),
      },
      {
        'id': 5,
        'type': 'bantuan_rejected',
        'title': 'Bantuan Sosial Ditolak',
        'message': 'Pengajuan bantuan modal usaha ditolak karena berkas tidak lengkap. Silakan ajukan kembali.',
        'time': '3 hari yang lalu',
        'isRead': true,
        'icon': Icons.cancel_rounded,
        'color': const Color(0xFFF44336),
      },
      {
        'id': 6,
        'type': 'system_update',
        'title': 'Update Aplikasi',
        'message': 'Fitur baru telah tersedia! Update aplikasi untuk pengalaman yang lebih baik.',
        'time': '1 minggu yang lalu',
        'isRead': true,
        'icon': Icons.system_update_rounded,
        'color': const Color(0xFF9C27B0),
      },
    ];

    final unreadCount = notifications.where((n) => !(n['isRead'] as bool)).length;

    return Column(
      children: [
        // Summary Header
        if (unreadCount > 0)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFff5001).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFff5001).withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFff5001).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: Color(0xFFff5001),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$unreadCount Notifikasi Baru',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFff5001),
                        ),
                      ),
                      const Text(
                        'Anda memiliki update penting',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFff5001),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        
        // Notifications List
        Expanded(
          child: notifications.isEmpty 
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return _buildNotificationCard(notification, index);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    final isRead = notification['isRead'] as bool;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xFFff5001).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isRead ? Colors.grey[200]! : const Color(0xFFff5001).withOpacity(0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _markAsRead(notification['id']),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: (notification['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    notification['icon'] as IconData,
                    color: notification['color'] as Color,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification['title'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                                color: const Color(0xFF2D3748),
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFff5001),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Message
                      Text(
                        notification['message'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Time
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            notification['time'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum Ada Notifikasi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notifikasi akan muncul di sini ketika ada update',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _markAsRead(int notificationId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notifikasi #$notificationId ditandai sebagai dibaca'),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _markAllAsRead() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Tandai Semua Dibaca',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menandai semua notifikasi sebagai sudah dibaca?',
          style: TextStyle(
            color: Color(0xFF4A5568),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: Color(0xFFff5001),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Semua notifikasi ditandai sebagai dibaca'),
                  backgroundColor: Color(0xFF4CAF50),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFff5001),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Ya, Tandai Semua',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}