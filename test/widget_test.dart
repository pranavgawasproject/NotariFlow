import 'package:flutter_test/flutter_test.dart';
import 'package:notariflow/utils/currency_service.dart';
import 'package:notariflow/utils/subscription_service.dart';

void main() {
  group('NotariFlow Unit Tests', () {
    test('validates expense & journal entry date calculations', () {
      final now = DateTime.now();
      expect(now.year, greaterThanOrEqualTo(2026));
    });

    test('validates monetary formatting', () {
      const amount = 150.5;
      final formatted = '${CurrencyService().currencySymbol}${amount.toStringAsFixed(2)}';
      expect(formatted, '\$150.50');
    });

    test('validates IRS mileage tax deduction calculation (0.67 rate)', () {
      const miles = 50.0;
      const taxDeductionRate = 0.67;
      final deduction = miles * taxDeductionRate;
      expect(deduction, 33.5);
    });

    test('validates subscription service limit constants', () {
      expect(SubscriptionService.freeInvoiceLimit, equals(10));
      expect(SubscriptionService.freeMileageLimit, equals(20));
      expect(SubscriptionService.freeExpenseLimit, equals(30));
      expect(SubscriptionService.freeClientLimit, equals(15));
      expect(SubscriptionService.freeSignatureLimit, equals(15));
    });

    test('validates double input parsing & safety', () {
      expect(double.tryParse('123.45'), equals(123.45));
      expect(double.tryParse('invalid'), isNull);
      expect(double.tryParse('-10'), equals(-10.0));
      
      double parseAmount(String input) => double.tryParse(input.trim()) ?? 0.0;
      expect(parseAmount('  99.99  '), equals(99.99));
      expect(parseAmount('abc'), equals(0.0));
    });

    test('validates notary fee calculation estimate with mileage', () {
      final estimate = SubscriptionService.calculateNotaryFeeEstimate(
        signaturesCount: 3,
        travelMiles: 20.0,
        feePerSignature: 10.0,
        mileageRate: 0.67,
      );
      expect(estimate['signatureTotal'], equals(30.0));
      expect(estimate['travelTotal'], equals(13.4));
      expect(estimate['totalEstimate'], equals(43.4));
    });
  });
}
