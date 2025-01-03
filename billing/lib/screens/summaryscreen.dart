import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:html' as html;
import 'package:http/http.dart' as http;

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
    final url = 'http://localhost:3000/downloadSummary/$summaryId';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final blob = html.Blob([response.bodyBytes]);
        final anchor = html.AnchorElement(
          href: html.Url.createObjectUrlFromBlob(blob),
        )
          ..download = 'summary_$summaryId.pdf'
          ..click();
      } else {
        throw Exception('Failed to download summary: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading summary: $e')),
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

                final invoiceId = summary['invoiceId'] ?? 'Unknown';
                final clientName = summary['clientName'] ?? 'Unknown';
                final clientAddress = summary['clientAddress'] ?? 'Unknown';
                final clientEmail = summary['clientEmail'] ?? 'Unknown';
                final date = summary['date'] ?? 'Unknown';
                final category = summary['category'] ?? 'Unknown';

                // Ensure items are fetched and parsed correctly
                final items =
                    (summary['items'] as List<dynamic>? ?? []).map((item) {
                  final itemData = item as Map<String, dynamic>;
                  return {
                    'number': itemData['number'] ?? 'Unknown',
                    'description': itemData['description'] ?? 'Unknown',
                    'qualificationOfWorkers':
                        itemData['qualificationOfWorkers'] ?? 0,
                    'quantity': itemData['quantity'] ?? 0,
                    'numberOfWorkers': itemData['numberOfWorkers'] ?? 0,
                    'numberOfDays': itemData['numberOfDays'] ?? 0,
                    'hoursInDay': itemData['hoursInDay'] ?? 0,
                    'moneyPaidPerHourPerPerson':
                        itemData['moneyPaidPerHourPerPerson'] ?? 0,
                    'daysToSupply': itemData['daysToSupply'] ?? 0,
                    'interestPercentage':
                        itemData['interestPercentage']?.toDouble() ?? 0.0,
                    'marketPrice': itemData['marketPrice']?.toDouble() ?? 0.0,
                    'otherExpenses':
                        itemData['otherExpenses']?.toDouble() ?? 0.0,
                    'machiningCost': itemData['machiningCost']?.toDouble() ??
                        0.0, // Ensure machiningCost is mapped
                    'immediateInvestment':
                        itemData['immediateInvestment']?.toDouble() ?? 0.0,
                    'totalInvestment':
                        itemData['totalInvestment']?.toDouble() ?? 0.0,
                    'markupPercentage':
                        itemData['markupPercentage']?.toDouble() ?? 0.0,
                    'profit': itemData['profit']?.toDouble() ?? 0.0,
                    'rate': itemData['rate']?.toDouble() ?? 0.0,
                    'amount': itemData['amount']?.toDouble() ?? 0.0,
                  };
                }).toList();

                final isExpanded = expandedItems[summaries[index].id] ?? false;

                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          'Invoice ID: $invoiceId',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Client: $clientName\nCategory: $category\nDate: $date',
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
                                          'Number: ${item['number']}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                            'Description: ${item['description']}'),
                                        Text('Quantity: ${item['quantity']}'),
                                        Text(
                                            'Qualification of Workers: ${item['qualificationOfWorkers']}'),
                                        Text(
                                            'Number of Workers: ${item['numberOfWorkers']}'),
                                        Text(
                                            'Number of Days: ${item['numberOfDays']}'),
                                        Text(
                                            'Hours in Day: ${item['hoursInDay']}'),
                                        Text(
                                            'Money Paid Per Hour Per Person: ${item['moneyPaidPerHourPerPerson']}'),
                                        Text(
                                            'Days to Pay: ${item['daysToSupply']}'),
                                        Text(
                                            '% Interest Charged: ${item['interestPercentage']}%'),
                                        Text(
                                            'Market Price: ${formatCurrency(item['marketPrice'])}'),
                                        Text(
                                            'Other Expenses: ${formatCurrency(item['otherExpenses'])}'),
                                        Text(
                                            'Machining Cost: ${formatCurrency(item['machiningCost'])}'), // Display machiningCost
                                        Text(
                                            'Immediate Investment: ${formatCurrency(item['immediateInvestment'])}'),
                                        Text(
                                            'Total Investment: ${formatCurrency(item['totalInvestment'])}'),
                                        Text(
                                            '% Markup: ${item['markupPercentage']}%'),
                                        Text(
                                            'Profit: ${formatCurrency(item['profit'])}'),
                                        Text(
                                            'Rate: ${formatCurrency(item['rate'])}'),
                                        Text(
                                            'Amount: ${formatCurrency(item['amount'])}'),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: () =>
                                      downloadSummary(summaries[index].id),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Download Summary'),
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
