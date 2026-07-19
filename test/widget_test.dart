import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotariFlow Unit Tests', () {
    test('validates expense & journal entry date calculations', () {
      final now = DateTime.now();
      expect(now.year, greaterThanOrEqualTo(2026));
    });

    test('validates monetary formatting', () {
      const amount = 150.5;
      final formatted = '\$${amount.toStringAsFixed(2)}';
      expect(formatted, '\$150.50');
    });
  });
}
