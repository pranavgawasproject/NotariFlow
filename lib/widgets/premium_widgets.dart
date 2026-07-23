import 'package:flutter/material.dart';
import '../utils/subscription_service.dart';

/// Widget that locks premium features with an upgrade prompt
class PremiumFeatureLock extends StatelessWidget {
  final String featureName;
  final IconData icon;
  final String description;

  const PremiumFeatureLock({
    super.key,
    required this.featureName,
    required this.icon,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: Colors.amber.shade700,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock, color: Colors.grey.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                featureName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => SubscriptionService.showPremiumDialog(context, featureName),
            icon: const Icon(Icons.star),
            label: const Text('Upgrade to Premium'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Banner showing usage limits for free users
class PremiumBanner extends StatelessWidget {
  final String feature;
  final int currentCount;
  final int limit;

  const PremiumBanner({
    super.key,
    required this.feature,
    required this.currentCount,
    required this.limit,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = limit - currentCount;
    final isNearLimit = remaining <= 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isNearLimit ? Colors.orange.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNearLimit ? Colors.orange.shade200 : Colors.blue.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isNearLimit ? Icons.warning_rounded : Icons.info_outline,
            color: isNearLimit ? Colors.orange.shade700 : Colors.blue.shade700,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isNearLimit
                      ? 'Running low on free $feature!'
                      : 'Free Plan: $currentCount/$limit $feature used',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isNearLimit ? Colors.orange.shade900 : Colors.blue.shade900,
                  ),
                ),
                Text(
                  'Upgrade to Premium for unlimited access',
                  style: TextStyle(
                    fontSize: 12,
                    color: isNearLimit ? Colors.orange.shade700 : Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => SubscriptionService.showPremiumDialog(context, 'Unlimited $feature'),
            child: Text(
              'Upgrade',
              style: TextStyle(
                color: isNearLimit ? Colors.orange.shade700 : Colors.blue.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small badge indicating premium status
class PremiumBadge extends StatelessWidget {
  const PremiumBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade400, Colors.amber.shade600],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: Colors.white, size: 14),
          SizedBox(width: 4),
          Text(
            'PRO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
