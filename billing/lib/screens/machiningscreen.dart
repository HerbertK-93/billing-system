import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MachiningScreen extends StatefulWidget {
  @override
  _MachiningScreenState createState() => _MachiningScreenState();
}

class _MachiningScreenState extends State<MachiningScreen> {
  // Controllers for client and invoice fields
  final TextEditingController clientNameController = TextEditingController();
  final TextEditingController clientAddressController = TextEditingController();
  final TextEditingController clientEmailController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController clientCategoryController =
      TextEditingController();

  // Item controllers
  final TextEditingController itemNumberController = TextEditingController();
  final TextEditingController itemDescriptionController =
      TextEditingController();
  final TextEditingController itemQuantityController = TextEditingController();
  final TextEditingController itemMarketPriceController =
      TextEditingController();
  final TextEditingController itemOtherExpensesController =
      TextEditingController();
  final TextEditingController itemMachiningCostController =
      TextEditingController();
  final TextEditingController itemImmediateInvestmentController =
      TextEditingController();
  final TextEditingController itemDaysToSupplyController =
      TextEditingController();
  final TextEditingController itemMonthsToPayController =
      TextEditingController();
  final TextEditingController itemInterestPercentageController =
      TextEditingController();
  final TextEditingController itemInterestChargedController =
      TextEditingController();
  final TextEditingController itemTotalInvestmentController =
      TextEditingController();
  final TextEditingController itemMarkupPercentageController =
      TextEditingController();
  final TextEditingController itemProfitController = TextEditingController();
  final TextEditingController itemRateController = TextEditingController();
  final TextEditingController itemAmountController = TextEditingController();
  final TextEditingController itemvatPercentageController =
      TextEditingController();
  final TextEditingController itemvatController = TextEditingController();
  final TextEditingController itemgrandTotalController =
      TextEditingController();

  // Issued by controller
  final TextEditingController issuedByController = TextEditingController();

  String invoiceSessionId = '';
  List<Map<String, dynamic>> items = [];
  double totalAmount = 0.0;

  String invoiceId = '';

  void calculateValues() {
    final int quantity = int.tryParse(itemQuantityController.text.trim()) ?? 0;
    final double marketPrice =
        double.tryParse(itemMarketPriceController.text.trim()) ?? 0.0;
    final double otherExpenses =
        double.tryParse(itemOtherExpensesController.text.trim()) ?? 0.0;
    final double machiningCost =
        double.tryParse(itemMachiningCostController.text.trim()) ?? 0.0;

    // Helper function to round to the nearest 100
    double roundToNearest100(double value) {
      return (value / 100).round() * 100;
    }

    // Immediate Investment
    final double immediateInvestment = roundToNearest100(
        quantity * (marketPrice + machiningCost) + otherExpenses);
    itemImmediateInvestmentController.text =
        immediateInvestment.toStringAsFixed(2);

    // Days to Supply and Months to Pay
    final int daysToSupply =
        int.tryParse(itemDaysToSupplyController.text.trim()) ?? 0;
    final int monthsToPay =
        int.tryParse(itemMonthsToPayController.text.trim()) ?? 0;
    final double interestPercentage =
        double.tryParse(itemInterestPercentageController.text.trim()) ?? 0.0;

    // % Interest Charged
    final double interestCharged = roundToNearest100(
      immediateInvestment *
          (daysToSupply + (monthsToPay * 30)) /
          30 *
          (interestPercentage / 100),
    );
    itemInterestChargedController.text = interestCharged.toStringAsFixed(2);

    // Total Investment
    final double totalInvestment =
        roundToNearest100(immediateInvestment + interestCharged);
    itemTotalInvestmentController.text = totalInvestment.toStringAsFixed(2);

    // Profit
    final double markupPercentage =
        double.tryParse(itemMarkupPercentageController.text.trim()) ?? 0.0;
    final double profit =
        roundToNearest100(totalInvestment * (markupPercentage / 100));
    itemProfitController.text = profit.toStringAsFixed(2);

    // Rate
    final double rate =
        roundToNearest100((totalInvestment + profit) / quantity);
    itemRateController.text = rate.toStringAsFixed(2);

    // Amount
    final double amount = roundToNearest100(rate * quantity);
    itemAmountController.text = amount.toStringAsFixed(2);

    // VAT Calculation
    final double vatPercentage =
        double.tryParse(itemvatPercentageController.text.trim()) ?? 0.0;
    final double vat = (amount * vatPercentage) / 100;
    itemvatController.text = vat.toStringAsFixed(2);

    // Grand Total Calculation
    final double grandTotal = amount + vat;
    itemgrandTotalController.text = grandTotal.toStringAsFixed(2);
  }

  void addItem() async {
    if (itemNumberController.text.isNotEmpty &&
        itemQuantityController.text.isNotEmpty &&
        itemRateController.text.isNotEmpty) {
      final String itemNumber = itemNumberController.text.trim();
      final String itemDescription = itemDescriptionController.text.trim();
      final int quantity =
          int.tryParse(itemQuantityController.text.trim()) ?? 0;
      final double marketPrice =
          double.tryParse(itemMarketPriceController.text.trim()) ?? 0.0;
      final double otherExpenses =
          double.tryParse(itemOtherExpensesController.text.trim()) ?? 0.0;
      final double machiningCost =
          double.tryParse(itemMachiningCostController.text.trim()) ?? 0.0;
      final double immediateInvestment =
          double.tryParse(itemImmediateInvestmentController.text.trim()) ?? 0.0;
      final int daysToSupply =
          int.tryParse(itemDaysToSupplyController.text.trim()) ?? 0;
      final int monthsToPay =
          int.tryParse(itemMonthsToPayController.text.trim()) ?? 0;
      final double interestPercentage =
          double.tryParse(itemInterestPercentageController.text.trim()) ?? 0.0;
      final double interestCharged =
          double.tryParse(itemInterestChargedController.text.trim()) ?? 0.0;
      final double totalInvestment =
          double.tryParse(itemTotalInvestmentController.text.trim()) ?? 0.0;
      final double markupPercentage =
          double.tryParse(itemMarkupPercentageController.text.trim()) ?? 0.0;
      final double profit =
          double.tryParse(itemProfitController.text.trim()) ?? 0.0;
      final double rate =
          double.tryParse(itemRateController.text.trim()) ?? 0.0;
      final double amount = quantity * rate;
      final double vatPercentage =
          double.tryParse(itemvatPercentageController.text.trim()) ?? 0.0;
      final double vat = (amount * vatPercentage) / 100;
      final double grandTotal = amount + vat;

      setState(() {
        items.add({
          'number': itemNumber,
          'description': itemDescription,
          'quantity': quantity,
          'marketPrice': marketPrice,
          'otherExpenses': otherExpenses,
          'machiningCost': machiningCost,
          'immediateInvestment': immediateInvestment,
          'daysToSupply': daysToSupply,
          'monthsToPay': monthsToPay,
          'interestPercentage': interestPercentage,
          'interestCharged': interestCharged,
          'totalInvestment': totalInvestment,
          'markupPercentage': markupPercentage,
          'profit': profit,
          'rate': rate,
          'amount': amount,
          'vat': vat,
          'grandTotal': grandTotal,
        });
        totalAmount += amount;

        // Clear input fields
        itemNumberController.clear();
        itemDescriptionController.clear();
        itemQuantityController.clear();
        itemMarketPriceController.clear();
        itemOtherExpensesController.clear();
        itemMachiningCostController.clear();
        itemImmediateInvestmentController.clear();
        itemDaysToSupplyController.clear();
        itemMonthsToPayController.clear();
        itemInterestPercentageController.clear();
        itemInterestChargedController.clear();
        itemTotalInvestmentController.clear();
        itemMarkupPercentageController.clear();
        itemProfitController.clear();
        itemRateController.clear();
        itemAmountController.clear();
        itemvatPercentageController.clear();
        itemvatController.clear();
        itemgrandTotalController.clear();
      });

      final existingDoc = await FirebaseFirestore.instance
          .collection('summary')
          .doc(invoiceSessionId)
          .get();

      if (existingDoc.exists) {
        await FirebaseFirestore.instance
            .collection('summary')
            .doc(invoiceSessionId)
            .update({
          'items': FieldValue.arrayUnion([
            {
              'number': itemNumber,
              'description': itemDescription,
              'quantity': quantity,
              'marketPrice': marketPrice,
              'otherExpenses': otherExpenses,
              'immediateInvestment': immediateInvestment,
              'daysToSupply': daysToSupply,
              'monthsToPay': monthsToPay,
              'interestPercentage': interestPercentage,
              'interestCharged': interestCharged,
              'totalInvestment': totalInvestment,
              'markupPercentage': markupPercentage,
              'profit': profit,
              'rate': rate,
              'amount': amount,
              'vat': vat,
              'grandTotal': grandTotal,
            }
          ]),
          'totalAmount': FieldValue.increment(amount),
        });
      } else {
        await FirebaseFirestore.instance
            .collection('summary')
            .doc(invoiceSessionId)
            .set({
          'invoiceId': invoiceSessionId,
          'clientName': clientNameController.text.trim(),
          'clientAddress': clientAddressController.text.trim(),
          'clientEmail': clientEmailController.text.trim(),
          'date': dateController.text.trim(),
          'category': clientCategoryController.text.trim(),
          'items': [
            {
              'number': itemNumber,
              'description': itemDescription,
              'quantity': quantity,
              'marketPrice': marketPrice,
              'otherExpenses': otherExpenses,
              'machiningCost': machiningCost,
              'immediateInvestment': immediateInvestment,
              'daysToSupply': daysToSupply,
              'monthsToPay': monthsToPay,
              'interestPercentage': interestPercentage,
              'interestCharged': interestCharged,
              'totalInvestment': totalInvestment,
              'markupPercentage': markupPercentage,
              'profit': profit,
              'rate': rate,
              'amount': amount,
              'vat': vat,
              'grandTotal': grandTotal,
            }
          ],
          'totalAmount': amount,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item added and summary updated')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all item fields')),
      );
    }
  }

  Future<void> createNewInvoiceSession() async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('counters').doc('invoice');
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          transaction.set(docRef, {'current': 1});
          invoiceId = '001';
        } else {
          int current = snapshot['current'];
          current += 1;
          transaction.update(docRef, {'current': current});
          invoiceId = current.toString().padLeft(3, '0');
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('New Invoice Session Created: $invoiceId')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating invoice session: $e')),
      );
    }
  }

  void saveInvoice() async {
    if (invoiceId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a new invoice session first.')),
      );
      return;
    }

    final Map<String, dynamic> invoiceData = {
      'invoiceId': invoiceId,
      'clientName': clientNameController.text.trim(),
      'clientAddress': clientAddressController.text.trim(),
      'clientEmail': clientEmailController.text.trim(),
      'category': clientCategoryController.text.trim(),
      'date': dateController.text.trim(),
      'issuedBy': issuedByController.text.trim(), // Add this line
      'items': items,
      'totalAmount': totalAmount,
      'createdAt': FieldValue.serverTimestamp(),
    };

    // Save to the invoices collection
    await FirebaseFirestore.instance
        .collection('invoices')
        .doc(invoiceId)
        .set(invoiceData);

    // Save to the summary collection
    await FirebaseFirestore.instance.collection('summary').doc(invoiceId).set({
      'invoiceId': invoiceId,
      'clientName': clientNameController.text.trim(),
      'clientAddress': clientAddressController.text.trim(),
      'clientEmail': clientEmailController.text.trim(),
      'category': clientCategoryController.text.trim(),
      'date': dateController.text.trim(),
      'issuedBy': issuedByController.text.trim(), // Add this line
      'items': items,
      'totalAmount': totalAmount,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance.collection('recentActivities').add({
      'invoiceId': invoiceId,
      'clientName': clientNameController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invoice and Summary Saved Successfully!')),
    );

    setState(() {
      items.clear();
      totalAmount = 0.0;
      invoiceId = '';
      issuedByController.clear(); // Clear the issued by field
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Machining', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.grey[300],
        actions: [
          ElevatedButton.icon(
            onPressed: createNewInvoiceSession,
            icon: const Icon(Icons.add),
            label: const Text('Create New Invoice'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text('Client Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            buildInputField('Client Name', clientNameController),
            buildInputField('Client Address', clientAddressController),
            buildInputField('Client Email', clientEmailController),
            buildInputField('Category', clientCategoryController),
            buildInputField('Date', dateController),
            const SizedBox(height: 20),
            const Text('Add Item',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            buildInputField('Item Number', itemNumberController),
            buildInputField('Item Description', itemDescriptionController),
            buildInputField('Quantity', itemQuantityController,
                isNumeric: true, onChanged: (_) => calculateValues()),
            buildInputField('Market Price', itemMarketPriceController,
                isNumeric: true, onChanged: (_) => calculateValues()),
            buildInputField('Other Expenses', itemOtherExpensesController,
                isNumeric: true, onChanged: (_) => calculateValues()),
            buildInputField(
                'Machining Cost Per Unit', itemMachiningCostController,
                isNumeric: true, onChanged: (_) => calculateValues()),
            buildInputField(
                'Immediate Investment', itemImmediateInvestmentController,
                isNumeric: true, readOnly: true),
            buildInputField('Days to Machine', itemDaysToSupplyController,
                isNumeric: true, onChanged: (_) => calculateValues()),
            buildInputField('Months to Pay', itemMonthsToPayController,
                isNumeric: true, onChanged: (_) => calculateValues()),
            buildInputField(
                '% Interest Charged', itemInterestPercentageController,
                isNumeric: true, onChanged: (_) => calculateValues()),
            buildInputField('Interest Charged', itemInterestChargedController,
                isNumeric: true, readOnly: true),
            buildInputField('Total Investment', itemTotalInvestmentController,
                isNumeric: true, readOnly: true),
            buildInputField('% Mark Up', itemMarkupPercentageController,
                isNumeric: true, onChanged: (_) => calculateValues()),
            buildInputField('Profit', itemProfitController,
                isNumeric: true, readOnly: true),
            buildInputField('Rate', itemRateController,
                isNumeric: true, readOnly: true),
            buildInputField('Amount', itemAmountController,
                isNumeric: true, readOnly: true),
            buildInputField('% VAT', itemvatPercentageController,
                isNumeric: true, onChanged: (_) => calculateValues()),
            buildInputField('VAT', itemvatController,
                isNumeric: true, readOnly: true),
            buildInputField('Grand Total', itemgrandTotalController,
                isNumeric: true, readOnly: true),
            ElevatedButton.icon(
              onPressed: addItem,
              icon: const Icon(Icons.add_box),
              label: const Text('Add Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text('Items List',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Table(
              border: TableBorder.all(color: Colors.grey),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(2),
              },
              children: [
                const TableRow(children: [
                  Padding(padding: EdgeInsets.all(8.0), child: Text('Number')),
                  Padding(
                      padding: EdgeInsets.all(8.0), child: Text('Description')),
                  Padding(
                      padding: EdgeInsets.all(8.0), child: Text('Quantity')),
                  Padding(
                      padding: EdgeInsets.all(8.0), child: Text('Rate (UGX)')),
                  Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Amount (UGX)')),
                ]),
                ...items.map((item) {
                  return TableRow(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(item['number']),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(item['description']),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${item['quantity']}'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${item['rate'].toStringAsFixed(2)}'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${item['amount'].toStringAsFixed(2)}'),
                    ),
                  ]);
                }).toList(),
                TableRow(children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(''),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('V.A.T (18%)',
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
                    child: Text(
                      items.isNotEmpty
                          ? items
                              .map((e) => e['vat'])
                              .reduce((a, b) => a + b)
                              .toStringAsFixed(2)
                          : '0.00',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ]),
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
                    child: Text(
                      items.isNotEmpty
                          ? items
                              .map((e) => e['grandTotal'])
                              .reduce((a, b) => a + b)
                              .toStringAsFixed(2)
                          : '0.00',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ]),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Issued by',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            buildInputField('Name of the issuer', issuedByController),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: saveInvoice,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Invoice'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: () => setState(() {
                    items.clear();
                    totalAmount = 0.0;
                  }),
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear All'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInputField(String label, TextEditingController controller,
      {bool isNumeric = false,
      bool readOnly = false,
      void Function(String)? onChanged}) {
    if (label == 'Date') {
      // Special handling for Date input field
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextField(
          controller: controller,
          readOnly: true, // Prevent manual input
          onTap: () async {
            // Show calendar picker
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (pickedDate != null) {
              // Format and set the selected date
              controller.text = "${pickedDate.toLocal()}".split(' ')[0];
            }
          },
          decoration: InputDecoration(
            labelText: label,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
            filled: true,
            fillColor: Colors.grey[200], // Optional: Indicate read-only status
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        readOnly: readOnly,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          filled: readOnly,
          fillColor: readOnly ? Colors.grey[200] : null,
        ),
      ),
    );
  }
}
