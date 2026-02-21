import 'package:flutter/material.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/order_entity.dart';

class OrderDetailsInfo extends StatelessWidget {
  final OrderEntity order;

  const OrderDetailsInfo({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Order Number', '#${order.orderNumber}', colors),
            _buildInfoRow('Order Date', _formatDate(order.createdAt), colors),
            _buildInfoRow(
              'Payment Method',
              order.paymentMethod
                  .toUpperCase()
                  .replaceAll('COD', 'Office Payment')
                  .replaceAll('BANK_TRANSFER', 'Bank Transfer')
                  .replaceAll('BANK', 'Bank Transfer')
                  .replaceAll('PDO_ZAMBIA', 'DPO Zambia')
                  .replaceAll('PAYFAST', 'Payfast')
                  .replaceAll('PESE', 'PesePay')
                  .replaceAll('OFFICE_PAYMENT', 'Office Payment'),
              colors,
            ),
            _buildInfoRow('Payment Status', order.paymentStatus, colors),
            if (order.deliveryDescription.isNotEmpty)
              _buildInfoRow('Delivery', order.deliveryDescription, colors),
            if (order.note != null && order.note!.isNotEmpty)
              _buildInfoRow('Note', order.note!, colors),
            const Divider(height: 24),
            _buildAmountSection(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSection(ColorScheme colors) {
    final s = order.summary;
    double fx(double v) => v * order.exchangeRate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Summary',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        _buildAmountRow(
          'Subtotal',
          s != null ? fx(s.subtotal) : order.amount * order.exchangeRate,
          colors,
        ),
        if ((s?.pointsUsed ?? order.pointsAmount) > 0)
          _buildAmountRow(
            'Points Used',
            s != null
                ? fx(s.pointsUsed)
                : order.pointsAmount * order.exchangeRate,
            colors,
            isDiscount: true,
          ),
        if ((s?.walletUsed ?? 0) > 0)
          _buildAmountRow(
            'Wallet Used',
            s != null ? fx(s.walletUsed) : 0,
            colors,
            isDiscount: true,
          ),
        if ((s?.tax ?? order.taxTotal) > 0)
          _buildAmountRow(
            'Tax',
            s != null ? fx(s.tax) : order.taxTotal,
            colors,
          ),
        if ((s?.shipping ?? order.shippingTotal) > 0)
          _buildAmountRow(
            'Shipping',
            s != null ? fx(s.shipping) : 10 * order.exchangeRate,
            colors,
          ),
        if ((s?.delivery ?? order.deliveryPrice) > 0)
          _buildAmountRow(
            'Delivery Fee',
            s != null
                ? fx(s.delivery)
                : order.deliveryPrice * order.exchangeRate,
            colors,
          ),
        if ((s?.fastShipping ?? order.fastShippingTotal ?? 0) > 0)
          _buildAmountRow(
            'Fast Shipping Fee',
            s != null
                ? fx(s.fastShipping)
                : (order.fastShippingTotal ?? 0) * order.exchangeRate,
            colors,
          ),
        // if ((s?.totalDiscounts ?? order.couponTotalDiscount) > 0)
        //   _buildAmountRow(
        //     'Grand Total',
        //     (s != null
        //         ? fx(s.grandTotal)
        //         : s?.grandTotal ?? 0 * order.exchangeRate),
        //     colors,
        //     isDiscount: true,
        //   ),
        const Divider(height: 16),
        _buildAmountRow(
          'Grand Total',
          s != null ? fx(s.finalTotal) : order.total * order.exchangeRate,
          colors,
          isTotal: true,
        ),
        const SizedBox(height: 4),
        // if (s?.amountToPay != 0.0)
        //   _buildAmountRow(
        //     'Amount To Pay',
        //     fx(s?.amountToPay ?? 0.0),
        //     colors,
        //     isTotal: true,
        //   ),
      ],
    );
  }

  Widget _buildAmountRow(
    String label,
    double amount,
    ColorScheme colors, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    final amountColor = isDiscount ? colors.error : colors.onSurface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              color:
                  isTotal
                      ? colors.onSurface
                      : colors.onSurface.withOpacity(0.6),
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Text(
            '${isDiscount ? '-' : ''}${order.currencySymbol}${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              color: amountColor,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
