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
                          // Display Client Information
                          Text(
                              'Client Address: ${invoiceData['clientAddress'] ?? 'N/A'}'),
                          Text(
                              'Client Email: ${invoiceData['clientEmail'] ?? 'N/A'}'),
                          Text(
                              'Category: ${invoiceData['category'] ?? 'Uncategorized'}'),
                          Text('Date: ${invoiceData['date'] ?? 'N/A'}'),
                          const SizedBox(height: 10),

                          // Display Items Section
                          const Text(
                            'Items:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const SizedBox(height: 10),

                          if (invoiceData['items'] != null &&
                              invoiceData['items'] is List)
                            Table(
                              border: TableBorder.all(color: Colors.grey),
                              columnWidths: const {
                                0: FlexColumnWidth(2), // Name
                                1: FlexColumnWidth(3), // Description
                                2: FlexColumnWidth(1), // Quantity
                                3: FlexColumnWidth(1), // Rate
                                4: FlexColumnWidth(2), // Amount
                              },
                              children: [
                                // Table Header
                                const TableRow(children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Name',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Description',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Quantity',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Rate (UGX)',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Amount (UGX)',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ]),
                                // Table Rows
                                ...List<TableRow>.from(
                                  (invoiceData['items'] as List).map((item) {
                                    return TableRow(children: [
                                      Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                              item['name'] ?? 'N/A')), // Name
                                      Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(item['description'] ??
                                              'N/A')), // Description
                                      Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                              '${item['quantity'] ?? 0}')), // Quantity
                                      Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                              'UGX ${item['rate']?.toStringAsFixed(2) ?? '0.00'}')), // Rate
                                      Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                              'UGX ${item['amount']?.toStringAsFixed(2) ?? '0.00'}')), // Amount
                                    ]);
                                  }),
                                ),
                              ],
                            )
                          else
                            const Text('No items available.'),

                          const SizedBox(height: 10),

                          // Grand Total
                          Text(
                            'Grand Total: UGX ${invoiceData['grandTotal']?.toStringAsFixed(2) ?? '0.00'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Download Invoice Button
                          ElevatedButton(
                            onPressed: () async {
                              await downloadInvoice(invoice.id);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
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
