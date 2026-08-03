/// Remote Online Notarization (RON) Compliance & Audit Validator Utility
/// Validates identity proofing (KBA + Credential Analysis), AV session recording,
/// digital certificate integrity, and state statutory fee caps.

class RonComplianceResult {
  final int complianceScore;
  final String status;
  final bool isKbaCompliant;
  final bool isCredentialAnalysisCompliant;
  final bool isAvRecordingCompliant;
  final bool isDigitalCertificateCompliant;
  final bool isFeeCompliant;
  final List<String> warnings;

  RonComplianceResult({
    required this.complianceScore,
    required this.status,
    required this.isKbaCompliant,
    required this.isCredentialAnalysisCompliant,
    required this.isAvRecordingCompliant,
    required this.isDigitalCertificateCompliant,
    required this.isFeeCompliant,
    required this.warnings,
  });
}

RonComplianceResult calculateRonComplianceScore({
  required bool isKbaVerified,
  required bool isCredentialAnalysisPassed,
  required bool isAudioVideoRecorded,
  required bool isDigitalCertificateValid,
  required double stateFeeChargedUsd,
  double maxStateFeeAllowedUsd = 25.0,
}) {
  int score = 100;
  final List<String> warnings = [];

  if (!isKbaVerified) {
    score -= 30;
    warnings.add('Knowledge-Based Authentication (KBA) passed identity check is missing.');
  }

  if (!isCredentialAnalysisPassed) {
    score -= 30;
    warnings.add('Government ID forensic credential analysis failed or not performed.');
  }

  if (!isAudioVideoRecorded) {
    score -= 25;
    warnings.add('Tamper-evident audio-video session recording must be retained.');
  }

  if (!isDigitalCertificateValid) {
    score -= 15;
    warnings.add('X.509 Digital Signer Certificate is expired or unverified.');
  }

  final bool isFeeCompliant = stateFeeChargedUsd <= maxStateFeeAllowedUsd;
  if (!isFeeCompliant) {
    score -= 10;
    warnings.add('Statutory fee charged (\$${stateFeeChargedUsd.toStringAsFixed(2)}) exceeds maximum state threshold (\$${maxStateFeeAllowedUsd.toStringAsFixed(2)}).');
  }

  final int finalScore = score < 0 ? 0 : (score > 100 ? 100 : score);
  final String status = finalScore >= 90 ? 'COMPLIANT' : 'NON_COMPLIANT';

  return RonComplianceResult(
    complianceScore: finalScore,
    status: status,
    isKbaCompliant: isKbaVerified,
    isCredentialAnalysisCompliant: isCredentialAnalysisPassed,
    isAvRecordingCompliant: isAudioVideoRecorded,
    isDigitalCertificateCompliant: isDigitalCertificateValid,
    isFeeCompliant: isFeeCompliant,
    warnings: warnings,
  );
}
