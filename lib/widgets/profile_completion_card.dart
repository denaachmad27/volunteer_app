import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileCompletionCard extends StatelessWidget {
  final int percentage;
  final int completedSections;
  final int totalSections;
  final String nextStep;
  final String nextRoute;
  final bool isComplete;
  final String message;
  final VoidCallback? onRefresh;

  const ProfileCompletionCard({
    Key? key,
    required this.percentage,
    required this.completedSections,
    required this.totalSections,
    required this.nextStep,
    required this.nextRoute,
    required this.isComplete,
    required this.message,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = _getCompletionColors(percentage);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors['background']!,
            colors['background']!.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors['primary']!.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors['primary']!.withOpacity(0.1),
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
                  color: colors['primary']!.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isComplete ? Icons.check_circle : Icons.assignment_ind,
                  color: colors['primary'],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isComplete ? 'Profil Lengkap' : 'Lengkapi Profil',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colors['text'],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completedSections dari $totalSections bagian selesai',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors['text']!.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (onRefresh != null)
                IconButton(
                  onPressed: onRefresh,
                  icon: Icon(
                    Icons.refresh,
                    color: colors['primary'],
                    size: 20,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colors['text'],
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors['primary'],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: colors['primary']!.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  widthFactor: percentage / 100,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colors['primary']!, colors['secondary']!],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Message
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: colors['text']!.withOpacity(0.8),
              height: 1.4,
            ),
          ),
          
          if (!isComplete) ...[
            const SizedBox(height: 20),
            
            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push(nextRoute),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors['primary'],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_forward,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Lanjutkan: $nextStep',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Map<String, Color> _getCompletionColors(int percentage) {
    if (percentage >= 100) {
      return {
        'primary': const Color(0xFF10B981), // Green
        'secondary': const Color(0xFF059669),
        'background': const Color(0xFFECFDF5),
        'text': const Color(0xFF065F46),
      };
    } else if (percentage >= 75) {
      return {
        'primary': const Color(0xFF3B82F6), // Blue
        'secondary': const Color(0xFF2563EB),
        'background': const Color(0xFFEFF6FF),
        'text': const Color(0xFF1E40AF),
      };
    } else if (percentage >= 50) {
      return {
        'primary': const Color(0xFFF59E0B), // Yellow
        'secondary': const Color(0xFFD97706),
        'background': const Color(0xFFFEF3C7),
        'text': const Color(0xFF92400E),
      };
    } else {
      return {
        'primary': const Color(0xFFEF4444), // Red
        'secondary': const Color(0xFFDC2626),
        'background': const Color(0xFFFEF2F2),
        'text': const Color(0xFF991B1B),
      };
    }
  }
}