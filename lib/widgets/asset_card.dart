import 'package:flutter/material.dart';
import '../services/economic_service.dart';

class AssetCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<AssetItem> items;

  const AssetCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120, // Fixed height to prevent overflow
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
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
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 14,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 6),
          
          // Asset items
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 1),
                  child: _buildAssetItem(item),
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetItem(AssetItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: item.isPositive ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (item.subtitle != null) ...[
                Text(
                  item.subtitle!,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey.shade600,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (item.value != null) ...[
                Text(
                  item.value!,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: item.isPositive ? Colors.green : Colors.red,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class AssetItem {
  final String label;
  final String? subtitle;
  final String? value;
  final bool isPositive;

  AssetItem({
    required this.label,
    this.subtitle,
    this.value,
    this.isPositive = true,
  });
}

// Factory methods for common asset types
class AssetCards {
  static AssetCard buildPropertyCard(Map<String, dynamic> economicData) {
    final statusRumah = economicData['status_rumah'] ?? 'Tidak diketahui';
    final jenisRumah = economicData['jenis_rumah'] ?? 'Tidak diketahui';
    
    return AssetCard(
      title: 'Properti & Tempat Tinggal',
      icon: Icons.home,
      color: const Color(0xFF3B82F6),
      items: [
        AssetItem(
          label: 'Status Kepemilikan',
          subtitle: statusRumah,
          isPositive: statusRumah == 'Milik Sendiri',
        ),
        AssetItem(
          label: 'Jenis Rumah',
          subtitle: jenisRumah,
        ),
      ],
    );
  }
  
  static AssetCard buildVehicleCard(Map<String, dynamic> economicData) {
    final punyaKendaraan = economicData['punya_kendaraan'] ?? false;
    final jenisKendaraan = economicData['jenis_kendaraan'];
    
    return AssetCard(
      title: 'Kendaraan',
      icon: Icons.directions_car,
      color: const Color(0xFF10B981),
      items: [
        AssetItem(
          label: punyaKendaraan ? 'Memiliki Kendaraan' : 'Tidak Memiliki Kendaraan',
          subtitle: punyaKendaraan && jenisKendaraan != null ? jenisKendaraan : null,
          isPositive: punyaKendaraan,
        ),
      ],
    );
  }
  
  static AssetCard buildSavingsCard(Map<String, dynamic> economicData) {
    final punyaTabungan = economicData['punya_tabungan'] ?? false;
    final jumlahTabungan = economicData['jumlah_tabungan'];
    
    return AssetCard(
      title: 'Tabungan',
      icon: Icons.savings,
      color: const Color(0xFF059669),
      items: [
        AssetItem(
          label: punyaTabungan ? 'Memiliki Tabungan' : 'Belum Memiliki Tabungan',
          value: punyaTabungan && jumlahTabungan != null 
            ? EconomicService.formatCurrency(double.tryParse(jumlahTabungan.toString()) ?? 0.0)
            : null,
          isPositive: punyaTabungan,
        ),
      ],
    );
  }
  
  static AssetCard buildDebtCard(Map<String, dynamic> economicData) {
    final punyaHutang = economicData['punya_hutang'] ?? false;
    final jumlahHutang = economicData['jumlah_hutang'];
    
    return AssetCard(
      title: 'Hutang',
      icon: Icons.money_off,
      color: const Color(0xFFEF4444),
      items: [
        AssetItem(
          label: punyaHutang ? 'Memiliki Hutang' : 'Tidak Memiliki Hutang',
          value: punyaHutang && jumlahHutang != null 
            ? EconomicService.formatCurrency(double.tryParse(jumlahHutang.toString()) ?? 0.0)
            : null,
          isPositive: !punyaHutang,
        ),
      ],
    );
  }
}