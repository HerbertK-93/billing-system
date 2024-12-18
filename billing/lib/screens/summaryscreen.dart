import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For currency formatting

class SummaryScreen extends StatefulWidget {
  @override
  _SummaryScreenState createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  Map<String, bool> expandedItems = {};
  double totalInvestment = 0.0;
  double totalProfit = 0.0;

  String formatCurrency(double value) {
    final formatter = NumberFormat.currency(locale: 'en_UG', symbol: 'UGX');
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
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
            final summary = summaries[index];
            final clientName = summary['clientName'];
            final invoiceId = summary['sessionId'];
            final grandTotal = summary['grandTotal'];
            final isExpanded = expandedItems[invoiceId] ?? false;

            final initialInvestmentController = TextEditingController();
            final daysToPayController = TextEditingController();
            final percentageChargeController = TextEditingController();

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      clientName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Grand Total: ${formatCurrency(grandTotal.toDouble())}\nInvoice ID: $invoiceId',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                      ),
                      onPressed: () {
                        setState(() {
                          expandedItems[invoiceId] = !isExpanded;
                        });
                      },
                    ),
                  ),
                  if (isExpanded) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildInputField('Initial Investment',
                              initialInvestmentController),
                          buildInputField(
                              'Days to Pay/Supply', daysToPayController),
                          buildInputField(
                              '% Charge', percentageChargeController),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              final initialInvestment = double.tryParse(
                                      initialInvestmentController.text) ??
                                  0.0;
                              final daysToPay =
                                  int.tryParse(daysToPayController.text) ?? 0;
                              final percentageCharge = double.tryParse(
                                      percentageChargeController.text) ??
                                  0.0;

                              final validGrandTotal = grandTotal is num
                                  ? grandTotal.toDouble()
                                  : 0.0;

                              if (validGrandTotal > 0) {
                                final rateFactor = 0.0001;
                                final rateAdjustment =
                                    validGrandTotal * (daysToPay * rateFactor);

                                final calculatedTotalInvestment =
                                    initialInvestment +
                                        (validGrandTotal *
                                            (percentageCharge / 100)) +
                                        rateAdjustment;

                                final calculatedTotalProfit =
                                    validGrandTotal - calculatedTotalInvestment;

                                setState(() {
                                  totalInvestment = calculatedTotalInvestment;
                                  totalProfit = calculatedTotalProfit;
                                });
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Invalid Data'),
                                    content: const Text(
                                        'Grand Total must be a positive number.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            child: const Text('Calculate'),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Investment: ${formatCurrency(totalInvestment)}',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Total Profit: ${formatCurrency(totalProfit)}',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final summaryDetails = FirebaseFirestore
                                      .instance
                                      .collection('summaryDetails');

                                  await summaryDetails.doc(invoiceId).set({
                                    'invoiceId': invoiceId,
                                    'totalInvestment': totalInvestment,
                                    'totalProfit': totalProfit,
                                    'timestamp': FieldValue.serverTimestamp(),
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Summary details saved for Invoice ID: $invoiceId'),
                                    ),
                                  );
                                },
                                child: const Text('Save'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('summaryDetails')
                                .doc(invoiceId)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              if (!snapshot.hasData || !snapshot.data!.exists) {
                                return const Text(
                                  'No summary details available.',
                                  style: TextStyle(color: Colors.grey),
                                );
                              }

                              final summaryData = snapshot.data!.data()!;
                              final fetchedTotalInvestment =
                                  summaryData['totalInvestment'] ?? 0.0;
                              final fetchedTotalProfit =
                                  summaryData['totalProfit'] ?? 0.0;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Summary Details:',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Fetched Total Investment: ${formatCurrency(fetchedTotalInvestment)}',
                                  ),
                                  Text(
                                    'Fetched Total Profit: ${formatCurrency(fetchedTotalProfit)}',
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget buildInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }
}
