import 'package:test/test.dart';
import 'package:notari_flow/utils/subscription_service.dart';

void main() {
  group('SubscriptionService - Loan Signing Batch Profitability', () {
    test('calculates batch signing profitability and hourly rate correctly', () {
      final res = SubscriptionService.calculateNotaryLoanSigningBatchProfitability(
        totalAppointmentsCount: 3,
        totalGrossFeesUsd: 450.0,
        totalRoundTripMiles: 60.0,
        totalPrintingPaperCostUsd: 30.0,
        mileageRateUsd: 0.67,
        totalTimeHours: 5.0,
      );

      expect(res['valid'], equals(true));
      expect(res['totalTravelCostUsd'], equals(40.2));
      expect(res['totalExpensesUsd'], equals(70.2));
      expect(res['netBatchProfitUsd'], equals(379.8));
      expect(res['netHourlyRateUsd'], equals(75.96));
      expect(res['averageProfitPerSigningUsd'], equals(126.6));
      expect(res['batchEfficiencyTier'], equals('HIGHLY_EFFICIENT_BATCH'));
      expect(res['isBatchProfitable'], equals(true));
    });

    test('returns invalid result for non-positive appointments count', () => {
      final res = SubscriptionService.calculateNotaryLoanSigningBatchProfitability(
        totalAppointmentsCount: 0,
        totalGrossFeesUsd: 300.0,
        totalRoundTripMiles: 40.0,
        totalPrintingPaperCostUsd: 20.0,
      );

      expect(res['valid'], equals(false));
      expect(res['error'], contains('Appointments count and total time must be positive'));
    });
  });

  group('SubscriptionService - Annual License Renewal Audit', () => {
    test('evaluates fully compliant notary license audit correctly', () => {
      final res = SubscriptionService.calculateNotaryAnnualLicenseRenewalAudit(
        commissionExpirationDateStr: '2028-12-31',
        requiredBondAmountUsd: 10000.0,
        activeBondAmountUsd: 10000.0,
        eAndOInsuranceCoverageUsd: 25000.0,
      );

      expect(res['valid'], equals(true));
      expect(res['isBondCompliant'], equals(true));
      expect(res['isInsuranceActive'], equals(true));
      expect(res['isCommissionValid'], equals(true));
      expect(res['complianceTier'], equals('FULLY_COMPLIANT'));
      expect(res['isFullyCompliant'], equals(true));
    });

    test('returns invalid for empty commission date string', () => {
      final res = SubscriptionService.calculateNotaryAnnualLicenseRenewalAudit(
        commissionExpirationDateStr: '',
      );

      expect(res['valid'], equals(false));
      expect(res['error'], contains('Commission expiration date and required bond amount are required'));
    });
  });

  group('SubscriptionService - Errors & Omissions Insurance Audit', () => {
    test('calculates adequate E&O coverage for standard volume', () => {
      final res = SubscriptionService.calculateNotaryErrorsAndOmissionsInsuranceAudit(
        currentPolicyCoverageUsd: 50000.0,
        monthlyLoanSigningsCount: 10,
      );

      expect(res['valid'], equals(true));
      expect(res['isCoverageAdequate'], equals(true));
      expect(res['auditScore'], equals(100));
      expect(res['coverageTier'], equals('ADEQUATE_EO_COVERAGE'));
    });

    test('returns invalid for non-positive policy coverage', () => {
      final res = SubscriptionService.calculateNotaryErrorsAndOmissionsInsuranceAudit(
        currentPolicyCoverageUsd: 0.0,
      );

      expect(res['valid'], equals(false));
      expect(res['error'], equals('Policy coverage must be a positive number'));
    });
  });

  group('calculateNotaryComplianceAndAuditReadiness', () {
    test('calculates state audit ready tier for fully compliant notary', () {
      final res = SubscriptionService.calculateNotaryComplianceAndAuditReadiness(
        completedJournalEntries: 20,
        missingSignaturesCount: 0,
        isEoInsuranceActive: true,
        isCommissionActive: true,
        isStateFeeCapCompliant: true,
      );

      expect(res['valid'], equals(true));
      expect(res['auditReadinessScore'], equals(100));
      expect(res['readinessTier'], equals('STATE_AUDIT_READY'));
      expect(res['isAuditReady'], equals(true));
      expect(res['recommendation'], contains('Notary records and active credentials achieve full state audit readiness'));
    });

    test('returns non-compliant high risk when commission is inactive', () {
      final res = SubscriptionService.calculateNotaryComplianceAndAuditReadiness(
        isCommissionActive: false,
      );

      expect(res['valid'], equals(true));
      expect(res['readinessTier'], equals('NON_COMPLIANT_HIGH_RISK'));
      expect(res['isAuditReady'], equals(false));
      expect(res['recommendation'], contains('CRITICAL COMPLIANCE ALERT'));
    });

    test('returns error for negative journal entries', () {
      final res = SubscriptionService.calculateNotaryComplianceAndAuditReadiness(
        completedJournalEntries: -5,
      );

      expect(res['valid'], equals(false));
      expect(res['error'], equals('Completed journal entries must be a non-negative number'));
    });
  });

  group('calculateNotaryJournalEntryIntegrityAudit', () {
    test('calculates state compliant journal tier for complete entries', () {
      final res = SubscriptionService.calculateNotaryJournalEntryIntegrityAudit(
        totalEntries: 50,
        missingIdTypeCount: 0,
        missingThumbprintCount: 0,
        unverifiedSignerCount: 0,
        hasDigitalBackup: true,
      );

      expect(res['valid'], equals(true));
      expect(res['totalIntegrityScore'], equals(100));
      expect(res['auditTier'], equals('STATE_COMPLIANT_JOURNAL'));
      expect(res['isJournalAuditPassed'], equals(true));
      expect(res['recommendation'], contains('Notary journal entries maintain 100% legal compliance'));
    });

    test('returns error for non-positive total entries', () {
      final res = SubscriptionService.calculateNotaryJournalEntryIntegrityAudit(
        totalEntries: 0,
      );

      expect(res['valid'], equals(false));
      expect(res['error'], equals('Total entries must be a positive number'));
    });
  });

  group('calculateNotaryRemoteOnlineNotarizationSessionSecurityScore', () {
    test('calculates SECURE_RON_SESSION_VERIFIED tier for full video archive and high KBA score', () {
      final res = SubscriptionService.calculateNotaryRemoteOnlineNotarizationSessionSecurityScore(
        isVideoSessionRecordedAndArchived: true,
        kbaPassPercentage: 100.0,
        isTamperEvidentDigitalSealApplied: true,
        idCredentialAnalysisScore: 95.0,
      );

      expect(res['valid'], equals(true));
      expect(res['totalRonSecurityScore'], equals(99));
      expect(res['ronComplianceTier'], equals('SECURE_RON_SESSION_VERIFIED'));
      expect(res['isRonCompliant'], equals(true));
      expect(res['recommendation'], contains('Remote Online Notarization (RON) session complies cleanly'));
    });

    test('returns error for negative percentage scores', () {
      final res = SubscriptionService.calculateNotaryRemoteOnlineNotarizationSessionSecurityScore(
        isVideoSessionRecordedAndArchived: true,
        kbaPassPercentage: -10.0,
        isTamperEvidentDigitalSealApplied: true,
        idCredentialAnalysisScore: 90.0,
      );

      expect(res['valid'], equals(false));
      expect(res['error'], equals('Percentage scores cannot be negative'));
    });
  });

  group('calculateNotaryDocumentIdentityVerificationAuditScore', () {
    test('calculates IDENTITY_VERIFIED_SECURE tier for valid ID and high biometric/KBA scores', () {
      final res = SubscriptionService.calculateNotaryDocumentIdentityVerificationAuditScore(
        hasGovernmentIdScanned: true,
        idExpiryCheckPassed: true,
        biometricFacialMatchScore: 95.0,
        kbaScore: 90.0,
      );

      expect(res['valid'], equals(true));
      expect(res['identityVerificationScore'], equals(96));
      expect(res['auditTier'], equals('IDENTITY_VERIFIED_SECURE'));
      expect(res['isIdentityVerified'], equals(true));
      expect(res['recommendation'], contains('Signer identity verified securely'));
    });

    test('returns FAILED_IDENTITY_AUDIT when ID check fails or is missing', () {
      final res = SubscriptionService.calculateNotaryDocumentIdentityVerificationAuditScore(
        hasGovernmentIdScanned: false,
        idExpiryCheckPassed: false,
        biometricFacialMatchScore: 50.0,
        kbaScore: 50.0,
      );

      expect(res['valid'], equals(true));
      expect(res['auditTier'], equals('FAILED_IDENTITY_AUDIT'));
      expect(res['isIdentityVerified'], equals(false));
      expect(res['recommendation'], contains('FAILED IDENTITY AUDIT'));
    });

    test('returns error for negative scores', () {
      final res = SubscriptionService.calculateNotaryDocumentIdentityVerificationAuditScore(
        hasGovernmentIdScanned: true,
        idExpiryCheckPassed: true,
        biometricFacialMatchScore: -5.0,
        kbaScore: 90.0,
      );

      expect(res['valid'], equals(false));
      expect(res['error'], equals('Scores cannot be negative'));
    });
  });
}






