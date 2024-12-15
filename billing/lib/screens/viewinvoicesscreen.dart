import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:html' as html;
import 'package:http/http.dart' as http;

class ViewInvoicesScreen extends StatelessWidget {
  Future<void> downloadInvoice(String invoiceId) async {
    final url = 'http://localhost:3000/downloadInvoice/$invoiceId';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final blob = html.Blob([response.bodyBytes]);
        final anchor = html.AnchorElement(
          href: html.Url.createObjectUrlFromBlob(blob),
        )
          ..download = 'invoice_$invoiceId.pdf'
          ..click();
      } else {
        throw Exception('Failed to download invoice: ${response.body}');
      }
    } catch (e) {
      print('Error downloading invoice: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'View Invoices',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.grey[300],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('invoices').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading invoices. Please try again later.'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No invoices found.', style: TextStyle(fontSize: 18)),
            );
          }

          final invoices = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              final invoiceData = invoice.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ExpansionTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoiceData['clientName'] ?? 'Unnamed Client',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Invoice ID: ${invoice.id}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Client Address: ${invoiceData['clientAddress'] ?? 'N/A'}'),
                          Text(
                              'Client Email: ${invoiceData['clientEmail'] ?? 'N/A'}'),
                          Text('Date: ${invoiceData['date'] ?? 'N/A'}'),
                          const SizedBox(height: 10),
                          const Text(
                            'Items:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Display items
                          if (invoiceData['items'] != null &&
                              invoiceData['items'] is List)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: (invoiceData['items'] as List)
                                  .map((item) => Text(
                                        '- ${item['name'] ?? 'N/A'}: ${item['description'] ?? 'N/A'} (Qty: ${item['quantity'] ?? 0}, Price: ${item['price'] ?? 0})',
                                      ))
                                  .toList(),
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Item Name: ${invoiceData['itemName'] ?? 'N/A'}'),
                                Text(
                                    'Item Description: ${invoiceData['itemDescription'] ?? 'N/A'}'),
                                Text(
                                    'Item Quantity: ${invoiceData['itemQuantity'] ?? 'N/A'}'),
                                Text(
                                    'Item Market Price: ${invoiceData['itemMarketPrice'] ?? 'N/A'}'),
                              ],
                            ),
                          const SizedBox(height: 10),
                          Text(
                              'Other Expenses: ${invoiceData['otherExpenses'] ?? 'N/A'}'),
                          Text(
                              'Immediate Investment: ${invoiceData['immediateInvestment'] ?? 'N/A'}'),
                          Text(
                              'Days to Supply: ${invoiceData['daysToSupply'] ?? 'N/A'}'),
                          Text(
                              'Percentage Interest Charged: ${invoiceData['percentageInterestCharged'] ?? 'N/A'}'),
                          Text('Rate: ${invoiceData['rate'] ?? 'N/A'}'),
                          Text(
                              'Total Investment: ${invoiceData['totalInvestment'] ?? 'N/A'}'),
                          Text(
                              'Total Profit: ${invoiceData['totalProfit'] ?? 'N/A'}'),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () async {
                              await downloadInvoice(invoice.id);
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blue,
                            ),
                            child: const Text('Download Invoice'),
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
    );
  }
}
