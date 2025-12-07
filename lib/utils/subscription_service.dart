import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Free tier limits
  static const int freeInvoiceLimit = 10;
  static const int freeClientLimit = 5;
  static const int freeExpenseLimit = 20;
  static const int freeMileageLimit = 20;

  // Check if user has premium subscription
  Future<bool> isPremium() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    // --- DEVELOPER BYPASS ---
    // Add your email here to bypass premium checks during development
    final developerEmails = [
      'pranavgawas@gmail.com',
      'admin@notariflow.com',
      'test@notariflow.com',
    ];
    
    if (developerEmails.contains(user.email)) {
      return true;
    }
    // ------------------------

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return false;

      final data = doc.data();
      if (data == null) return false;

      // Check if user has active subscription
      final isPremium = data['isPremium'] ?? false;
      
      // Check subscription expiry if exists
      if (data['subscriptionExpiry'] != null) {
        final expiry = (data['subscriptionExpiry'] as Timestamp).toDate();
        if (expiry.isBefore(DateTime.now())) {
          // Subscription expired, update user status
          await _firestore.collection('users').doc(user.uid).update({
            'isPremium': false,
          });
          return false;
        }
      }

      return isPremium;
    } catch (e) {
      return false;
    }
  }

  // Get subscription plan type
  Future<String> getSubscriptionPlan() async {
    final user = _auth.currentUser;
    if (user == null) return 'free';

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return 'free';

      final data = doc.data();
      if (data == null) return 'free';

      return data['subscriptionPlan'] ?? 'free';
    } catch (e) {
      return 'free';
    }
  }

  // Activate premium subscription
  Future<void> activatePremium(String plan, {DateTime? expiryDate}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'isPremium': true,
      'subscriptionPlan': plan, // 'monthly' or 'yearly'
      'subscriptionActivatedAt': FieldValue.serverTimestamp(),
      'subscriptionExpiry': expiryDate != null ? Timestamp.fromDate(expiryDate) : null,
    }, SetOptions(merge: true));
  }

  // Check if feature is available for current user
  Future<bool> canUseFeature(String feature) async {
    final premium = await isPremium();
    
    // Premium users can use all features
    if (premium) return true;

    // Free users have access to basic features
    final freeFeatures = [
      'dashboard',
      'basic_invoices',
      'basic_mileage',
      'journal',
      'calculator',
      'settings',
    ];

    return freeFeatures.contains(feature);
  }

  // Check if user has reached limit
  Future<Map<String, dynamic>> checkLimits() async {
    final user = _auth.currentUser;
    if (user == null) {
      return {'canAdd': false, 'message': 'Please login first'};
    }

    final premium = await isPremium();
    if (premium) {
      return {'canAdd': true, 'isPremium': true};
    }

    return {'canAdd': true, 'isPremium': false};
  }

  // Check invoice limit
  Future<Map<String, dynamic>> checkInvoiceLimit() async {
    final limits = await checkLimits();
    if (limits['isPremium'] == true) {
      return {'canAdd': true, 'message': '', 'count': 0, 'limit': -1};
    }

    final user = _auth.currentUser;
    if (user == null) {
      return {'canAdd': false, 'message': 'Please login first', 'count': 0, 'limit': freeInvoiceLimit};
    }

    try {
      final invoices = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('invoices')
          .get();

      final count = invoices.docs.length;

      if (count >= freeInvoiceLimit) {
        return {
          'canAdd': false,
          'message': 'Free plan limit: $freeInvoiceLimit invoices. Upgrade to Premium for unlimited invoices.',
          'count': count,
          'limit': freeInvoiceLimit,
        };
      }

      return {
        'canAdd': true,
        'message': '',
        'count': count,
        'limit': freeInvoiceLimit,
      };
    } catch (e) {
      return {'canAdd': true, 'message': '', 'count': 0, 'limit': freeInvoiceLimit};
    }
  }

  // Check client limit
  Future<Map<String, dynamic>> checkClientLimit() async {
    final limits = await checkLimits();
    if (limits['isPremium'] == true) {
      return {'canAdd': true, 'message': '', 'count': 0, 'limit': -1};
    }

    final user = _auth.currentUser;
    if (user == null) {
      return {'canAdd': false, 'message': 'Please login first', 'count': 0, 'limit': freeClientLimit};
    }

    try {
      final clients = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('clients')
          .get();

      final count = clients.docs.length;

      if (count >= freeClientLimit) {
        return {
          'canAdd': false,
          'message': 'Free plan limit: $freeClientLimit clients. Upgrade to Premium for unlimited clients.',
          'count': count,
          'limit': freeClientLimit,
        };
      }

      return {
        'canAdd': true,
        'message': '',
        'count': count,
        'limit': freeClientLimit,
      };
    } catch (e) {
      return {'canAdd': true, 'message': '', 'count': 0, 'limit': freeClientLimit};
    }
  }

  // Check expense limit
  Future<Map<String, dynamic>> checkExpenseLimit() async {
    final limits = await checkLimits();
    if (limits['isPremium'] == true) {
      return {'canAdd': true, 'message': '', 'count': 0, 'limit': -1};
    }

    final user = _auth.currentUser;
    if (user == null) {
      return {'canAdd': false, 'message': 'Please login first', 'count': 0, 'limit': freeExpenseLimit};
    }

    try {
      final expenses = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('expenses')
          .get();

      final count = expenses.docs.length;

      if (count >= freeExpenseLimit) {
        return {
          'canAdd': false,
          'message': 'Free plan limit: $freeExpenseLimit expenses. Upgrade to Premium for unlimited tracking.',
          'count': count,
          'limit': freeExpenseLimit,
        };
      }

      return {
        'canAdd': true,
        'message': '',
        'count': count,
        'limit': freeExpenseLimit,
      };
    } catch (e) {
      return {'canAdd': true, 'message': '', 'count': 0, 'limit': freeExpenseLimit};
    }
  }

  // Check mileage limit
  Future<Map<String, dynamic>> checkMileageLimit() async {
    final limits = await checkLimits();
    if (limits['isPremium'] == true) {
      return {'canAdd': true, 'message': '', 'count': 0, 'limit': -1};
    }

    final user = _auth.currentUser;
    if (user == null) {
      return {'canAdd': false, 'message': 'Please login first', 'count': 0, 'limit': freeMileageLimit};
    }

    try {
      final mileage = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('mileage')
          .get();

      final count = mileage.docs.length;

      if (count >= freeMileageLimit) {
        return {
          'canAdd': false,
          'message': 'Free plan limit: $freeMileageLimit trips. Upgrade to Premium for unlimited mileage tracking.',
          'count': count,
          'limit': freeMileageLimit,
        };
      }

      return {
        'canAdd': true,
        'message': '',
        'count': count,
        'limit': freeMileageLimit,
      };
    } catch (e) {
      return {'canAdd': true, 'message': '', 'count': 0, 'limit': freeMileageLimit};
    }
  }

  // Show premium dialog
  static void showPremiumDialog(context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.star, color: Colors.amber, size: 28),
            SizedBox(width: 12),
            Text('Premium Feature'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Unlock $feature with Premium:'),
            const SizedBox(height: 16),
            const _PremiumFeatureItem(text: '✓ Unlimited invoices & clients'),
            const _PremiumFeatureItem(text: '✓ Advanced analytics & reports'),
            const _PremiumFeatureItem(text: '✓ Cloud backup & sync'),
            const _PremiumFeatureItem(text: '✓ Export to PDF & CSV'),
            const _PremiumFeatureItem(text: '✓ Priority support'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to settings/premium page
            },
            icon: const Icon(Icons.star),
            label: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }
}

class _PremiumFeatureItem extends StatelessWidget {
  final String text;
  
  const _PremiumFeatureItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }
}
