# Premium Subscription Implementation Guide

## Overview
This document outlines the premium subscription features implemented in NotariFlow.

## Premium vs Free Features

### ✅ Free Features
- Dashboard view
- Up to 10 invoices
- Up to 5 clients
- Up to 20 expenses
- Up to 20 mileage entries
- Basic calculator
- Journal entries
- Settings

### ⭐ Premium Features ($14.99/month or $149/year)
- **Unlimited Everything**
  - Unlimited invoices
  - Unlimited clients
  - Unlimited expenses
  - Unlimited mileage tracking

- **Advanced Analytics**
  - Detailed charts and graphs
  - Profit/loss reports
  - Trend analysis
  - Revenue forecasting

- **Export Capabilities**
  - Export invoices to PDF
  - Export data to CSV
  - Batch export options

- **Cloud Sync & Backup**
  - Automatic cloud backup
  - Multi-device sync
  - Data recovery

- **Custom Branding**
  - Add your logo to invoices
  - Custom color schemes
  - Professional templates

- **Priority Support**
  - Email support
  - Faster response times

## Implementation Files

### 1. Subscription Service (`lib/utils/subscription_service.dart`)
Core service that manages subscription state and limits.

**Key Methods:**
- `isPremium()` - Check if user has active premium
- `checkInvoiceLimit()` - Verify invoice count against limit
- `checkClientLimit()` - Verify client count against limit
- `checkExpenseLimit()` - Verify expense count against limit
- `checkMileageLimit()` - Verify mileage count against limit
- `activatePremium()` - Activate premium after payment

### 2. Premium Widgets (`lib/widgets/premium_widgets.dart`)
Reusable UI components for premium features.

**Components:**
- `PremiumBanner` - Shows usage limits with progress bar
- `PremiumFeatureLock` - Locks premium-only features
- `PremiumBadge` - Displays "PRO" badge for premium users

## Integration Steps

### Step 1: Import Services
Add to top of `lib/main.dart`:
\`\`\`dart
import 'utils/subscription_service.dart';
import 'widgets/premium_widgets.dart';
\`\`\`

### Step 2: Check Limits Before Adding Items

#### Example: Invoice Creation
\`\`\`dart
// In InvoicesScreen, before showing add dialog:
Future<void> _showAddInvoiceDialog() async {
  // Check limit first
  final limitCheck = await SubscriptionService().checkInvoiceLimit();
  
  if (!limitCheck['canAdd']) {
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
      ),
    );
    return;
  }
  
  // Proceed with add invoice dialog
  showDialog(...);
}
\`\`\`

#### Example: Client Addition
\`\`\`dart
// In ClientsScreen, before adding client:
Future<void> _showAddClientDialog() async {
  final limitCheck = await SubscriptionService().checkClientLimit();
  
  if (!limitCheck['canAdd']) {
    SubscriptionService.showPremiumDialog(context, 'Unlimited Clients');
    return;
  }
  
  // Show add client dialog
}
\`\`\`

### Step 3: Display Usage Banners

#### Example: Show Banner in Invoices Screen
\`\`\`dart
@override
Widget build(BuildContext context) {
  return FutureBuilder<bool>(
    future: SubscriptionService().isPremium(),
    builder: (context, premiumSnapshot) {
      final isPremium = premiumSnapshot.data ?? false;
      
      return Column(
        children: [
          // Show banner for free users
          if (!isPremium)
            FutureBuilder<Map<String, dynamic>>(
              future: SubscriptionService().checkInvoiceLimit(),
              builder: (context, limitSnapshot) {
                if (limitSnapshot.hasData) {
                  final data = limitSnapshot.data!;
                  return PremiumBanner(
                    feature: 'invoices',
                    currentCount: data['count'],
                    limit: data['limit'],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          
          // Rest of your UI
          Expanded(
            child: StreamBuilder(...),
          ),
        ],
      );
    },
  );
}
\`\`\`

### Step 4: Lock Premium-Only Features

#### Example: Advanced Analytics
\`\`\`dart
// In AnalyticsScreen:
@override
Widget build(BuildContext context) {
  return FutureBuilder<bool>(
    future: SubscriptionService().isPremium(),
    builder: (context, snapshot) {
      final isPremium = snapshot.data ?? false;
      
      if (!isPremium) {
        return Center(
          child: PremiumFeatureLock(
            featureName: 'Advanced Analytics',
            icon: Icons.analytics,
            description: 'Unlock detailed charts, trends, and profit analysis with Premium',
          ),
        );
      }
      
      // Show full analytics for premium users
      return _buildAnalyticsDashboard();
    },
  );
}
\`\`\`

### Step 5: Disable Export for Free Users

#### Example: CSV Export
\`\`\`dart
// In any screen with export functionality:
IconButton(
  icon: const Icon(Icons.download),
  onPressed: () async {
    final isPremium = await SubscriptionService().isPremium();
    
    if (!isPremium) {
      SubscriptionService.showPremiumDialog(context, 'Export to CSV');
      return;
    }
    
    // Proceed with export
    await _exportCSV();
  },
)
\`\`\`

### Step 6: Show Premium Badge for Premium Users

#### Example: In Settings Screen
\`\`\`dart
// Show premium status:
FutureBuilder<bool>(
  future: SubscriptionService().isPremium(),
  builder: (context, snapshot) {
    final isPremium = snapshot.data ?? false;
    
    return ListTile(
      title: Row(
        children: [
          const Text('Account Status'),
          const SizedBox(width: 8),
          if (isPremium) const PremiumBadge(),
        ],
      ),
      subtitle: Text(isPremium ? 'Premium Member' : 'Free Plan'),
    );
  },
)
\`\`\`

## Firestore Database Structure

### Users Collection
\`\`\`
users/{userId}/
  - email: string
  - name: string
  - isPremium: boolean
  - subscriptionPlan: 'free' | 'monthly' | 'yearly'
  - subscriptionActivatedAt: timestamp
  - subscriptionExpiry: timestamp (optional)
  - createdAt: timestamp
\`\`\`

## Payment Integration (LemonSqueezy)

After successful payment from LemonSqueezy webhook:

\`\`\`dart
// Call this after payment confirmation
await SubscriptionService().activatePremium(
  'monthly', // or 'yearly'
  expiryDate: DateTime.now().add(const Duration(days: 30)), // or 365 for yearly
);
\`\`\`

## Testing Premium Features

### Test Mode - Activate Premium Manually
For testing, you can manually activate premium in Firestore:

1. Go to Firebase Console → Firestore
2. Find your user document: `users/{yourUserId}`
3. Add/update fields:
   - `isPremium`: true
   - `subscriptionPlan`: 'yearly'

### Test Free Limits
1. Create a test account
2. Try adding more than 10 invoices
3. Verify the limit banner appears
4. Try adding 11th invoice - should show upgrade prompt

## UI/UX Best Practices

1. **Don't Block Core Features**: Dashboard, basic invoice viewing should work for free users
2. **Clear Communication**: Always tell users what they get with premium
3. **Soft Limits**: Show warnings at 80% of limit (e.g., 8/10 invoices)
4. **Easy Upgrade Path**: One-click upgrade buttons throughout the app
5. **Value Proposition**: Highlight premium benefits in banners

## Next Steps

1. ✅ Create subscription service files
2. ⏳ Integrate limit checks in main.dart
3. ⏳ Add premium banners to screens
4. ⏳ Lock advanced analytics
5. ⏳ Disable exports for free users
6. ⏳ Test payment flow
7. ⏳ Set up LemonSqueezy webhooks

## Questions?

Contact the development team for assistance with implementation.
