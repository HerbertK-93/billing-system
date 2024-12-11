import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profilescreen.dart'; // Import the ProfileScreen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String firstName = '';
  String lastName = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          firstName = userDoc['firstName'];
          lastName = userDoc['lastName'];
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300], // Light grey color
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "INNOVATION CONSORTIUM BILLING",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black, // Text color
              ),
            ),
            Row(
              children: [
                if (isLoading)
                  const CircularProgressIndicator()
                else
                  Text(
                    "Welcome, $firstName $lastName",
                    style: const TextStyle(color: Colors.black), // Text color
                  ),
                const SizedBox(width: 8), // Spacing between text and icon
                GestureDetector(
                  onTap: () {
                    // Navigate to Profile Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileScreen()),
                    );
                  },
                  child: const Icon(
                    Icons.person,
                    color: Colors.black, // Icon color
                  ),
                ),
              ],
            ),
          ],
        ),
        automaticallyImplyLeading: false, // Removes the back arrow
      ),
      body: const Center(
        child: Text(
          "Welcome to Innovation Consortium Billing System!",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
