import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GeneralScreen extends StatelessWidget {
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
          'General',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.grey[300],
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 199, 184, 51),
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
              buildTextField('Client Name', clientNameController),
              buildTextField('Client Address', clientAddressController),
              buildTextField('Client Email', clientEmailController),
              buildTextField('Date', dateController),
              buildTextField('Item Name', itemNameController),
              buildTextField('Item Description', itemDescriptionController),
              buildTextField('Item Quantity', itemQuantityController),
              buildTextField('Item Market Price', itemMarketPriceController),
              buildTextField('Other Expenses', otherExpensesController),
              buildTextField(
                  'Immediate Investment', immediateInvestmentController),
              buildTextField('Days to Supply', daysToSupplyController),
              buildTextField('Percentage Interest Charged',
                  percentageInterestChargedController),
              buildTextField('Rate', rateController),
              buildTextField('Total Investment', totalInvestmentController),
              buildTextField('Total Profit', totalProfitController),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 199, 184, 51),
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
                          SnackBar(
                              content:
                                  Text('Create a new invoice session first.')),
                        );
                        return;
                      }

                      final invoiceData = {
                        'sessionId': invoiceSessionId,
                        'clientName': clientNameController.text,
                        'clientAddress': clientAddressController.text,
                        'clientEmail': clientEmailController.text,
                        'date': dateController.text,
                        'itemName': itemNameController.text,
                        'itemDescription': itemDescriptionController.text,
                        'itemQuantity': itemQuantityController.text,
                        'itemMarketPrice': itemMarketPriceController.text,
                        'otherExpenses': otherExpensesController.text,
                        'immediateInvestment':
                            immediateInvestmentController.text,
                        'daysToSupply': daysToSupplyController.text,
                        'percentageInterestCharged':
                            percentageInterestChargedController.text,
                        'rate': rateController.text,
                        'totalInvestment': totalInvestmentController.text,
                        'totalProfit': totalProfitController.text,
                        'createdAt': FieldValue.serverTimestamp(),
                      };

                      await FirebaseFirestore.instance
                          .collection('invoices')
                          .add(invoiceData);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Invoice Saved Successfully!')),
                      );
                    },
                    child: const Text(
                      'Save Invoice',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red, // Button background color
                      onPrimary: Colors.white, // Text color
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () {
                      // Clear all text fields
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
                        SnackBar(content: Text('Fields Cleared!')),
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

  Widget buildTextField(String labelText, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }
}
