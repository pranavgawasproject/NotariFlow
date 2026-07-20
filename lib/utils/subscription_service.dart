import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

/// Subscription service for managing premium features and limits
class SubscriptionService {
  static const int freeInvoiceLimit = 10;
  static const int freeMileageLimit = 20;
  static const int freeExpenseLimit = 30;
  static const int freeClientLimit = 15;
  static const int freeSignatureLimit = 15;

  // LemonSqueezy checkout URLs
  static const String monthlyCheckoutUrl = 
      'https://notariflow.lemonsqueezy.com/buy/74996c57-0a9e-4890-b424-86bd3aac606d';
  static const String yearlyCheckoutUrl = 
      'https://notariflow.lemonsqueezy.com/buy/101bec89-b835-4862-a493-526855bde384';

  // Developer emails that get automatic premium access (for testing)
  static const List<String> _developerEmails = [
    'pranavgawas@gmail.com',
    'pranavgawas.project@gmail.com',
    // Add more developer emails here as needed
  ];

  /// Check if current user is a developer (gets free premium)
  bool _isDeveloper() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    return _developerEmails.contains(user.email?.toLowerCase());
  }

  /// Check if user has premium subscription
  Future<bool> isPremium() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      // Developer bypass - always return premium for developer accounts
      if (_isDeveloper()) {
        debugPrint('🔑 Developer account detected: ${user.email} - Premium enabled');
        return true;
      }

      final doc = await FirebaseFirestore.instance
          .collection('artifacts/notaryflow-v2/users/${user.uid}/subscription')
          .doc('status')
          .get();

      if (!doc.exists) return false;

      final data = doc.data();
      if (data == null) return false;

      final isPremium = data['isPremium'] as bool? ?? false;
      final expiryDate = data['expiryDate'] as Timestamp?;

      if (expiryDate != null) {
        return isPremium && expiryDate.toDate().isAfter(DateTime.now());
      }

      return isPremium;
    } catch (e) {
      debugPrint('Error checking premium status: $e');
      return false;
    }
  }

  /// Check mileage limit for free users
  Future<Map<String, dynamic>> checkMileageLimit() async {
    final premium = await isPremium();
    if (premium) {
      return {'allowed': true, 'canAdd': true, 'isPremium': true, 'count': 0, 'limit': -1, 'message': ''};
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return {'allowed': false, 'canAdd': false, 'isPremium': false, 'count': 0, 'limit': freeMileageLimit, 'message': 'User not authenticated'};
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('artifacts/notaryflow-v2/users/${user.uid}/mileage')
          .count()
          .get();

      final count = snapshot.count ?? 0;
      final allowed = count < freeMileageLimit;
      return {
        'allowed': allowed,
        'canAdd': allowed,
        'isPremium': false,
        'count': count,
        'limit': freeMileageLimit,
        'message': allowed ? '' : 'Free plan limit of $freeMileageLimit mileage entries reached. Upgrade for unlimited logs.',
      };
    } catch (e) {
      debugPrint('Error checking mileage limit: $e');
      return {'allowed': true, 'canAdd': true, 'isPremium': false, 'count': 0, 'limit': freeMileageLimit, 'message': ''};
    }
  }

  /// Check invoice limit for free users
  Future<Map<String, dynamic>> checkInvoiceLimit() async {
    final premium = await isPremium();
    if (premium) {
      return {'allowed': true, 'canAdd': true, 'isPremium': true, 'count': 0, 'limit': -1, 'message': ''};
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return {'allowed': false, 'canAdd': false, 'isPremium': false, 'count': 0, 'limit': freeInvoiceLimit, 'message': 'User not authenticated'};
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('artifacts/notaryflow-v2/users/${user.uid}/invoices')
          .count()
          .get();

      final count = snapshot.count ?? 0;
      final allowed = count < freeInvoiceLimit;
      return {
        'allowed': allowed,
        'canAdd': allowed,
        'isPremium': false,
        'count': count,
        'limit': freeInvoiceLimit,
        'message': allowed ? '' : 'Free plan limit of $freeInvoiceLimit invoices reached. Upgrade for unlimited invoices.',
      };
    } catch (e) {
      debugPrint('Error checking invoice limit: $e');
      return {'allowed': true, 'canAdd': true, 'isPremium': false, 'count': 0, 'limit': freeInvoiceLimit, 'message': ''};
    }
  }

  /// Check expense limit for free users
  Future<Map<String, dynamic>> checkExpenseLimit() async {
    final premium = await isPremium();
    if (premium) {
      return {'allowed': true, 'canAdd': true, 'isPremium': true, 'count': 0, 'limit': -1, 'message': ''};
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return {'allowed': false, 'canAdd': false, 'isPremium': false, 'count': 0, 'limit': freeExpenseLimit, 'message': 'User not authenticated'};
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('artifacts/notaryflow-v2/users/${user.uid}/expenses')
          .count()
          .get();

      final count = snapshot.count ?? 0;
      final allowed = count < freeExpenseLimit;
      return {
        'allowed': allowed,
        'canAdd': allowed,
        'isPremium': false,
        'count': count,
        'limit': freeExpenseLimit,
        'message': allowed ? '' : 'Free plan limit of $freeExpenseLimit expenses reached. Upgrade for unlimited expenses.',
      };
    } catch (e) {
      debugPrint('Error checking expense limit: $e');
      return {'allowed': true, 'canAdd': true, 'isPremium': false, 'count': 0, 'limit': freeExpenseLimit, 'message': ''};
    }
  }

  /// Check client limit for free users
  Future<Map<String, dynamic>> checkClientLimit() async {
    final premium = await isPremium();
    if (premium) {
      return {'allowed': true, 'canAdd': true, 'isPremium': true, 'count': 0, 'limit': -1, 'message': ''};
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return {'allowed': false, 'canAdd': false, 'isPremium': false, 'count': 0, 'limit': freeClientLimit, 'message': 'User not authenticated'};
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('artifacts/notaryflow-v2/users/${user.uid}/clients')
          .count()
          .get();

      final count = snapshot.count ?? 0;
      final allowed = count < freeClientLimit;
      return {
        'allowed': allowed,
        'canAdd': allowed,
        'isPremium': false,
        'count': count,
        'limit': freeClientLimit,
        'message': allowed ? '' : 'Free plan limit of $freeClientLimit clients reached. Upgrade for unlimited clients.',
      };
    } catch (e) {
      debugPrint('Error checking client limit: $e');
      return {'allowed': true, 'canAdd': true, 'isPremium': false, 'count': 0, 'limit': freeClientLimit, 'message': ''};
    }
  }

  /// Check signature log limit for free users
  Future<Map<String, dynamic>> checkSignatureLimit() async {
    final premium = await isPremium();
    if (premium) {
      return {'allowed': true, 'canAdd': true, 'isPremium': true, 'count': 0, 'limit': -1, 'message': ''};
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return {'allowed': false, 'canAdd': false, 'isPremium': false, 'count': 0, 'limit': freeSignatureLimit, 'message': 'User not authenticated'};
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('artifacts/notaryflow-v2/users/${user.uid}/signatures')
          .count()
          .get();

      final count = snapshot.count ?? 0;
      final allowed = count < freeSignatureLimit;
      return {
        'allowed': allowed,
        'canAdd': allowed,
        'isPremium': false,
        'count': count,
        'limit': freeSignatureLimit,
        'message': allowed ? '' : 'Free plan limit of $freeSignatureLimit digital signatures reached. Upgrade for unlimited signatures.',
      };
    } catch (e) {
      debugPrint('Error checking signature limit: $e');
      return {'allowed': true, 'canAdd': true, 'isPremium': false, 'count': 0, 'limit': freeSignatureLimit, 'message': ''};
    }
  }


  /// Show premium upgrade dialog
  static void showPremiumDialog(BuildContext context, String feature) {
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.star, color: Colors.amber.shade600),
            const SizedBox(width: 8),
            const Text('Upgrade to Premium'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unlock $feature and more!',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildFeatureItem('Unlimited invoices, expenses & mileage'),
            _buildFeatureItem('Advanced analytics & reports'),
            _buildFeatureItem('CSV export functionality'),
            _buildFeatureItem('Priority support'),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Choose your plan:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              _launchCheckout(monthlyCheckoutUrl, userEmail);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.amber.shade700,
              side: BorderSide(color: Colors.amber.shade600),
            ),
            child: const Text('Monthly'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _launchCheckout(yearlyCheckoutUrl, userEmail);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yearly (Save 20%)'),
          ),
        ],
      ),
    );
  }

  /// Launch LemonSqueezy checkout with user email prefilled
  static Future<void> _launchCheckout(String baseUrl, String email) async {
    // Add email as checkout prefill parameter
    final checkoutUrl = email.isNotEmpty 
        ? '$baseUrl?checkout[email]=$email'
        : baseUrl;
    
    final uri = Uri.parse(checkoutUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Open subscription management / upgrade page
  static void showUpgradePage(BuildContext context) {
    showPremiumDialog(context, 'all premium features');
  }

  static Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
