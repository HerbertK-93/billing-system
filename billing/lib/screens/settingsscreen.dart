import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // General Settings Section
            const Divider(thickness: 1, color: Colors.grey),
            ExpansionTile(
              leading: const Icon(Icons.settings, color: Colors.black),
              title: const Text('General Settings'),
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Language'),
                  onTap: () {
                    // Navigate to language settings
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: const Text('Theme'),
                  onTap: () {
                    // Navigate to theme settings
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.date_range),
                  title: const Text('Date/Time Format'),
                  onTap: () {
                    // Navigate to date/time settings
                  },
                ),
              ],
            ),
            const Divider(thickness: 1, color: Colors.grey),
            // User Management Section
            ExpansionTile(
              leading: const Icon(Icons.person, color: Colors.black),
              title: const Text('User Management'),
              children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit Profile'),
                  onTap: () {
                    // Navigate to edit profile
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Change Password'),
                  onTap: () {
                    // Navigate to change password
                  },
                ),
              ],
            ),
            const Divider(thickness: 1, color: Colors.grey),
            // Billing Preferences Section
            ExpansionTile(
              leading: const Icon(Icons.receipt_long, color: Colors.black),
              title: const Text('Billing Preferences'),
              children: [
                ListTile(
                  leading: const Icon(Icons.insert_drive_file),
                  title: const Text('Invoice Template'),
                  onTap: () {
                    // Navigate to invoice template
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.money),
                  title: const Text('Tax Settings'),
                  onTap: () {
                    // Navigate to tax settings
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.payment),
                  title: const Text('Payment Gateways'),
                  onTap: () {
                    // Navigate to payment gateways
                  },
                ),
              ],
            ),
            const Divider(thickness: 1, color: Colors.grey),
            // Notifications Section
            ExpansionTile(
              leading: const Icon(Icons.notifications, color: Colors.black),
              title: const Text('Notifications'),
              children: [
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Email Notifications'),
                  onTap: () {
                    // Navigate to email notifications
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sms),
                  title: const Text('SMS Notifications'),
                  onTap: () {
                    // Navigate to SMS notifications
                  },
                ),
              ],
            ),
            const Divider(thickness: 1, color: Colors.grey),
            // Data Management Section
            ExpansionTile(
              leading: const Icon(Icons.storage, color: Colors.black),
              title: const Text('Data Management'),
              children: [
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Export Data'),
                  onTap: () {
                    // Navigate to export data
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.restore),
                  title: const Text('Backup & Restore'),
                  onTap: () {
                    // Navigate to backup & restore
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Save Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Save settings logic
                },
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
