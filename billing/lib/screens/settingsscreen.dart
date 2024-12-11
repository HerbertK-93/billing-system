import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.grey[300], // Light grey color
      ),
      body: const Center(
        child: Text(
          'Settings Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
