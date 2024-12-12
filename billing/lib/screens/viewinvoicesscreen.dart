import 'package:flutter/material.dart';

class ViewInvoicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Invoices'),
        backgroundColor: Colors.grey[300],
      ),
      body: const Center(
        child: Text(
          'List of Invoices',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
