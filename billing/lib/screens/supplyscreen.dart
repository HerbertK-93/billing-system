import 'package:flutter/material.dart';

class SupplyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Supply'),
        backgroundColor: Colors.grey[300], // Light grey color
      ),
      body: const Center(
        child: Text('Supply Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
