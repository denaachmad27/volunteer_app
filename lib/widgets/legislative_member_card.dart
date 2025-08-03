import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/legislative_service.dart';

class LegislativeMemberCard extends StatelessWidget {
  final LegislativeMember member;
  final VoidCallback? onTap;

  const LegislativeMemberCard({
    super.key,
    required this.member,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    // Profile Photo
                    Container(
                      width: 80,
                      height: 80,
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
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: member.profilePhotoUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: member.profilePhotoUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: const Color(0xFFff5001).withOpacity(0.1),
                                  child: const Icon(
                                    Icons.person_outline,
                                    color: Color(0xFFff5001),
                                    size: 40,
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: const Color(0xFFff5001).withOpacity(0.1),
                                  child: const Icon(
                                    Icons.person_outline,
                                    color: Color(0xFFff5001),
                                    size: 40,
                                  ),
                                ),
                              )
                            : Container(
                                color: const Color(0xFFff5001).withOpacity(0.1),
                                child: const Icon(
                                  Icons.person_outline,
                                  color: Color(0xFFff5001),
                                  size: 40,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.namaLengkap,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            member.jabatanSaatIni,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
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
                              color: const Color(0xFF4CAF50).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF4CAF50).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF4CAF50),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Aktif',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: const Color(0xFF4CAF50).withOpacity(0.8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Arrow icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFff5001).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFFff5001),
                        size: 16,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Info row
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.grey[600],
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ketuk untuk melihat profil lengkap dan informasi kontak',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
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
}

class LegislativeMemberCardWithPhoto extends StatelessWidget {
  final LegislativeMemberDetail member;
  final VoidCallback? onTap;

  const LegislativeMemberCardWithPhoto({
    super.key,
    required this.member,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    // Profile Photo with network image
                    Container(
                      width: 80,
                      height: 80,
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
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: member.profilePhotoUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: member.profilePhotoUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: const Color(0xFFff5001).withOpacity(0.1),
                                  child: const Icon(
                                    Icons.person_outline,
                                    color: Color(0xFFff5001),
                                    size: 40,
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: const Color(0xFFff5001).withOpacity(0.1),
                                  child: const Icon(
                                    Icons.person_outline,
                                    color: Color(0xFFff5001),
                                    size: 40,
                                  ),
                                ),
                              )
                            : Container(
                                color: const Color(0xFFff5001).withOpacity(0.1),
                                child: const Icon(
                                  Icons.person_outline,
                                  color: Color(0xFFff5001),
                                  size: 40,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.namaLengkap,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            member.jabatanSaatIni,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            member.partaiPolitik,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: member.status == 'Aktif'
                                  ? const Color(0xFF4CAF50).withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: member.status == 'Aktif'
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
                                    color: member.status == 'Aktif'
                                        ? const Color(0xFF4CAF50)
                                        : Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  member.status,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: member.status == 'Aktif'
                                        ? const Color(0xFF4CAF50).withOpacity(0.8)
                                        : Colors.grey.withOpacity(0.8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Arrow icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFff5001).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFFff5001),
                        size: 16,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Additional info row with volunteer count
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        color: Colors.grey[600],
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${member.volunteerCount} Volunteer terdaftar',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Ketuk untuk detail',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
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
}

class LegislativeMemberCardSkeleton extends StatelessWidget {
  const LegislativeMemberCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                // Profile Photo Skeleton
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity * 0.7,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 80,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
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
}