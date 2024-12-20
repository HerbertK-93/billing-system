import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InstallationScreen extends StatefulWidget {
  @override
  _InstallationScreenState createState() => _InstallationScreenState();
}

class _InstallationScreenState extends State<InstallationScreen> {
  // Controllers for client and invoice fields
  final TextEditingController clientNameController = TextEditingController();
  final TextEditingController clientAddressController = TextEditingController();
  final TextEditingController clientEmailController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController clientCategoryController =
      TextEditingController();

  // Item controllers
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController itemDescriptionController =
      TextEditingController();
  final TextEditingController itemQuantityController = TextEditingController();
  final TextEditingController itemMarketPriceController =
      TextEditingController();
  final TextEditingController itemOtherExpensesController =
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

  String invoiceSessionId = '';
  List<Map<String, dynamic>> items = [];
  double grandTotal = 0.0;

  void calculateValues() {
    final int quantity = int.tryParse(itemQuantityController.text.trim()) ?? 0;
    final double marketPrice =
        double.tryParse(itemMarketPriceController.text.trim()) ?? 0.0;
    final double otherExpenses =
        double.tryParse(itemOtherExpensesController.text.trim()) ?? 0.0;

    // Immediate Investment
    final double immediateInvestment = quantity * marketPrice + otherExpenses;
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
    final double interestCharged = immediateInvestment *
        (daysToSupply + (monthsToPay * 30)) /
        30 *
        (interestPercentage / 100);
    itemInterestChargedController.text = interestCharged.toStringAsFixed(2);

    // Total Investment
    final double totalInvestment = immediateInvestment + interestCharged;
    itemTotalInvestmentController.text = totalInvestment.toStringAsFixed(2);

    // Profit
    final double markupPercentage =
        double.tryParse(itemMarkupPercentageController.text.trim()) ?? 0.0;
    final double profit = immediateInvestment * (markupPercentage / 100);
    itemProfitController.text = profit.toStringAsFixed(2);

    // Rate
    final double rate = (immediateInvestment + profit) / quantity;
    itemRateController.text = rate.toStringAsFixed(2);

    // Amount
    final double amount = rate * quantity;
    itemAmountController.text = amount.toStringAsFixed(2);
  }

  void addItem() async {
    if (itemNameController.text.isNotEmpty &&
        itemQuantityController.text.isNotEmpty &&
        itemRateController.text.isNotEmpty) {
      final String itemName = itemNameController.text.trim();
      final String itemDescription = itemDescriptionController.text.trim();
      final int quantity =
          int.tryParse(itemQuantityController.text.trim()) ?? 0;
      final double marketPrice =
          double.tryParse(itemMarketPriceController.text.trim()) ?? 0.0;
      final double otherExpenses =
          double.tryParse(itemOtherExpensesController.text.trim()) ?? 0.0;
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

      setState(() {
        items.add({
          'name': itemName,
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
        });
        grandTotal += amount;

        // Clear input fields
        itemNameController.clear();
        itemDescriptionController.clear();
        itemQuantityController.clear();
        itemMarketPriceController.clear();
        itemOtherExpensesController.clear();
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
      });

      // Update the summary collection
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
              'name': itemName,
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
            }
          ]),
          'grandTotal': FieldValue.increment(amount),
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
              'name': itemName,
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
            }
          ],
          'grandTotal': amount,
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

  void saveInvoice() async {
    if (invoiceSessionId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a new invoice session first.')),
      );
      return;
    }

    final Map<String, dynamic> invoiceData = {
      'sessionId': invoiceSessionId,
      'clientName': clientNameController.text.trim(),
      'clientAddress': clientAddressController.text.trim(),
      'clientEmail': clientEmailController.text.trim(),
      'category': clientCategoryController.text.trim(),
      'date': dateController.text.trim(),
      'items': items,
      'grandTotal': grandTotal,
      'createdAt': FieldValue.serverTimestamp(),
    };

    // Save to the invoices collection
    await FirebaseFirestore.instance
        .collection('invoices')
        .doc(invoiceSessionId)
        .set(invoiceData);

    // Add a single entry to recentActivities
    await FirebaseFirestore.instance.collection('recentActivities').add({
      'clientName': clientNameController.text.trim(),
      'invoiceId': invoiceSessionId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invoice Saved Successfully!')),
    );

    setState(() {
      items.clear();
      grandTotal = 0.0;
      invoiceSessionId = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Installations', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.grey[300],
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                invoiceSessionId =
                    DateTime.now().millisecondsSinceEpoch.toString();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('New Invoice Session Created: $invoiceSessionId')),
              );
            },
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
            buildInputField('Item Name', itemNameController),
            buildInputField('Item Description', itemDescriptionController),
            buildInputField('Quantity', itemQuantityController,
                isNumeric: true, onChanged: (_) => calculateValues()),
            buildInputField('Market Price', itemMarketPriceController,
                isNumeric: true, onChanged: (_) => calculateValues()),
            buildInputField('Other Expenses', itemOtherExpensesController,
                isNumeric: true, onChanged: (_) => calculateValues()),
            buildInputField(
                'Immediate Investment', itemImmediateInvestmentController,
                isNumeric: true, readOnly: true),
            buildInputField('Days to Supply', itemDaysToSupplyController,
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
                  Padding(padding: EdgeInsets.all(8.0), child: Text('Name')),
                  Padding(
                      padding: EdgeInsets.all(8.0), child: Text('Description')),
                  Padding(
                      padding: EdgeInsets.all(8.0), child: Text('Quantity')),
                  Padding(padding: EdgeInsets.all(8.0), child: Text('Rate')),
                  Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Amount (UGX)')),
                ]),
                ...items.map((item) {
                  return TableRow(children: [
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(item['name'])),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(item['description'])),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${item['quantity']}')),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('UGX ${item['rate'].toStringAsFixed(2)}')),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child:
                            Text('UGX ${item['amount'].toStringAsFixed(2)}')),
                  ]);
                }).toList(),
              ],
            ),
            const SizedBox(height: 20),
            Text('Grand Total: UGX ${grandTotal.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    grandTotal = 0.0;
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
