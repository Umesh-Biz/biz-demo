import 'dart:convert';

import 'package:deliveries_mfe/screens/delivery_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:orders/models/delivery.dart';
import 'package:orders/models/order.dart';
import 'package:http/http.dart' as http;
import 'package:orders/widgets/delivery_card.dart';

const storage = FlutterSecureStorage();

class PoDetails extends StatefulWidget {
  const PoDetails({
    super.key,
    required this.order,
    required this.storage,
  });

  final Order order;
  final FlutterSecureStorage storage;

  @override
  State<PoDetails> createState() {
    return _PoDetailsState();
  }
}

class _PoDetailsState extends State<PoDetails> {
  bool _isLoading = false;
  FlutterSecureStorage? _storage;
  List<Delivery> _deliveries = [];

  void _fetchDeliveries() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final jwt = await _storage!.read(key: 'jwt');
      final Map<String, dynamic> queryParams = {
        'purchaseOrderId': widget.order.orderId.toString(),
        'page': '0',
        'size': '10',
        'type': 'BUYER'
      };

      final Uri url = Uri.https(
        'schedulingservice.qa16.indopus.in',
        '/scheduling-service/deliveries',
        queryParams,
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $jwt',
        },
      );

      final decodedResponse = jsonDecode(response.body);
      if (decodedResponse!['status']!.toString() == '404') {
        throw decodedResponse['message'] ?? 'Something went wrong!';
      }

      List<Delivery> deliveries =
          (decodedResponse['data']!['deliveries'] as List)
              .map((delivery) => Delivery.fromJSON(delivery))
              .toList();

      setState(() {
        _isLoading = false;
        _deliveries = deliveries;
      });
    } catch (error) {
      if (context.mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.toString(),
            ),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    _storage = widget.storage;
    super.initState();
    _fetchDeliveries();
  }

  @override
  Widget build(context) {
    String orderNumber = widget.order.number;
    Widget content = const Center(child: Text('Something went wrong!'));

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_deliveries.isNotEmpty) {
      content = ListView.builder(
        itemCount: _deliveries.length,
        itemBuilder: (ctx, index) => Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 6,
          ),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => DeliveryDetails(
                    delivery: _deliveries[index],
                  ),
                ),
              );
            },
            child: DeliveryCard(
              delivery: _deliveries[index],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(orderNumber),
      ),
      body: content,
    );
  }
}
