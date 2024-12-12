import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detailed Reports',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildDetailTile(
                    title: 'Monthly Sales Report',
                    icon: Icons.analytics,
                    onTap: () {
                      // Handle report viewing
                    },
                  ),
                  _buildDetailTile(
                    title: 'Customer Overview',
                    icon: Icons.people,
                    onTap: () {
                      // Handle report viewing
                    },
                  ),
                  _buildDetailTile(
                    title: 'Product Performance',
                    icon: Icons.shopping_basket,
                    onTap: () {
                      // Handle report viewing
                    },
                  ),
                  _buildDetailTile(
                    title: 'Expense Breakdown',
                    icon: Icons.pie_chart,
                    onTap: () {
                      // Handle report viewing
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 2.0,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Icon(icon, color: Colors.black, size: 25),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
