import '../../models/order.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final currencyFormatter = NumberFormat.currency(locale: 'en_IN', name: '₹');

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.orderDetails,
  });

  final Order orderDetails;

  @override
  Widget build(BuildContext context) {
    final convertedAmount =
        currencyFormatter.format(double.parse(orderDetails.amount));

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 0,
        vertical: 8,
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderDetails.number,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  orderDetails.createdBy,
                ),
              ],
            ),
            Text(convertedAmount),
          ],
        ),
      ),
    );
  }
}
