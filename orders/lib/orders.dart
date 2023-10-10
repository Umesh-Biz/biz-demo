library orders;

/// A Calculator.
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:orders/screens/po_details.dart';
import 'package:orders/widgets/order_card.dart';
import 'package:ums/screens/navigation.dart';
import '../models/order.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

enum PersonaType { buyer, seller }

class Orders extends StatefulWidget {
  const Orders({
    super.key,
    required this.storage,
  });

  final FlutterSecureStorage storage;

  @override
  State<Orders> createState() {
    return _OrdersState();
  }
}

class _OrdersState extends State<Orders> with TickerProviderStateMixin {
  List<Order> _ordersList = [];
  bool _isLoading = false;
  PersonaType _personaType = PersonaType.buyer;
  // int _activeTabIndex = 0;
  FlutterSecureStorage _storage = const FlutterSecureStorage();
  late final TabController _tabController;

  void _fetchOrders() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final jwt = await _storage.read(key: 'jwt');
      final Map<String, dynamic> headers = {
        'size': '10',
      };

      if (_personaType == PersonaType.buyer) {
        // 'requestType': 'TO',
        // 'buyerId': '20002',
        headers['requestType'] = 'TO';
        headers['buyerId'] = '20002';
        headers['page'] = '1';
      } else {
        headers['requestType'] = 'FROM';
        headers['supplierId'] = '21898';
        headers['page'] = '0';
      }

      final Uri url =
          Uri.https('poservice.qa16.indopus.in', '/purchase-orders', headers);

      final response =
          await http.get(url, headers: {'Authorization': 'Bearer $jwt'});

      dynamic ordersData = jsonDecode(response.body);
      List<Order> orders = (ordersData['pos'] as List)
          .map(
              (order) => Order.fromJSON(order, ordersData['additionalDataMap']))
          .toList();

      setState(() {
        _ordersList = orders;
        _isLoading = false;
      });
    } catch (error) {
      if (context.mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _storage = widget.storage;
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: 0,
    );
  }

  void _onChangePersonaType(int index) {
    setState(() {
      // _activeTabIndex = index;
      // _ordersList = [];
      if (index == 0) {
        _personaType = PersonaType.buyer;
      } else {
        _personaType = PersonaType.seller;
      }
    });

    _fetchOrders();
  }

  void _viewOrdersDetails(Order order) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => PoDetails(
          order: order,
          storage: _storage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('No Content!'),
    );

    if (_ordersList.isNotEmpty) {
      content = ListView.builder(
        itemCount: _ordersList.length,
        itemBuilder: (ctx, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
          child: InkWell(
            onTap: () {
              _viewOrdersDetails(_ordersList[index]);
            },
            child: OrderCard(orderDetails: _ordersList[index]),
          ),
        ),
      );
    }

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Next'),
        bottom: TabBar(
          onTap: _onChangePersonaType,
          controller: _tabController,
          tabs: const <Widget>[
            Tab(
              icon: Icon(Icons.file_copy),
              text: 'Purchase Orders',
            ),
            Tab(
              icon: Icon(Icons.file_copy),
              text: 'Sales Orders',
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [content, content],
      ),
      // Center(
      //   child: Padding(
      //     padding: const EdgeInsets.all(16),
      //     child: content,
      //   ),
      // ),
      bottomNavigationBar: Navigation(
        storage: _storage,
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      //   onTap: _onChangePersonaType,
      //   currentIndex: _activeTabIndex,
      //   items: const [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.file_copy),
      //       label: 'Purchase Orders',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.file_copy),
      //       label: 'Sales Orders',
      //     ),
      //   ],
      // ),
    );
  }
}
