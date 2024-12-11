import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: Colors.grey[300], // Light grey color
      ),
      body: const Center(
        child: Text(
          'Reports Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
