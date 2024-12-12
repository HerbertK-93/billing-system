import 'package:billing/screens/viewinvoicesscreen.dart';
import 'package:flutter/material.dart';

class InvoicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          elevation: 5,
          color: Colors.white, // Light background for the card
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewInvoicesScreen()),
              );
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => {}, // Hover state handled separately if needed
              onExit: (_) => {}, // Placeholder for leaving hover state
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 200, vertical: 100),
                child: Text(
                  'View Invoices',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Default color
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
