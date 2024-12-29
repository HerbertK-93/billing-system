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
            const SizedBox(
                height: 16), // This space is kept for layout adjustment
            // General Settings Section
            ExpansionTile(
              leading: const Icon(Icons.settings, color: Colors.black),
              title: const Text('General Settings'),
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Language'),
                  onTap: () {
                    // Navigate to language settings
                    Navigator.pushNamed(context, '/languageSettings');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: const Text('Theme'),
                  onTap: () {
                    // Navigate to theme settings
                    Navigator.pushNamed(context, '/themeSettings');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.date_range),
                  title: const Text('Date/Time Format'),
                  onTap: () {
                    // Navigate to date/time settings
                    Navigator.pushNamed(context, '/dateTimeSettings');
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
                    // Navigate to edit profile screen
                    Navigator.pushNamed(context, '/editProfile');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Change Password'),
                  onTap: () {
                    // Navigate to change password screen
                    Navigator.pushNamed(context, '/changePassword');
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
                    // Navigate to invoice template settings
                    Navigator.pushNamed(context, '/invoiceTemplate');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.money),
                  title: const Text('Tax Settings'),
                  onTap: () {
                    // Navigate to tax settings
                    Navigator.pushNamed(context, '/taxSettings');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.payment),
                  title: const Text('Payment Gateways'),
                  onTap: () {
                    // Navigate to payment gateways settings
                    Navigator.pushNamed(context, '/paymentGateways');
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
                    // Navigate to email notifications settings
                    Navigator.pushNamed(context, '/emailNotifications');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sms),
                  title: const Text('SMS Notifications'),
                  onTap: () {
                    // Navigate to SMS notifications settings
                    Navigator.pushNamed(context, '/smsNotifications');
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
                    // Navigate to export data functionality
                    Navigator.pushNamed(context, '/exportData');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.restore),
                  title: const Text('Backup & Restore'),
                  onTap: () {
                    // Navigate to backup & restore functionality
                    Navigator.pushNamed(context, '/backupRestore');
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Save Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: const Color.fromARGB(
                      255, 199, 184, 51), // Yellow background color
                ),
                onPressed: () {
                  // Implement save settings functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Settings saved successfully!')),
                  );
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
