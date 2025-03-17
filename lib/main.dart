import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shaadisetu/pages/dashboard.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'pages/no_internet.dart';

void main() {
  runApp(const ShaadiSetuApp());
}

class ShaadiSetuApp extends StatefulWidget {
  const ShaadiSetuApp({super.key});

  @override
  State<ShaadiSetuApp> createState() => _ShaadiSetuAppState();
}

class _ShaadiSetuAppState extends State<ShaadiSetuApp> {
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkFullConnectivity();
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      setState(() {
        _isConnected = results.isNotEmpty &&
            results.any((result) => result != ConnectivityResult.none);
      });
      if (_isConnected) {
        _verifyInternet();
      }
    });
  }

  Future<void> _checkFullConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    final hasNetwork = result != ConnectivityResult.none;
    if (hasNetwork) {
      await _verifyInternet();
    } else {
      setState(() {
        _isConnected = false;
      });
    }
  }

  Future<void> _verifyInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      setState(() {
        _isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      });
    } on SocketException catch (_) {
      setState(() {
        _isConnected = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShaadiSetu',
      debugShowCheckedModeBanner: false,
      home: _isConnected
          ? const Dashboard()
          : NoInternetScreen(onRetry: _checkFullConnectivity),
    );
  }
}
