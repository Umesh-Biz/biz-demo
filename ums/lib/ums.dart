library ums;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:orders/orders.dart';
import 'package:flutter/material.dart';
import 'package:ums/screens/login.dart';

const storage = FlutterSecureStorage();

class Auth extends StatelessWidget {
  const Auth({super.key});

  Future<String> get isJWTPresent async {
    // await storage.write(key: 'jwt', value: "something");
    // await storage.delete(key: 'jwt');
    final jwtToken = await storage.read(key: 'jwt');

    if (jwtToken == null) {
      return "";
    }

    return jwtToken;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: isJWTPresent,
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        if (snapshot.data!.isEmpty) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.primary,
            body: const Login(
              storage: storage,
            ),
          );
        }

        return const Orders(
          storage: storage,
        );
      },
    );
  }
}
