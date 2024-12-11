import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: Colors.grey[300], // Light grey color
      ),
      body: const Center(
        child: Text(
          'History Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
