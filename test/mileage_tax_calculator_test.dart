import 'package:flutter_test/flutter_test.dart';
import '../lib/utils/mileage_tax_calculator.dart';

void main() {
  group('MileageTaxCalculator Tests', () {
    test('Calculates correct deduction for 2024', () {
      final deduction = MileageTaxCalculator.calculateTripDeduction(100.0, year: 2024);
      expect(deduction, 67.0);
    });

    test('Calculates correct deduction for 2023', () {
      final deduction = MileageTaxCalculator.calculateTripDeduction(100.0, year: 2023);
      expect(deduction, 65.50);
    });

    test('Calculates total deduction for multiple trips', () {
      final deduction = MileageTaxCalculator.calculateTotalDeduction([10.0, 20.0, 30.0], year: 2024);
      // 60.0 * 0.67 = 40.20
      expect(deduction, 40.20);
    });

    test('Throws error for unsupported year', () {
      expect(
        () => MileageTaxCalculator.calculateTripDeduction(100.0, year: 1999),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Throws error for negative miles', () {
      expect(
        () => MileageTaxCalculator.calculateTripDeduction(-10.0, year: 2024),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
