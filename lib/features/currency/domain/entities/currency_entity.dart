import 'package:equatable/equatable.dart';

class CurrencyEntity extends Equatable {
  final int id;
  final String code;
  final String symbol;
  final int noOfDecimal;
  final String exchangeRate;
  final String symbolPosition;
  final String thousandsSeparator;
  final String decimalSeparator;
  final int systemReserve;
  final int status;
  final dynamic createdById;
  final String createdAt;
  final String updatedAt;
  final dynamic deletedAt;

  const CurrencyEntity({
    required this.id,
    required this.code,
    required this.symbol,
    required this.noOfDecimal,
    required this.exchangeRate,
    required this.symbolPosition,
    required this.thousandsSeparator,
    required this.decimalSeparator,
    required this.systemReserve,
    required this.status,
    required this.createdById,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  @override
  List<Object?> get props => [
    id,
    code,
    symbol,
    noOfDecimal,
    exchangeRate,
    symbolPosition,
    thousandsSeparator,
    decimalSeparator,
    systemReserve,
    status,
    createdById,
    createdAt,
    updatedAt,
    deletedAt,
  ];

  // Helper method to format price
  String formatPrice(double price) {
    final exchangeRateValue = double.tryParse(exchangeRate) ?? 1.0;
    final convertedPrice = price * exchangeRateValue;

    // Format the number based on decimal places
    final formattedNumber = convertedPrice.toStringAsFixed(noOfDecimal);

    // Add thousands separator if needed
    String finalNumber = formattedNumber;
    if (thousandsSeparator == 'comma') {
      final parts = formattedNumber.split('.');
      if (parts[0].length > 3) {
        final integerPart = parts[0];
        final formattedInteger = integerPart.replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
        finalNumber = '${formattedInteger}.${parts[1]}';
      }
    }

    // Add symbol based on position
    if (symbolPosition == 'before_price') {
      return '$symbol$finalNumber';
    } else {
      return '$finalNumber$symbol';
    }
  }

  // Helper method to get exchange rate as double
  double get exchangeRateAsDouble => double.tryParse(exchangeRate) ?? 1.0;
}
