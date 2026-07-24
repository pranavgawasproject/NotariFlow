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

  /// Calculate usage percentage (0-100) towards free limit for UI progress bars
  static Map<String, dynamic> calculatePlanUsagePercentage(int currentCount, int maxLimit) {
    if (maxLimit <= 0) {
      return {'percentage': 0, 'isNearLimit': false, 'isLimitReached': false};
    }
    final count = currentCount < 0 ? 0 : currentCount;
    final pct = ((count / maxLimit) * 100).round().clamp(0, 100);
    return {
      'percentage': pct,
      'isNearLimit': pct >= 80 && pct < 100,
      'isLimitReached': pct >= 100,
    };
  }

  /// Calculate estimated fee for notarization service including travel mileage
  static Map<String, dynamic> calculateNotaryFeeEstimate({
    int signaturesCount = 1,
    double travelMiles = 0.0,
    double feePerSignature = 10.0,
    double mileageRate = 0.67,
  }) {
    final sigs = signaturesCount <= 0 ? 1 : signaturesCount;
    final miles = travelMiles < 0 ? 0.0 : travelMiles;
    final sigFee = feePerSignature < 0 ? 10.0 : feePerSignature;
    final rate = mileageRate < 0 ? 0.67 : mileageRate;

    final signatureTotal = sigs * sigFee;
    final travelTotal = miles * rate;
    final totalEstimate = signatureTotal + travelTotal;

    return {
      'signaturesCount': sigs,
      'signatureTotal': double.parse(signatureTotal.toStringAsFixed(2)),
      'travelMiles': double.parse(miles.toStringAsFixed(2)),
      'travelTotal': double.parse(travelTotal.toStringAsFixed(2)),
      'totalEstimate': double.parse(totalEstimate.toStringAsFixed(2)),
    };
  }

  /// Calculate annual tax savings and deduction from travel mileage logs
  static Map<String, dynamic> calculateTravelMileageDeductionTaxSavings({
    required double totalMiles,
    double standardRatePerMile = 0.67,
    double taxBracketPercentage = 22.0,
  }) {
    final miles = totalMiles < 0 ? 0.0 : totalMiles;
    final rate = standardRatePerMile < 0 ? 0.67 : standardRatePerMile;
    final bracket = taxBracketPercentage < 0 ? 22.0 : taxBracketPercentage;

    final totalDeductionUsd = miles * rate;
    final estimatedTaxSavedUsd = totalDeductionUsd * (bracket / 100.0);

    return {
      'totalMiles': double.parse(miles.toStringAsFixed(2)),
      'ratePerMile': rate,
      'taxBracketPercentage': bracket,
      'totalDeductionUsd': double.parse(totalDeductionUsd.toStringAsFixed(2)),
      'estimatedTaxSavedUsd': double.parse(estimatedTaxSavedUsd.toStringAsFixed(2)),
    };
  }

  /// Calculate annual notary business revenue projection & profit margin
  static Map<String, dynamic> calculateAnnualNotaryBusinessRevenueProjection({
    required int monthlyNotaryJobs,
    required double avgFeePerJob,
    double monthlySoftwareExpenseUsd = 20.0,
    double monthlyMileageExpenseUsd = 50.0,
  }) {
    final jobs = monthlyNotaryJobs < 0 ? 0 : monthlyNotaryJobs;
    final fee = avgFeePerJob < 0 ? 0.0 : avgFeePerJob;
    final softwareExp = monthlySoftwareExpenseUsd < 0 ? 0.0 : monthlySoftwareExpenseUsd;
    final mileageExp = monthlyMileageExpenseUsd < 0 ? 0.0 : monthlyMileageExpenseUsd;

    final grossMonthlyRevenueUsd = jobs * fee;
    final grossAnnualRevenueUsd = grossMonthlyRevenueUsd * 12;
    final annualExpensesUsd = (softwareExp + mileageExp) * 12;
    final netAnnualProfitUsd = grossAnnualRevenueUsd - annualExpensesUsd;

    final profitMarginPct = grossAnnualRevenueUsd > 0
        ? ((netAnnualProfitUsd / grossAnnualRevenueUsd) * 100.0)
        : 0.0;

    return {
      'monthlyNotaryJobs': jobs,
      'avgFeePerJob': fee,
      'grossMonthlyRevenueUsd': double.parse(grossMonthlyRevenueUsd.toStringAsFixed(2)),
      'grossAnnualRevenueUsd': double.parse(grossAnnualRevenueUsd.toStringAsFixed(2)),
      'annualExpensesUsd': double.parse(annualExpensesUsd.toStringAsFixed(2)),
      'netAnnualProfitUsd': double.parse(netAnnualProfitUsd.toStringAsFixed(2)),
      'profitMarginPercentage': double.parse(profitMarginPct.toStringAsFixed(1)),
    };
  }

  /// Calculate compliance score (0-100%) and missing audit fields for a notary journal record
  static Map<String, dynamic> calculateNotaryDocumentComplianceScore({
    required bool hasSignerIdType,
    required bool hasSignerSignature,
    required bool hasThumbprint,
    required bool hasFeeRecorded,
    required bool hasSealTimestamp,
  }) {
    int score = 0;
    final List<String> missingFields = [];

    if (hasSignerIdType) score += 25; else missingFields.add('Signer ID Type');
    if (hasSignerSignature) score += 25; else missingFields.add('Signer Signature');
    if (hasThumbprint) score += 20; else missingFields.add('Thumbprint');
    if (hasFeeRecorded) score += 15; else missingFields.add('Fee Record');
    if (hasSealTimestamp) score += 15; else missingFields.add('Seal Timestamp');

    return {
      'score': score,
      'isCompliant': score >= 80,
      'missingFields': missingFields,
    };
  }

  /// Calculate travel distance surcharge fee and total invoice estimate for mobile notary appointments
  static Map<String, dynamic> calculateNotaryTravelDistanceFee({
    required double travelDistanceMiles,
    double baseTravelFeeUsd = 25.0,
    double extraPerMileUsd = 1.50,
    bool isAfterHoursOrWeekend = false,
  }) {
    final miles = travelDistanceMiles < 0 ? 0.0 : travelDistanceMiles;
    final baseFee = baseTravelFeeUsd < 0 ? 25.0 : baseTravelFeeUsd;
    final perMile = extraPerMileUsd < 0 ? 1.50 : extraPerMileUsd;

    final distanceSurcharge = miles > 10 ? (miles - 10) * perMile : 0.0;
    final afterHoursMultiplier = isAfterHoursOrWeekend ? 1.5 : 1.0;

    final subtotalTravelFee = (baseFee + distanceSurcharge) * afterHoursMultiplier;
    final totalTravelFeeUsd = double.parse(subtotalTravelFee.toStringAsFixed(2));

    return {
      'travelDistanceMiles': double.parse(miles.toStringAsFixed(2)),
      'baseTravelFeeUsd': baseFee,
      'distanceSurchargeUsd': double.parse(distanceSurcharge.toStringAsFixed(2)),
      'isAfterHoursOrWeekend': isAfterHoursOrWeekend,
      'totalTravelFeeUsd': totalTravelFeeUsd,
    };
  }

  /// Calculate loan signing package fee estimate with print page count & courier fee
  static Map<String, dynamic> calculateLoanSigningPackageFee({
    double basePackageFeeUsd = 150.0,
    int pageCount = 100,
    double printFeePerPageUsd = 0.25,
    double shippingCourierFeeUsd = 25.0,
    bool requireScanBacks = false,
    double scanBackFeeUsd = 20.0,
  }) {
    final baseFee = basePackageFeeUsd < 0 ? 150.0 : basePackageFeeUsd;
    final pages = pageCount < 0 ? 0 : pageCount;
    final printFeeRate = printFeePerPageUsd < 0 ? 0.25 : printFeePerPageUsd;
    final courierFee = shippingCourierFeeUsd < 0 ? 0.0 : shippingCourierFeeUsd;
    final scanFee = scanBackFeeUsd < 0 ? 0.0 : scanBackFeeUsd;

    final printTotalUsd = pages * printFeeRate;
    final scanBackTotalUsd = requireScanBacks ? scanFee : 0.0;
    final totalFeeUsd = baseFee + printTotalUsd + courierFee + scanBackTotalUsd;

    return {
      'basePackageFeeUsd': baseFee,
      'pageCount': pages,
      'printTotalUsd': double.parse(printTotalUsd.toStringAsFixed(2)),
      'shippingCourierFeeUsd': courierFee,
      'scanBackTotalUsd': double.parse(scanBackTotalUsd.toStringAsFixed(2)),
      'totalFeeUsd': double.parse(totalFeeUsd.toStringAsFixed(2)),
    };
  }

  /// Calculate notary signer verification risk score based on ID expiration, distance mismatch, and signature confidence
  static Map<String, dynamic> calculateNotarySignerVerificationRiskScore({
    required bool isIdExpired,
    required double distanceMismatchMiles,
    required double signatureMatchConfidencePct,
  }) {
    final miles = distanceMismatchMiles < 0 ? 0.0 : distanceMismatchMiles;
    final confidence = signatureMatchConfidencePct < 0 ? 0.0 : (signatureMatchConfidencePct > 100 ? 100.0 : signatureMatchConfidencePct);

    double riskScore = 10.0;
    if (isIdExpired) riskScore += 50.0;
    if (miles > 25) {
      riskScore += 25.0;
    } else if (miles > 10) {
      riskScore += 15.0;
    }

    if (confidence < 70) {
      riskScore += 20.0;
    } else if (confidence < 85) {
      riskScore += 10.0;
    }

    final finalRiskScore = riskScore > 100.0 ? 100.0 : double.parse(riskScore.toStringAsFixed(1));
    final String riskTier;
    if (finalRiskScore >= 60) {
      riskTier = 'HIGH_RISK';
    } else if (finalRiskScore >= 35) {
      riskTier = 'MODERATE_RISK';
    } else {
      riskTier = 'LOW_RISK';
    }

    return {
      'riskScore': finalRiskScore,
      'riskTier': riskTier,
      'requiresSecondaryVerification': finalRiskScore >= 50,
      'isApprovedForSigning': finalRiskScore < 60 && !isIdExpired,
    };
  }

  /// Calculate notary journal audit compliance index based on missing signatures, thumbprints, and seal details
  static Map<String, dynamic> calculateNotaryJournalAuditComplianceIndex({
    required int totalJournalEntries,
    int missingSignatureCount = 0,
    int missingThumbprintCount = 0,
    bool includesStampDetails = true,
  }) {
    final entries = totalJournalEntries < 0 ? 0 : totalJournalEntries;
    if (entries == 0) {
      return {
        'complianceScore': 100.0,
        'auditGrade': 'A+',
        'isAuditReady': true,
        'totalJournalEntries': 0,
      };
    }

    final sigErrors = missingSignatureCount < 0 ? 0 : missingSignatureCount;
    final thumbErrors = missingThumbprintCount < 0 ? 0 : missingThumbprintCount;

    double score = 100.0;
    score -= (sigErrors / entries) * 40.0;
    score -= (thumbErrors / entries) * 30.0;
    if (!includesStampDetails) score -= 15.0;

    final finalScore = score < 0 ? 0.0 : double.parse(score.toStringAsFixed(1));
    final String auditGrade;
    if (finalScore >= 90) {
      auditGrade = 'A+';
    } else if (finalScore >= 75) {
      auditGrade = 'B';
    } else {
      auditGrade = 'C';
    }

    return {
      'complianceScore': finalScore,
      'auditGrade': auditGrade,
      'isAuditReady': finalScore >= 80,
      'totalJournalEntries': entries,
    };
  }

  /// Calculate remote online notarization (RON) fee schedule including platform fee and video recording archive fee
  static Map<String, dynamic> calculateRemoteOnlineNotarizationFeeSchedule({
    double baseRonFeeUsd = 25.0,
    int additionalSignerCount = 0,
    double extraSignerFeeUsd = 10.0,
    bool includesVideoArchiveStorage = true,
    double archiveStorageFeeUsd = 5.0,
  }) {
    final baseFee = baseRonFeeUsd < 0 ? 25.0 : baseRonFeeUsd;
    final signers = additionalSignerCount < 0 ? 0 : additionalSignerCount;
    final extraFeeRate = extraSignerFeeUsd < 0 ? 10.0 : extraSignerFeeUsd;
    final archiveFee = includesVideoArchiveStorage ? (archiveStorageFeeUsd < 0 ? 0.0 : archiveStorageFeeUsd) : 0.0;

    final additionalSignerTotal = signers * extraFeeRate;
    final totalRonFeeUsd = baseFee + additionalSignerTotal + archiveFee;

    return {
      'baseRonFeeUsd': baseFee,
      'additionalSignerCount': signers,
      'additionalSignerTotalUsd': double.parse(additionalSignerTotal.toStringAsFixed(2)),
      'includesVideoArchiveStorage': includesVideoArchiveStorage,
      'archiveStorageFeeUsd': archiveFee,
      'totalRonFeeUsd': double.parse(totalRonFeeUsd.toStringAsFixed(2)),
    };
  }

  /// Calculate RON (Remote Online Notarization) session compliance score
  static Map<String, dynamic> calculateNotarySessionComplianceScore({
    required bool isAudioVideoRecorded,
    required bool isKbaIdentityVerified,
    required bool isCredentialAnalysisPassed,
    required bool isDigitalSignatureAttached,
  }) {
    int score = 0;
    final List<String> pendingVerifications = [];

    if (isAudioVideoRecorded) score += 30; else pendingVerifications.add('Audio/Video Recording');
    if (isKbaIdentityVerified) score += 30; else pendingVerifications.add('Knowledge-Based Auth');
    if (isCredentialAnalysisPassed) score += 20; else pendingVerifications.add('ID Credential Analysis');
    if (isDigitalSignatureAttached) score += 20; else pendingVerifications.add('Digital PKI Signature');

    return {
      'score': score,
      'isSessionCompliant': score >= 80,
      'pendingVerifications': pendingVerifications,
    };
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

  /// Calculates notary document retention compliance score and risk grade
  static Map<String, dynamic> calculateNotaryDocumentRetentionPolicyScore({
    int retentionYears = 7,
    bool hasEncryptedBackup = true,
    bool isAuditLogged = true,
    bool hasDigitalSignature = true,
  }) {
    int score = 0;
    if (retentionYears >= 10) {
      score += 40;
    } else if (retentionYears >= 7) {
      score += 30;
    } else if (retentionYears >= 5) {
      score += 15;
    }

    if (hasEncryptedBackup) score += 25;
    if (isAuditLogged) score += 20;
    if (hasDigitalSignature) score += 15;

    score = score > 100 ? 100 : score;
    final bool isCompliant = score >= 70;
    String grade = 'EXCELLENT';

    if (score < 50) {
      grade = 'NON_COMPLIANT';
    } else if (score < 70) {
      grade = 'NEEDS_IMPROVEMENT';
    } else if (score < 85) {
      grade = 'SATISFACTORY';
    }

    return {
      'valid': true,
      'retentionYears': retentionYears,
      'hasEncryptedBackup': hasEncryptedBackup,
      'isAuditLogged': isAuditLogged,
      'hasDigitalSignature': hasDigitalSignature,
      'score': score,
      'isCompliant': isCompliant,
      'retentionGrade': grade,
      'recommendation': isCompliant
          ? 'Notary journal entries meet state legal retention policy requirements.'
          : 'Enable encrypted backup and digital signatures to achieve full compliance.',
    };
  }

  /// Calculates notary journal audit readiness score and compliance recommendations
  static Map<String, dynamic> calculateNotaryJournalAuditReadinessScore({
    int totalEntries = 10,
    int missingSignatures = 0,
    int missingOcrData = 0,
    bool hasBiometricVerification = false,
  }) {
    if (totalEntries <= 0) {
      return {
        'valid': false,
        'error': 'Total entries must be a positive integer',
        'score': 0,
        'isReady': false,
      };
    }

    final int cleanSignatures = (totalEntries - missingSignatures).clamp(0, totalEntries);
    final int cleanOcr = (totalEntries - missingOcrData).clamp(0, totalEntries);

    final double signatureRatio = cleanSignatures / totalEntries;
    final double ocrRatio = cleanOcr / totalEntries;

    int score = ((signatureRatio * 50) + (ocrRatio * 40)).round();
    if (hasBiometricVerification) score += 10;
    score = score.clamp(0, 100);

    final bool isReady = score >= 80;
    String auditGrade = 'EXCELLENT';
    if (score < 50) {
      auditGrade = 'HIGH_RISK';
    } else if (score < 80) {
      auditGrade = 'MODERATE_RISK';
    }

    return {
      'valid': true,
      'totalEntries': totalEntries,
      'missingSignatures': missingSignatures,
      'missingOcrData': missingOcrData,
      'hasBiometricVerification': hasBiometricVerification,
      'score': score,
      'isReady': isReady,
      'auditGrade': auditGrade,
      'recommendation': isReady
          ? 'Journal entries are audit-ready with complete signatures and OCR data.'
          : 'Complete missing client signatures and scanned IDs before submitting for state audit.',
    };
  }

  /// Calculates notary identity verification confidence score for remote online notarization (RON)
  static Map<String, dynamic> calculateNotaryIdentityVerificationConfidenceScore({
    bool isGovernmentIdVerified = true,
    bool isKbaPassed = true,
    double facialBiometricMatchScore = 95.0,
    bool isAntiSpoofingCheckPassed = true,
  }) {
    int score = 0;
    if (isGovernmentIdVerified) score += 35;
    if (isKbaPassed) score += 25;
    if (isAntiSpoofingCheckPassed) score += 20;

    final matchScore = facialBiometricMatchScore.clamp(0.0, 100.0);
    score += ((matchScore / 100.0) * 20.0).round();
    score = score.clamp(0, 100);

    final bool isVerified = score >= 80;
    String confidenceTier = 'HIGH_CONFIDENCE';
    if (score < 50) {
      confidenceTier = 'UNVERIFIED';
    } else if (score < 80) {
      confidenceTier = 'MODERATE_CONFIDENCE';
    }

    return {
      'valid': true,
      'isGovernmentIdVerified': isGovernmentIdVerified,
      'isKbaPassed': isKbaPassed,
      'facialBiometricMatchScore': matchScore,
      'isAntiSpoofingCheckPassed': isAntiSpoofingCheckPassed,
      'confidenceScore': score,
      'isVerified': isVerified,
      'confidenceTier': confidenceTier,
      'recommendation': isVerified
          ? 'Identity verification confidence score exceeds state RON compliance thresholds.'
          : 'Require additional credential analysis or secondary Knowledge-Based Authentication (KBA).',
    };
  }
}



