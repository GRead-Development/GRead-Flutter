import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _user = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    developer.log('LoginScreen initialized', name: 'LoginScreen');
  }

  @override
  void dispose() {
    _user.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    developer.log(
      'LoginScreen build - Loading: $_loading, Error: $_errorMessage',
      name: 'LoginScreen',
    );
    final auth = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('GRead Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to GRead',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _user,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pass,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final username = _user.text.trim();
                        final password = _pass.text;

                        developer.log(
                          'Login button pressed - Username: $username, Password length: ${password.length}',
                          name: 'LoginScreen',
                        );

                        if (username.isEmpty || password.isEmpty) {
                          developer.log(
                            'Login validation failed - Username empty: ${username.isEmpty}, Password empty: ${password.isEmpty}',
                            name: 'LoginScreen',
                          );
                          setState(() => _errorMessage = 'Please enter username and password');
                          return;
                        }

                        setState(() {
                          _loading = true;
                          _errorMessage = null;
                        });
                        developer.log('Login loading state set to true', name: 'LoginScreen');

                        try {
                          developer.log('Calling auth.login()', name: 'LoginScreen');
                          final ok = await auth.login(username, password);

                          developer.log(
                            'auth.login() returned: $ok',
                            name: 'LoginScreen',
                          );

                          if (mounted) {
                            developer.log('Widget mounted after login attempt', name: 'LoginScreen');
                            setState(() => _loading = false);

                            if (ok) {
                              developer.log('Login successful, rebuilding app', name: 'LoginScreen');
                              // The AppRoot will automatically show HomeScreen due to the watch on loggedIn
                              // No need to navigate manually
                            } else {
                              developer.log('Login returned false', name: 'LoginScreen');
                              setState(() => _errorMessage = 'Login failed - check username and password');
                            }
                          } else {
                            developer.log('Widget not mounted after login attempt', name: 'LoginScreen');
                          }
                        } catch (e, stackTrace) {
                          developer.log(
                            'Login exception: $e',
                            name: 'LoginScreen',
                            error: e,
                            stackTrace: stackTrace,
                          );

                          if (mounted) {
                            setState(() {
                              _loading = false;
                              _errorMessage = 'Error: ${e.toString()}';
                            });
                          }
                        }
                      },
                      child: const Text('Login'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
