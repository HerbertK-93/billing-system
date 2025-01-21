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
              final category = invoiceData['category'] ?? 'Uncategorized';

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
                          Text('Category: $category'),
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
                          if (invoiceData['items'] != null &&
                              invoiceData['items'] is List)
                            buildInvoiceTable(category, invoiceData['items'])
                          else
                            const Text('No items available.'),
                          const SizedBox(height: 20),
                          // Display "Issued by" field
                          if (invoiceData['issuedBy'] != null)
                            Text(
                              'Issued by: ${invoiceData['issuedBy']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          const SizedBox(height: 20),
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

  /// Build a dynamic table based on the category
  Widget buildInvoiceTable(String category, List<dynamic> items) {
    List<TableRow> rows = [];

    if (category == 'General') {
      // General category table
      rows.add(
        const TableRow(children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child:
                Text('Number', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Description',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child:
                Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Rate (UGX)',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Amount (UGX)',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ]),
      );

      rows.addAll(items.map((item) {
        return TableRow(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(item['number'] ?? 'N/A'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(item['description'] ?? 'N/A'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('${item['quantity'] ?? 0}'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('${item['rate']?.toStringAsFixed(2) ?? '0.00'}'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('${item['amount']?.toStringAsFixed(2) ?? '0.00'}'),
          ),
        ]);
      }).toList());

      // Add Summary Rows for Consumables, Labour, SubTotal2, VAT, etc.
      final double consumables = items.fold<double>(
        0.0,
        (sum, item) => sum + (item['consumables'] ?? 0.0),
      );
      final double labour = items.fold<double>(
        0.0,
        (sum, item) => sum + (item['labour'] ?? 0.0),
      );
      final double subTotal2 = items.fold<double>(
        0.0,
        (sum, item) => sum + (item['subTotal2'] ?? 0.0),
      );
      final double vat = items.fold<double>(
        0.0,
        (sum, item) => sum + (item['vat'] ?? 0.0),
      );
      final double grandTotal = items.fold<double>(
        0.0,
        (sum, item) => sum + (item['grandTotal'] ?? 0.0),
      );

      rows.add(
        TableRow(children: [
          const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Consumables',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
          const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(consumables.toStringAsFixed(2)),
          ),
        ]),
      );

      rows.add(
        TableRow(children: [
          const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child:
                Text('Labour', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
          const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(labour.toStringAsFixed(2)),
          ),
        ]),
      );

      rows.add(
        TableRow(children: [
          const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Sub-Total 2',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
          const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(subTotal2.toStringAsFixed(2)),
          ),
        ]),
      );

      rows.add(
        TableRow(children: [
          const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child:
                Text('VAT(18%)', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
          const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(vat.toStringAsFixed(2)),
          ),
        ]),
      );

      rows.add(
        TableRow(children: [
          const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Grand Total',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
          const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(grandTotal.toStringAsFixed(2)),
          ),
        ]),
      );
    } else if (category == 'Supply' || category == 'Machining') {
      rows.add(
        const TableRow(children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child:
                Text('Number', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Description',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child:
                Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Rate (UGX)',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Amount (UGX)',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ]),
      );

      rows.addAll(items.map((item) {
        return TableRow(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(item['number'] ?? 'N/A'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(item['description'] ?? 'N/A'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('${item['quantity'] ?? 0}'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('${item['rate']?.toStringAsFixed(2) ?? '0.00'}'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('${item['amount']?.toStringAsFixed(2) ?? '0.00'}'),
          ),
        ]);
      }).toList());
      final double vat = items.fold<double>(
        0.0,
        (sum, item) => sum + (item['vat'] ?? 0.0),
      );
      final double grandTotal = items.fold<double>(
        0.0,
        (sum, item) => sum + (item['grandTotal'] ?? 0.0),
      );

      rows.add(
        TableRow(children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(''),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('VAT (18%)',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(''),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(''),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(vat.toStringAsFixed(2)),
          ),
        ]),
      );

      rows.add(
        TableRow(children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(''),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Grand Total',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(''),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(''),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(grandTotal.toStringAsFixed(2)),
          ),
        ]),
      );
    } else if (category == 'Maintenance' ||
        category == 'Fabrication' ||
        category == 'Installation' ||
        category == 'Designing') {
      rows.add(
        const TableRow(children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child:
                Text('Number', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Description',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Qualification of Workers',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('No of Workers',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('No of Days',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Hours in Day',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Rate (UGX)',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Amount (UGX)',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ]),
      );

      rows.addAll(items.map((item) {
        return TableRow(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(item['number'] ?? 'N/A'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(item['description'] ?? 'N/A'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(item['qualificationOfWorkers'] ?? 'N/A'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('${item['numberOfWorkers'] ?? 0}'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('${item['numberOfDays'] ?? 0}'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('${item['hoursInDay'] ?? 0}'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('${item['rate']?.toStringAsFixed(2) ?? '0.00'}'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('${item['amount']?.toStringAsFixed(2) ?? '0.00'}'),
          ),
        ]);
      }).toList());

      // VAT Row
      final double vat = items.fold<double>(
        0.0,
        (sum, item) => sum + (item['amount'] ?? 0.0) * 0.18,
      );

      rows.add(
        TableRow(children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(''),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('VAT (18%)',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
          const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
          const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
          const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
          const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(vat.toStringAsFixed(2)),
          ),
        ]),
      );

      // Grand Total Row
      final double grandTotal = items.fold<double>(
        0.0,
        (sum, item) => sum + (item['amount'] ?? 0.0) * 1.18,
      );

      rows.add(
        TableRow(children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(''),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Grand Total',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
          const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
          const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
          const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
          const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(grandTotal.toStringAsFixed(2)),
          ),
        ]),
      );
    }

    return Table(
      border: TableBorder.all(color: Colors.grey),
      children: rows,
    );
  }
}
