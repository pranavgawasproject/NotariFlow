class MileageTaxCalculator {
  /// IRS Standard Mileage Rates (USD per mile)
  static const Map<int, double> _irsRates = {
    2022: 0.585, // First half 2022
    2023: 0.655,
    2024: 0.670,
    2025: 0.670, // Assuming same for now
  };

  /// Retrieves the standard rate for the given year.
  static double getRateForYear(int year) {
    if (!_irsRates.containsKey(year)) {
      throw ArgumentError('IRS rate for year $year is not supported.');
    }
    return _irsRates[year]!;
  }

  /// Calculates the tax deduction for a single trip.
  static double calculateTripDeduction(double miles, {int year = 2024}) {
    if (miles < 0) {
      throw ArgumentError('Miles cannot be negative.');
    }
    double rate = getRateForYear(year);
    return double.parse((miles * rate).toStringAsFixed(2));
  }

  /// Calculates the total tax deduction for multiple trips.
  static double calculateTotalDeduction(List<double> tripMiles, {int year = 2024}) {
    double totalDeduction = 0.0;
    for (var miles in tripMiles) {
      totalDeduction += calculateTripDeduction(miles, year: year);
    }
    return double.parse(totalDeduction.toStringAsFixed(2));
  }
}
