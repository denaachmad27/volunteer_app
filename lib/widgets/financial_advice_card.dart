import 'package:flutter/material.dart';

class FinancialAdviceCard extends StatelessWidget {
  final List<String> adviceList;

  const FinancialAdviceCard({
    Key? key,
    required this.adviceList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (adviceList.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFEF3C7), // Light yellow
            Color(0xFFFEF9E7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: Color(0xFFF59E0B),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saran Keuangan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD97706),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Rekomendasi untuk meningkatkan kondisi finansial',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Advice list
          ...adviceList.asMap().entries.map((entry) {
            final index = entry.key;
            final advice = entry.value;
            
            return Padding(
              padding: EdgeInsets.only(bottom: index < adviceList.length - 1 ? 12 : 0),
              child: _buildAdviceItem(advice, index + 1),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAdviceItem(String advice, int number) {
    // Extract emoji and text
    final parts = advice.split(' ');
    final emoji = parts.isNotEmpty && _isEmoji(parts[0]) ? parts[0] : '💡';
    final text = _isEmoji(parts[0]) ? parts.skip(1).join(' ') : advice;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number or emoji
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isEmoji(String text) {
    if (text.isEmpty) return false;
    
    // Common emoji patterns for financial advice
    const emojiList = ['💰', '🏦', '⚠️', '💼', '🏠', '📉', '💳', '📊', '📈'];
    return emojiList.contains(text) || text.runes.length == 1;
  }
}