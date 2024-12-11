import 'package:billing/screens/categoriesscreen.dart';
import 'package:billing/screens/dashboardscreen.dart';
import 'package:billing/screens/historyscreen.dart';
import 'package:billing/screens/invoicesscreen.dart';
import 'package:billing/screens/reportsscreen.dart';
import 'package:billing/screens/settingsscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profilescreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String firstName = '';
  String lastName = '';
  bool isLoading = true;
  int selectedIndex = 0;
  final PageController _pageController = PageController();

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

  Widget buildDashboardItem(String title, IconData iconData, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedIndex = index;
          _pageController.jumpToPage(index);
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: selectedIndex == index
              ? Colors.blueAccent.withOpacity(0.2)
              : Colors.transparent,
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          leading: Icon(iconData, color: Colors.black),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black, // Black color for all text
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "INNOVATION CONSORTIUM BILLING",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Row(
              children: [
                if (isLoading)
                  const CircularProgressIndicator()
                else
                  Text(
                    "Welcome, $firstName $lastName",
                    style: const TextStyle(color: Colors.white),
                  ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileScreen()),
                    );
                  },
                  child: const Icon(Icons.person, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: Row(
        children: [
          Container(
            width: 250, // Increased width for the sidebar
            color: Color.fromARGB(255, 231, 230, 230),
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const SizedBox(height: 30),
                buildDashboardItem("Dashboard", Icons.dashboard, 0),
                buildDashboardItem("Categories", Icons.category, 1),
                buildDashboardItem("Invoices", Icons.receipt, 2),
                buildDashboardItem("Settings", Icons.settings, 3),
                buildDashboardItem("History", Icons.history, 4),
                buildDashboardItem("Reports", Icons.bar_chart, 5),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              children: [
                DashboardScreen(),
                CategoriesScreen(),
                InvoicesScreen(),
                SettingsScreen(),
                HistoryScreen(),
                ReportsScreen(),
              ].map((screen) => screen).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
