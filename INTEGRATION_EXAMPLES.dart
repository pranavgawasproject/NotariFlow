// EXAMPLE: How to integrate subscription limits in your existing code
// This shows the key changes needed in main.dart

// ============================================================================
// 1. ADD IMPORTS AT THE TOP OF main.dart
// ============================================================================
import 'utils/subscription_service.dart';
import 'widgets/premium_widgets.dart';


// ============================================================================
// 2. MODIFY INVOICES SCREEN - Add limit check before creating invoice
// ============================================================================

// FIND: The FloatingActionButton in InvoicesScreen around line 2260
// REPLACE WITH:

FloatingActionButton(
  heroTag: 'add-invoice',
  onPressed: () async {
    // CHECK LIMIT BEFORE ALLOWING CREATION
    final limitCheck = await SubscriptionService().checkInvoiceLimit();
    
    if (!limitCheck['canAdd']) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(limitCheck['message']),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Upgrade',
              textColor: Colors.white,
              onPressed: () {
                SubscriptionService.showPremiumDialog(context, 'Unlimited Invoices');
              },
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return;
    }
    
    // EXISTING CODE - show add invoice dialog
    showDialog(
      context: context,
      builder: (ctx) => _AddInvoiceDialog(
        clients: clients,
        clientMap: clientMap,
      ),
    );
  },
  child: const Icon(Icons.add_rounded),
)

// ============================================================================
// 3. ADD USAGE BANNER TO INVOICES SCREEN
// ============================================================================

// FIND: The build method in _InvoicesScreenState around line 2220
// ADD THIS AFTER THE APP BAR, BEFORE THE MAIN CONTENT:

@override
Widget build(BuildContext context) {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  return Column(
    children: [
      // ADD THIS BANNER
      FutureBuilder<bool>(
        future: SubscriptionService().isPremium(),
        builder: (context, premiumSnapshot) {
          final isPremium = premiumSnapshot.data ?? false;
          
          if (isPremium) return const SizedBox.shrink();
          
          return FutureBuilder<Map<String, dynamic>>(
            future: SubscriptionService().checkInvoiceLimit(),
            builder: (context, limitSnapshot) {
              if (!limitSnapshot.hasData) return const SizedBox.shrink();
              
              final data = limitSnapshot.data!;
              return PremiumBanner(
                feature: 'invoices',
                currentCount: data['count'] ?? 0,
                limit: data['limit'] ?? 10,
              );
            },
          );
        },
      ),
      
      // EXISTING STREAMBUILDER CODE...
      Expanded(
        child: StreamBuilder(...),
      ),
    ],
  );
}


// ============================================================================
// 4. MODIFY CLIENTS SCREEN - Add limit check
// ============================================================================

// FIND: FloatingActionButton in ClientsScreen around line 2900
// REPLACE WITH:

FloatingActionButton(
  heroTag: 'add-client',
  onPressed: () async {
    // CHECK LIMIT
    final limitCheck = await SubscriptionService().checkClientLimit();
    
    if (!limitCheck['canAdd']) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(limitCheck['message']),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Upgrade',
              textColor: Colors.white,
              onPressed: () {
                SubscriptionService.showPremiumDialog(context, 'Unlimited Clients');
              },
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return;
    }
    
    // EXISTING ADD CLIENT DIALOG CODE
    showDialog(
      context: context,
      builder: (ctx) => _AddClientDialog(),
    );
  },
  child: const Icon(Icons.add_rounded),
)


// ============================================================================
// 5. MODIFY EXPENSES SCREEN - Add limit check
// ============================================================================

// Similar pattern for ExpensesScreen FloatingActionButton:

FloatingActionButton(
  heroTag: 'add-expense',
  onPressed: () async {
    final limitCheck = await SubscriptionService().checkExpenseLimit();
    
    if (!limitCheck['canAdd']) {
      if (context.mounted) {
        SubscriptionService.showPremiumDialog(context, 'Unlimited Expenses');
      }
      return;
    }
    
    // Show add expense dialog
    showDialog(
      context: context,
      builder: (ctx) => _AddExpenseDialog(),
    );
  },
  child: const Icon(Icons.add_rounded),
)


// ============================================================================
// 6. MODIFY MILEAGE SCREEN - Add limit check
// ============================================================================

FloatingActionButton(
  heroTag: 'add-mileage',
  onPressed: () async {
    final limitCheck = await SubscriptionService().checkMileageLimit();
    
    if (!limitCheck['canAdd']) {
      if (context.mounted) {
        SubscriptionService.showPremiumDialog(context, 'Unlimited Mileage');
      }
      return;
    }
    
    // Show add mileage dialog
    showDialog(
      context: context,
      builder: (ctx) => _AddMileageDialog(),
    );
  },
  child: const Icon(Icons.add_rounded),
)


// ============================================================================
// 7. LOCK ADVANCED ANALYTICS - Make it premium only
// ============================================================================

// FIND: AnalyticsScreen build method
// WRAP THE ENTIRE CONTENT:

@override
Widget build(BuildContext context) {
  return FutureBuilder<bool>(
    future: SubscriptionService().isPremium(),
    builder: (context, snapshot) {
      final isPremium = snapshot.data ?? false;
      
      // Show lock screen for free users
      if (!isPremium) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Analytics'),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: PremiumFeatureLock(
                featureName: 'Advanced Analytics',
                icon: Icons.analytics_rounded,
                description: 'Get detailed insights, charts, profit/loss reports, and revenue trends with Premium',
              ),
            ),
          ),
        );
      }
      
      // EXISTING ANALYTICS CODE FOR PREMIUM USERS
      return Scaffold(
        appBar: AppBar(
          title: const Text('Analytics'),
          actions: [
            const PremiumBadge(), // Show premium badge
            const SizedBox(width: 16),
          ],
        ),
        body: // ... existing analytics widgets
      );
    },
  );
}


// ============================================================================
// 8. DISABLE CSV EXPORT FOR FREE USERS
// ============================================================================

// FIND: Export button in InvoicesScreen (around line 2300)
// MODIFY:

IconButton(
  icon: const Icon(Icons.download_rounded),
  tooltip: 'Export CSV',
  onPressed: () async {
    // Check if premium
    final isPremium = await SubscriptionService().isPremium();
    
    if (!isPremium) {
      if (context.mounted) {
        SubscriptionService.showPremiumDialog(context, 'Export to CSV');
      }
      return;
    }
    
    // EXISTING EXPORT CODE
    await _exportCSV(invoices);
  },
)


// ============================================================================
// 9. UPDATE SETTINGS SCREEN - Show subscription status
// ============================================================================

// FIND: SettingsScreen build method, ADD this section:

// After the profile section, add subscription card:
Card(
  margin: const EdgeInsets.all(16),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: FutureBuilder<bool>(
      future: SubscriptionService().isPremium(),
      builder: (context, snapshot) {
        final isPremium = snapshot.data ?? false;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isPremium ? Icons.star : Icons.star_border,
                  color: isPremium ? Colors.amber : Colors.grey,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPremium ? 'Premium Member' : 'Free Plan',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isPremium 
                          ? 'Enjoying unlimited features'
                          : 'Upgrade to unlock all features',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isPremium) const PremiumBadge(),
              ],
            ),
            if (!isPremium) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    // Scroll to premium section
                    SubscriptionService.showPremiumDialog(context, 'All Features');
                  },
                  icon: const Icon(Icons.star),
                  label: const Text('Upgrade to Premium'),
                ),
              ),
            ],
          ],
        );
      },
    ),
  ),
)


// ============================================================================
// 10. HANDLE PAYMENT SUCCESS - Webhook Handler
// ============================================================================

// Create a new function to handle successful payment (call from webhook):
Future<void> handlePaymentSuccess({
  required String userId,
  required String plan, // 'monthly' or 'yearly'
  required String paymentId,
}) async {
  try {
    final expiryDate = plan == 'monthly'
        ? DateTime.now().add(const Duration(days: 30))
        : DateTime.now().add(const Duration(days: 365));
    
    // Update user's premium status
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .set({
      'isPremium': true,
      'subscriptionPlan': plan,
      'subscriptionActivatedAt': FieldValue.serverTimestamp(),
      'subscriptionExpiry': Timestamp.fromDate(expiryDate),
      'lastPaymentId': paymentId,
    }, SetOptions(merge: true));
    
    print('Premium activated for user: $userId, plan: $plan');
  } catch (e) {
    print('Error activating premium: $e');
  }
}

// ============================================================================
// SUMMARY OF CHANGES
// ============================================================================

/*
1. ✅ Add subscription service imports
2. ✅ Check limits before creating invoices (10 limit)
3. ✅ Check limits before adding clients (5 limit)
4. ✅ Check limits before adding expenses (20 limit)
5. ✅ Check limits before adding mileage (20 limit)
6. ✅ Show usage banners on each screen
7. ✅ Lock advanced analytics for free users
8. ✅ Disable CSV export for free users
9. ✅ Show premium status in settings
10. ✅ Add premium badge for premium users

FREE PLAN LIMITS:
- 10 invoices
- 5 clients
- 20 expenses
- 20 mileage entries
- No analytics
- No exports

PREMIUM FEATURES ($14.99/month or $149/year):
- Unlimited everything
- Advanced analytics with charts
- Export to PDF & CSV
- Cloud backup & sync
- Priority support
*/
