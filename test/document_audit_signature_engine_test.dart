import 'package:flutter_test/flutter_test.dart';
import 'package:notariflow/utils/document_audit_signature_engine.dart';

void main() {
  group('DocumentAuditSignatureEngine', () {
    test('generateDocumentFingerprint produces valid signature string', () {
      final fingerprint = DocumentAuditSignatureEngine.generateDocumentFingerprint(
        'DOC-1001',
        'Power of Attorney Contract',
        DateTime(2026, 8, 6),
      );

      expect(fingerprint, startsWith('notari_sig_'));
      expect(fingerprint.length, greaterThan(15));
    });

    test('validateNotaryStampFormat validates state stamp format', () {
      final valid = DocumentAuditSignatureEngine.validateNotaryStampFormat('CA-NOTARY-8899', 'CA');
      expect(valid, isTrue);

      final invalid = DocumentAuditSignatureEngine.validateNotaryStampFormat('123', 'NY');
      expect(invalid, isFalse);
    });

    test('calculateJournalComplianceScore scores journal entry completeness', () {
      final full = DocumentAuditSignatureEngine.calculateJournalComplianceScore(
        hasSignature: true,
        hasThumbprint: true,
        hasIdVerified: true,
        hasFeeRecorded: true,
      );

      expect(full['score'], equals(100));
      expect(full['complianceTier'], equals('FULLY_COMPLIANT'));
      expect(full['isAuditReady'], isTrue);
    });
  });
}
