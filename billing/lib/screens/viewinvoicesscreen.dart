import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ViewInvoicesScreen extends StatelessWidget {
  Future<void> downloadInvoice(
      Map<String, dynamic> invoiceData, String invoiceId) async {
    try {
      final pdf = pw.Document();

      // Generate the PDF content
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Invoice ID: $invoiceId',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Text('Client Name: ${invoiceData['clientName'] ?? 'N/A'}'),
                pw.Text(
                    'Client Address: ${invoiceData['clientAddress'] ?? 'N/A'}'),
                pw.Text('Client Email: ${invoiceData['clientEmail'] ?? 'N/A'}'),
                pw.Text('Date: ${invoiceData['date'] ?? 'N/A'}'),
                pw.Text('Item Name: ${invoiceData['itemName'] ?? 'N/A'}'),
                pw.Text(
                    'Item Description: ${invoiceData['itemDescription'] ?? 'N/A'}'),
                pw.Text(
                    'Item Quantity: ${invoiceData['itemQuantity'] ?? 'N/A'}'),
                pw.Text(
                    'Item Market Price: ${invoiceData['itemMarketPrice'] ?? 'N/A'}'),
                pw.Text(
                    'Other Expenses: ${invoiceData['otherExpenses'] ?? 'N/A'}'),
                pw.Text(
                    'Immediate Investment: ${invoiceData['immediateInvestment'] ?? 'N/A'}'),
                pw.Text(
                    'Days to Supply: ${invoiceData['daysToSupply'] ?? 'N/A'}'),
                pw.Text(
                    'Percentage Interest Charged: ${invoiceData['percentageInterestCharged'] ?? 'N/A'}'),
                pw.Text('Rate: ${invoiceData['rate'] ?? 'N/A'}'),
                pw.Text(
                    'Total Investment: ${invoiceData['totalInvestment'] ?? 'N/A'}'),
                pw.Text('Total Profit: ${invoiceData['totalProfit'] ?? 'N/A'}'),
                pw.Text(
                    'Created At: ${invoiceData['createdAt'] != null ? invoiceData['createdAt'].toDate() : 'N/A'}'),
              ],
            );
          },
        ),
      );

      // Save the PDF to the device's local storage
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/invoice_$invoiceId.pdf');

      await file.writeAsBytes(await pdf.save());

      // Provide user feedback
      print('Invoice saved at: ${file.path}');
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(content: Text('Invoice downloaded: ${file.path}')),
      );

      // Share or print the PDF
      await Printing.sharePdf(
          bytes: await pdf.save(), filename: 'invoice_$invoiceId.pdf');
    } catch (e) {
      print('Error saving invoice: $e');
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(
            content: Text('Failed to download invoice. Please try again.')),
      );
    }
  }

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disable the debug banner
      navigatorKey: navigatorKey,
      home: Scaffold(
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
                child:
                    Text('No invoices found.', style: TextStyle(fontSize: 18)),
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
                            Text(
                                'Item Name: ${invoiceData['itemName'] ?? 'N/A'}'),
                            Text(
                                'Item Description: ${invoiceData['itemDescription'] ?? 'N/A'}'),
                            Text(
                                'Item Quantity: ${invoiceData['itemQuantity'] ?? 'N/A'}'),
                            Text(
                                'Item Market Price: ${invoiceData['itemMarketPrice'] ?? 'N/A'}'),
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
                            Text(
                                'Created At: ${invoiceData['createdAt'] != null ? invoiceData['createdAt'].toDate() : 'N/A'}'),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () async {
                                await downloadInvoice(invoiceData, invoice.id);
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.blue, // Button color
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
      ),
    );
  }
}
