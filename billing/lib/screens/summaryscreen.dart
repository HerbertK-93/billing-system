import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:html' as html;

class SummaryScreen extends StatefulWidget {
  @override
  _SummaryScreenState createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  Map<String, bool> expandedItems = {};

  String formatCurrency(double value) {
    final formatter = NumberFormat.currency(locale: 'en_UG', symbol: 'UGX');
    return formatter.format(value);
  }

  Future<void> downloadSummary(String summaryId) async {
    final url =
        'http://localhost:3000/downloadSummary/$summaryId'; // Backend endpoint
    try {
      html.AnchorElement anchor = html.AnchorElement(href: url)
        ..target = '_blank'
        ..download = 'summary_$summaryId.pdf'; // Suggested file name
      anchor.click();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('summary').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No summaries available.'));
            }

            final summaries = snapshot.data!.docs;

            return ListView.builder(
              itemCount: summaries.length,
              itemBuilder: (context, index) {
                final summary = summaries[index].data() as Map<String, dynamic>;

                final clientName = summary['clientName'] ?? 'Unknown';
                final clientAddress = summary['clientAddress'] ?? 'Unknown';
                final clientEmail = summary['clientEmail'] ?? 'Unknown';
                final date = summary['date'] ?? 'Unknown';
                final category = summary['category'] ?? 'Unknown';
                final items = summary['items'] as List<dynamic>? ?? [];

                final isExpanded = expandedItems[summaries[index].id] ?? false;

                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          clientName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Category: $category\nDate: $date',
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                          ),
                          onPressed: () {
                            setState(() {
                              expandedItems[summaries[index].id] = !isExpanded;
                            });
                          },
                        ),
                      ),
                      if (isExpanded)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Client Information:',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text('Name: $clientName'),
                              Text('Address: $clientAddress'),
                              Text('Email: $clientEmail'),
                              Text('Category: $category'),
                              Text('Date: $date'),
                              const SizedBox(height: 8),
                              const Text(
                                'Items:',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              ...items.map((item) {
                                final itemData = item as Map<String, dynamic>;
                                return Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Name: ${itemData['name'] ?? 'Unknown'}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                            'Description: ${itemData['description'] ?? 'Unknown'}'),
                                        Text(
                                            'Quantity: ${itemData['quantity'] ?? 0}'),
                                        Text(
                                            'Days to Pay: ${itemData['daysToSupply'] ?? 0}'),
                                        Text(
                                            '% Interest Charged: ${itemData['interestPercentage']?.toDouble() ?? 0.0}%'),
                                        Text(
                                            'Market Price: ${formatCurrency(itemData['marketPrice']?.toDouble() ?? 0.0)}'),
                                        Text(
                                            'Other Expenses: ${formatCurrency(itemData['otherExpenses']?.toDouble() ?? 0.0)}'),
                                        Text(
                                            'Immediate Investment: ${formatCurrency(itemData['immediateInvestment']?.toDouble() ?? 0.0)}'),
                                        Text(
                                            'Total Investment: ${formatCurrency(itemData['totalInvestment']?.toDouble() ?? 0.0)}'),
                                        Text(
                                            '% Markup: ${itemData['markupPercentage']?.toDouble() ?? 0.0}%'),
                                        Text(
                                            'Profit: ${formatCurrency(itemData['profit']?.toDouble() ?? 0.0)}'),
                                        Text(
                                            'Rate: ${formatCurrency(itemData['rate']?.toDouble() ?? 0.0)}'),
                                        Text(
                                            'Amount: ${formatCurrency(itemData['amount']?.toDouble() ?? 0.0)}'),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      downloadSummary(summaries[index].id),
                                  icon: const Icon(Icons.download),
                                  label: const Text('Download Summary'),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
