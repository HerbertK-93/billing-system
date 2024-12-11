import 'package:billing/screens/designingscreen.dart';
import 'package:billing/screens/fabricationscreen.dart';
import 'package:billing/screens/generalscreen.dart';
import 'package:billing/screens/installationscreen.dart';
import 'package:billing/screens/machiningscreen.dart';
import 'package:billing/screens/maintenancescreen.dart';
import 'package:billing/screens/supplyscreen.dart';
import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          buildCategoryItem(
              context, 'Supply', Icons.arrow_forward_ios, SupplyScreen()),
          buildCategoryItem(
              context, 'Machining', Icons.arrow_forward_ios, MachiningScreen()),
          buildCategoryItem(context, 'Maintenance', Icons.arrow_forward_ios,
              MaintenanceScreen()),
          buildCategoryItem(context, 'Fabrication', Icons.arrow_forward_ios,
              FabricationScreen()),
          buildCategoryItem(context, 'Installation', Icons.arrow_forward_ios,
              InstallationScreen()),
          buildCategoryItem(
              context, 'Designing', Icons.arrow_forward_ios, DesigningScreen()),
          buildCategoryItem(
              context, 'General', Icons.arrow_forward_ios, GeneralScreen()),
        ],
      ),
    );
  }

  Widget buildCategoryItem(
      BuildContext context, String title, IconData iconData, Widget screen) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[300], // Grey background
        borderRadius: BorderRadius.circular(10.0), // Rounded edges
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 10), // Reduced height
        title: Text(
          title,
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        trailing: Icon(iconData, color: Colors.black),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
      ),
    );
  }
}
