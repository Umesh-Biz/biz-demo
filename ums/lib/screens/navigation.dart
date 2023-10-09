import 'package:deliveries/deliveries.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:orders/orders.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key, required this.storage});

  final FlutterSecureStorage storage;

  @override
  State<Navigation> createState() {
    return _NavigationState();
  }
}

class _NavigationState extends State<Navigation> {
  int _activeTabIndex = 0;
  FlutterSecureStorage _storage = const FlutterSecureStorage();

  void _onNavigate(int index) {
    setState(() {
      _activeTabIndex = index;
      if (index == 0) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (ctx) => Orders(
              storage: _storage,
            ),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (ctx) => Deliveries(
              storage: _storage,
            ),
          ),
        );
      }
    });
  }

  @override
  void initState() {
    _storage = widget.storage;
    super.initState();
  }

  @override
  Widget build(context) {
    return BottomNavigationBar(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      onTap: _onNavigate,
      currentIndex: _activeTabIndex,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_basket),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fire_truck),
          label: 'Deliveries',
        ),
      ],
    );
  }
}
