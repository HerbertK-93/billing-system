import 'package:flutter/material.dart';

class FabricationScreen extends StatelessWidget {
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
        title: const Text('Fabrication'),
        backgroundColor: Colors.grey[300], // Light grey color
      ),
      body: const Center(
        child: Text('Fabrication Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
