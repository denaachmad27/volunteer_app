import 'package:flutter/material.dart';
import '../services/family_service.dart';

class FamilyMemberCard extends StatelessWidget {
  final Map<String, dynamic> familyMember;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const FamilyMemberCard({
    super.key,
    required this.familyMember,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final hubungan = familyMember['hubungan'] ?? '';
    final relationshipColor = FamilyService.getRelationshipColor(hubungan);
    final relationshipIcon = FamilyService.getRelationshipIcon(hubungan);
    final age = FamilyService.calculateAge(familyMember['tanggal_lahir'] ?? '');
    final penghasilan = FamilyService.formatCurrency(
      double.tryParse(familyMember['penghasilan']?.toString() ?? '0') ?? 0,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: relationshipColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with name and relationship
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: relationshipColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  relationshipIcon,
                  color: relationshipColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      familyMember['nama_anggota'] ?? 'Nama tidak diketahui',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: relationshipColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        hubungan,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: relationshipColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (showActions) ...[
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit' && onEdit != null) {
                      onEdit!();
                    } else if (value == 'delete' && onDelete != null) {
                      onDelete!();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18, color: Color(0xFFff5001)),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Hapus'),
                        ],
                      ),
                    ),
                  ],
                  child: const Icon(
                    Icons.more_vert,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Member details
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  icon: Icons.person_outline,
                  label: 'Gender',
                  value: familyMember['jenis_kelamin'] ?? '-',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDetailItem(
                  icon: Icons.cake,
                  label: 'Usia',
                  value: age > 0 ? '$age tahun' : '-',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  icon: Icons.work_outline,
                  label: 'Pekerjaan',
                  value: familyMember['pekerjaan'] ?? '-',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDetailItem(
                  icon: Icons.school_outlined,
                  label: 'Pendidikan',
                  value: familyMember['pendidikan'] ?? '-',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  icon: Icons.attach_money,
                  label: 'Penghasilan',
                  value: penghasilan,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDetailItem(
                  icon: Icons.family_restroom,
                  label: 'Tanggungan',
                  value: (familyMember['tanggungan'] == true || familyMember['tanggungan'] == 1) ? 'Ya' : 'Tidak',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: const Color(0xFF6B7280),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}