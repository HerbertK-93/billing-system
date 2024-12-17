import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InstallationScreen extends StatelessWidget {
  // Controllers and invoiceSessionId remain unchanged
  final TextEditingController clientNameController = TextEditingController();
  final TextEditingController clientAddressController = TextEditingController();
  final TextEditingController clientEmailController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController itemDescriptionController =
      TextEditingController();
  final TextEditingController itemQuantityController = TextEditingController();
  final TextEditingController itemMarketPriceController =
      TextEditingController();
  final TextEditingController otherExpensesController = TextEditingController();
  final TextEditingController immediateInvestmentController =
      TextEditingController();
  final TextEditingController daysToSupplyController = TextEditingController();
  final TextEditingController percentageInterestChargedController =
      TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController totalInvestmentController =
      TextEditingController();
  final TextEditingController totalProfitController = TextEditingController();

  String invoiceSessionId = '';

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
          'Installtion',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.grey[300],
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: const Color.fromARGB(255, 199, 184, 51),
                  onPrimary: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () {
                  invoiceSessionId =
                      DateTime.now().millisecondsSinceEpoch.toString();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'New Invoice Session Created: $invoiceSessionId')),
                  );
                },
                child: const Text(
                  'Create New Invoice',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: 600,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            shrinkWrap: true,
            children: [
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(3),
                },
                border: TableBorder.all(color: Colors.grey),
                children: [
                  buildTableRow('Client Name', clientNameController),
                  buildTableRow('Client Address', clientAddressController),
                  buildTableRow('Client Email', clientEmailController),
                  buildTableRow('Date', dateController),
                  buildTableRow('Item Name', itemNameController),
                  buildTableRow('Item Description', itemDescriptionController),
                  buildTableRow('Item Quantity', itemQuantityController),
                  buildTableRow('Item Market Price', itemMarketPriceController),
                  buildTableRow('Other Expenses', otherExpensesController),
                  buildTableRow(
                      'Immediate Investment', immediateInvestmentController),
                  buildTableRow('Days to Supply', daysToSupplyController),
                  buildTableRow('Percentage Interest Charged',
                      percentageInterestChargedController),
                  buildTableRow('Rate', rateController),
                  buildTableRow('Total Investment', totalInvestmentController),
                  buildTableRow('Total Profit', totalProfitController),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: const Color.fromARGB(255, 199, 184, 51),
                      onPrimary: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () async {
                      if (invoiceSessionId.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Create a new invoice session first.')),
                        );
                        return;
                      }

                      final List<Map<String, dynamic>> items = [
                        {
                          'name': itemNameController.text.trim(),
                          'description': itemDescriptionController.text.trim(),
                          'quantity': itemQuantityController.text.trim(),
                          'price': itemMarketPriceController.text.trim(),
                        },
                      ];

                      final Map<String, dynamic> invoiceData = {
                        'sessionId': invoiceSessionId,
                        'clientName': clientNameController.text.trim(),
                        'clientAddress': clientAddressController.text.trim(),
                        'clientEmail': clientEmailController.text.trim(),
                        'date': dateController.text.trim(),
                        'items': items,
                        'otherExpenses': otherExpensesController.text.trim(),
                        'immediateInvestment':
                            immediateInvestmentController.text.trim(),
                        'daysToSupply': daysToSupplyController.text.trim(),
                        'percentageInterestCharged':
                            percentageInterestChargedController.text.trim(),
                        'rate': rateController.text.trim(),
                        'totalInvestment':
                            totalInvestmentController.text.trim(),
                        'totalProfit': totalProfitController.text.trim(),
                        'createdAt': FieldValue.serverTimestamp(),
                      };

                      await FirebaseFirestore.instance
                          .collection('invoices')
                          .doc(invoiceSessionId)
                          .set(invoiceData);

                      // Save recent activity in Firestore
                      await FirebaseFirestore.instance
                          .collection('recentActivities')
                          .add({
                        'invoiceId': invoiceSessionId,
                        'clientName': clientNameController.text.trim(),
                        'timestamp': FieldValue.serverTimestamp(),
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Invoice Saved Successfully!')),
                      );
                    },
                    child: const Text(
                      'Save Invoice',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      onPrimary: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () {
                      clientNameController.clear();
                      clientAddressController.clear();
                      clientEmailController.clear();
                      dateController.clear();
                      itemNameController.clear();
                      itemDescriptionController.clear();
                      itemQuantityController.clear();
                      itemMarketPriceController.clear();
                      otherExpensesController.clear();
                      immediateInvestmentController.clear();
                      daysToSupplyController.clear();
                      percentageInterestChargedController.clear();
                      rateController.clear();
                      totalInvestmentController.clear();
                      totalProfitController.clear();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fields Cleared!')),
                      );
                    },
                    child: const Text(
                      'Clear',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  TableRow buildTableRow(String label, TextEditingController controller) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
