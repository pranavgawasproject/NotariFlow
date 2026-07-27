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
}
