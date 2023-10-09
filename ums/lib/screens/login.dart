import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:orders/orders.dart';

class Login extends StatefulWidget {
  const Login({
    super.key,
    required this.storage,
  });

  final FlutterSecureStorage storage;

  @override
  State<Login> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  final _form = GlobalKey<FormState>();
  dynamic _userEmail, _userPassword;
  FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isLoading = false;

  @override
  void initState() {
    _storage = widget.storage;
    super.initState();
  }

  void _signin() async {
    _form.currentState!.save();

    try {
      setState(() {
        _isLoading = true;
      });
      final Uri url = Uri.https('ums.qa15.indopus.in', '/auth-verify');
      final encodedCredsBytes = utf8.encode('$_userEmail:$_userPassword');
      final encodedCreds = base64.encode(encodedCredsBytes);

      var response = await http.post(url, headers: {
        'Source': 'BizongoApp',
        'IdentityProvider': 'password',
        'Authorization': 'Basic $encodedCreds',
      });
      var responseBody = json.decode(response.body);
      if (response.statusCode == 400) {
        throw Exception('Invalid cred!');
      }
      await _storage.write(key: 'jwt', value: responseBody['jwt_token']);

      if (!context.mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => Orders(
            storage: _storage,
          ),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );
    }
  }

  @override
  Widget build(context) {
    Widget content = Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              margin: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(
                    16,
                  ),
                  child: Form(
                    key: _form,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Email Id',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          onSaved: (value) {
                            if (value != null) {
                              _userEmail = value;
                            }
                          },
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
                          obscureText: true,
                          onSaved: (value) {
                            _userPassword = value!;
                          },
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        ElevatedButton(
                          onPressed: _signin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                          child: const Text('Login'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: content,
    );
  }
}
