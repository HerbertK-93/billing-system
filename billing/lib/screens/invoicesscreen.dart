import 'package:flutter/material.dart';

class InvoicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        backgroundColor: Colors.grey[300], // Light grey color
      ),
      body: const Center(
        child: Text(
          'Invoices Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
