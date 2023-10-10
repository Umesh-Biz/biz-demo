import 'package:flutter/material.dart';
import 'package:orders/models/delivery.dart';

class DeliveryCard extends StatelessWidget {
  const DeliveryCard({
    super.key,
    required this.delivery,
  });

  final Delivery delivery;

  @override
  Widget build(context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 0,
        vertical: 8,
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [Text(delivery.deliveryId)],
        ),
      ),
    );
  }
}
