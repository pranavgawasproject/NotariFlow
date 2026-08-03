import 'package:flutter_test/flutter_test.dart';
import 'package:notariflow/utils/ron_compliance_validator.dart';

void main() {
  group('RON Compliance Validator Unit Tests', () {
    test('evaluates fully compliant RON session correctly', () {
      final result = calculateRonComplianceScore(
        isKbaVerified: true,
        isCredentialAnalysisPassed: true,
        isAudioVideoRecorded: true,
        isDigitalCertificateValid: true,
        stateFeeChargedUsd: 25.0,
      );

      expect(result.complianceScore, equals(100));
      expect(result.status, equals('COMPLIANT'));
      expect(result.warnings.isEmpty, isTrue);
    });

    test('flags non-compliant session when KBA and credential analysis fail', () {
      final result = calculateRonComplianceScore(
        isKbaVerified: false,
        isCredentialAnalysisPassed: false,
        isAudioVideoRecorded: true,
        isDigitalCertificateValid: true,
        stateFeeChargedUsd: 30.0,
        maxStateFeeAllowedUsd: 25.0,
      );

      expect(result.complianceScore, lessThan(90));
      expect(result.status, equals('NON_COMPLIANT'));
      expect(result.isKbaCompliant, isFalse);
      expect(result.isFeeCompliant, isFalse);
      expect(result.warnings.length, equals(3));
    });
  });
}
