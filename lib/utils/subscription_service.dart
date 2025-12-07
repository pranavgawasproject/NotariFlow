import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Subscription service for managing premium features and limits
class SubscriptionService {
  static const int freeInvoiceLimit = 10;
  static const int freeMileageLimit = 20;
  static const int freeExpenseLimit = 30;
  static const int freeClientLimit = 15;

  // Developer emails that get automatic premium access (for testing)
  static const List<String> _developerEmails = [
    'pranavgawas@gmail.com',
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
      return {'allowed': true, 'isPremium': true, 'count': 0, 'limit': -1};
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return {'allowed': false, 'isPremium': false, 'count': 0, 'limit': freeMileageLimit};
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('artifacts/notaryflow-v2/users/${user.uid}/mileage')
          .count()
          .get();

      final count = snapshot.count ?? 0;
      return {
        'allowed': count < freeMileageLimit,
        'isPremium': false,
        'count': count,
        'limit': freeMileageLimit,
      };
    } catch (e) {
      debugPrint('Error checking mileage limit: $e');
      return {'allowed': true, 'isPremium': false, 'count': 0, 'limit': freeMileageLimit};
    }
  }

  /// Check invoice limit for free users
  Future<Map<String, dynamic>> checkInvoiceLimit() async {
    final premium = await isPremium();
    if (premium) {
      return {'allowed': true, 'isPremium': true, 'count': 0, 'limit': -1};
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return {'allowed': false, 'isPremium': false, 'count': 0, 'limit': freeInvoiceLimit};
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('artifacts/notaryflow-v2/users/${user.uid}/invoices')
          .count()
          .get();

      final count = snapshot.count ?? 0;
      return {
        'allowed': count < freeInvoiceLimit,
        'isPremium': false,
        'count': count,
        'limit': freeInvoiceLimit,
      };
    } catch (e) {
      debugPrint('Error checking invoice limit: $e');
      return {'allowed': true, 'isPremium': false, 'count': 0, 'limit': freeInvoiceLimit};
    }
  }

  /// Check expense limit for free users
  Future<Map<String, dynamic>> checkExpenseLimit() async {
    final premium = await isPremium();
    if (premium) {
      return {'allowed': true, 'isPremium': true, 'count': 0, 'limit': -1};
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return {'allowed': false, 'isPremium': false, 'count': 0, 'limit': freeExpenseLimit};
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('artifacts/notaryflow-v2/users/${user.uid}/expenses')
          .count()
          .get();

      final count = snapshot.count ?? 0;
      return {
        'allowed': count < freeExpenseLimit,
        'isPremium': false,
        'count': count,
        'limit': freeExpenseLimit,
      };
    } catch (e) {
      debugPrint('Error checking expense limit: $e');
      return {'allowed': true, 'isPremium': false, 'count': 0, 'limit': freeExpenseLimit};
    }
  }

  /// Check client limit for free users
  Future<Map<String, dynamic>> checkClientLimit() async {
    final premium = await isPremium();
    if (premium) {
      return {'allowed': true, 'isPremium': true, 'count': 0, 'limit': -1};
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return {'allowed': false, 'isPremium': false, 'count': 0, 'limit': freeClientLimit};
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('artifacts/notaryflow-v2/users/${user.uid}/clients')
          .count()
          .get();

      final count = snapshot.count ?? 0;
      return {
        'allowed': count < freeClientLimit,
        'isPremium': false,
        'count': count,
        'limit': freeClientLimit,
      };
    } catch (e) {
      debugPrint('Error checking client limit: $e');
      return {'allowed': true, 'isPremium': false, 'count': 0, 'limit': freeClientLimit};
    }
  }

  /// Show premium upgrade dialog
  static void showPremiumDialog(BuildContext context, String feature) {
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement upgrade flow
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
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
