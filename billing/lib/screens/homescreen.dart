import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'categoriesscreen.dart';
import 'dashboardscreen.dart';
import 'invoicesscreen.dart';
import 'reportsscreen.dart';
import 'settingsscreen.dart';
import 'loginscreen.dart'; // Ensure this is imported

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
  final TextEditingController searchController = TextEditingController();

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

  String getUserInitials() {
    return '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}';
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
              color: Colors.black,
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
                  child: const Icon(Icons.person, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
              ),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                child: Text(
                  getUserInitials(),
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 40,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text('$firstName $lastName'),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: Text(FirebaseAuth.instance.currentUser?.email ?? ''),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                try {
                  // Sign out the user
                  await FirebaseAuth.instance.signOut();

                  // Navigate to the login screen
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logout failed: ${e.toString()}')),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by Client Name, Invoice ID, or Item',
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
              onSubmitted: (query) async {
                if (query.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter a search term.')),
                  );
                  return;
                }

                try {
                  // Firestore query to search for the input in users, invoices, or items collections
                  final userResults = await FirebaseFirestore.instance
                      .collection('users')
                      .where('name', isGreaterThanOrEqualTo: query)
                      .where('name', isLessThanOrEqualTo: query + '\uf8ff')
                      .get();

                  final invoiceResults = await FirebaseFirestore.instance
                      .collection('invoices')
                      .where('invoiceId', isEqualTo: query)
                      .get();

                  final itemResults = await FirebaseFirestore.instance
                      .collection('items')
                      .where('itemName', isGreaterThanOrEqualTo: query)
                      .where('itemName', isLessThanOrEqualTo: query + '\uf8ff')
                      .get();

                  // Aggregate and process results
                  List<String> results = [];
                  for (var doc in userResults.docs) {
                    results.add('User: ${doc['name']}');
                  }
                  for (var doc in invoiceResults.docs) {
                    results.add('Invoice ID: ${doc['invoiceId']}');
                  }
                  for (var doc in itemResults.docs) {
                    results.add('Item: ${doc['itemName']}');
                  }

                  // Display results or show no matches found
                  if (results.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Results:\n${results.join('\n')}')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No matches found.')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Error during search: ${e.toString()}')),
                  );
                }
              },
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 250,
                  color: const Color.fromARGB(255, 231, 230, 230),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      buildDashboardItem("Dashboard", Icons.dashboard, 0),
                      buildDashboardItem("Categories", Icons.category, 1),
                      buildDashboardItem("Invoices", Icons.receipt, 2),
                      buildDashboardItem("Settings", Icons.settings, 3),
                      buildDashboardItem("Reports", Icons.bar_chart, 4),
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
                      ReportsScreen(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
