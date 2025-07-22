import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(PimpleLockApp());
}

class PimpleLockApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Lock',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: AppLockScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppLockScreen extends StatefulWidget {
  @override
  _AppLockScreenState createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _authenticated = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
  }

  Future<void> _checkBiometricSupport() async {
    bool canCheckBiometrics = await auth.canCheckBiometrics;
    bool isSupported = await auth.isDeviceSupported();

    if (canCheckBiometrics && isSupported) {
      _authenticate();
    } else {
      setState(() {
        _error = 'Biometric authentication is not available on this device.';
      });
    }
  }

  Future<void> _authenticate() async {
    try {
      final bool authenticated = await auth.authenticate(
        localizedReason: 'Please scan your fingerprint to unlock',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      if (authenticated) {
        setState(() {
          _authenticated = true;
        });
      } else {
        setState(() {
          _error = 'Authentication failed. Try again.';
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        _error = 'Error: ${e.message}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_authenticated) return HomeScreen();

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fingerprint, size: 60, color: Colors.indigo),
              SizedBox(height: 20),
              Text(
                'Authenticate to access Smart Lock',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (_error.isNotEmpty) ...[
                SizedBox(height: 15),
                Text(
                  _error,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
              SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _authenticate,
                icon: Icon(Icons.lock_open),
                label: Text('Authenticate Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
