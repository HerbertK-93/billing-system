import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GeneralScreen extends StatefulWidget {
  @override
  _GeneralScreenState createState() => _GeneralScreenState();
}

class _GeneralScreenState extends State<GeneralScreen> {
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
  final TextEditingController itemRateController = TextEditingController();
  final TextEditingController itemAmountController = TextEditingController();
  final TextEditingController itemSubTotal1Controller = TextEditingController();
  final TextEditingController itemConsumablesPercentageController =
      TextEditingController();
  final TextEditingController itemConsumablesController =
      TextEditingController();
  final TextEditingController itemLabourPercentageController =
      TextEditingController();
  final TextEditingController itemLabourController = TextEditingController();
  final TextEditingController itemSubTotal2Controller = TextEditingController();
  final TextEditingController itemVATController = TextEditingController();
  final TextEditingController itemGrandTotalController =
      TextEditingController();

  String invoiceSessionId = '';
  List<Map<String, dynamic>> items = [];
  double totalAmount = 0.0;

  String invoiceId = '';

  void calculateValues() {
    final int quantity = int.tryParse(itemQuantityController.text.trim()) ?? 0;
    final double rate = double.tryParse(itemRateController.text.trim()) ?? 0.0;

    // Amount (same as Sub-Total 1)
    final double amount = quantity * rate;
    itemAmountController.text = amount.toStringAsFixed(2);
    itemSubTotal1Controller.text = amount.toStringAsFixed(2);

    // Consumables Calculation
    final double consumablesPercentage =
        double.tryParse(itemConsumablesPercentageController.text.trim()) ?? 0.0;
    final double consumables = (amount * consumablesPercentage) / 100;
    itemConsumablesController.text = consumables.toStringAsFixed(2);

    // Labour Calculation
    final double labourPercentage =
        double.tryParse(itemLabourPercentageController.text.trim()) ?? 0.0;
    final double labour = (amount * labourPercentage) / 100;
    itemLabourController.text = labour.toStringAsFixed(2);

    // Sub-Total 2 Calculation
    final double subTotal2 = amount + consumables + labour;
    itemSubTotal2Controller.text = subTotal2.toStringAsFixed(2);

    // VAT Calculation (18%)
    final double vat = (subTotal2 * 18) / 100;
    itemVATController.text = vat.toStringAsFixed(2);

    // Grand Total Calculation
    final double grandTotal = subTotal2 + vat;
    itemGrandTotalController.text = grandTotal.toStringAsFixed(2);
  }

  void addItem() {
    if (itemNumberController.text.isNotEmpty &&
        itemQuantityController.text.isNotEmpty &&
        itemRateController.text.isNotEmpty) {
      final String itemNumber = itemNumberController.text.trim();
      final String itemDescription = itemDescriptionController.text.trim();
      final int quantity =
          int.tryParse(itemQuantityController.text.trim()) ?? 0;
      final double rate =
          double.tryParse(itemRateController.text.trim()) ?? 0.0;
      final double amount =
          double.tryParse(itemAmountController.text.trim()) ?? 0.0;
      final double subTotal1 =
          double.tryParse(itemSubTotal1Controller.text.trim()) ?? 0.0;
      final double consumablesPercentage =
          double.tryParse(itemConsumablesPercentageController.text.trim()) ??
              0.0;
      final double consumables =
          double.tryParse(itemConsumablesController.text.trim()) ?? 0.0;
      final double labourPercentage =
          double.tryParse(itemLabourPercentageController.text.trim()) ?? 0.0;
      final double labour =
          double.tryParse(itemLabourController.text.trim()) ?? 0.0;
      final double subTotal2 =
          double.tryParse(itemSubTotal2Controller.text.trim()) ?? 0.0;
      final double vat = double.tryParse(itemVATController.text.trim()) ?? 0.0;
      final double grandTotal =
          double.tryParse(itemGrandTotalController.text.trim()) ?? 0.0;

      setState(() {
        items.add({
          'number': itemNumber,
          'description': itemDescription,
          'quantity': quantity,
          'rate': rate,
          'amount': amount,
          'subTotal1': subTotal1,
          'consumablesPercentage': consumablesPercentage,
          'consumables': consumables,
          'labourPercentage': labourPercentage,
          'labour': labour,
          'subTotal2': subTotal2,
          'vat': vat,
          'grandTotal': grandTotal,
        });
        totalAmount += amount;

        // Clear input fields
        itemNumberController.clear();
        itemDescriptionController.clear();
        itemQuantityController.clear();
        itemRateController.clear();
        itemAmountController.clear();
        itemSubTotal1Controller.clear();
        itemConsumablesPercentageController.clear();
        itemConsumablesController.clear();
        itemLabourPercentageController.clear();
        itemLabourController.clear();
        itemSubTotal2Controller.clear();
        itemVATController.clear();
        itemGrandTotalController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item added successfully')),
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('General', style: TextStyle(color: Colors.black)),
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
            const Text(
              'Client Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            buildInputField('Client Name', clientNameController),
            buildInputField('Client Address', clientAddressController),
            buildInputField('Client Email', clientEmailController),
            buildInputField('Category', clientCategoryController),
            buildInputField('Date', dateController),
            const SizedBox(height: 20),
            const Text(
              'Add Item',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            buildInputField('Item Number', itemNumberController),
            buildInputField('Item Description', itemDescriptionController),
            buildInputField('Quantity', itemQuantityController,
                isNumeric: true, onChanged: (_) => calculateValues()),
            buildInputField('Rate', itemRateController,
                isNumeric: true, onChanged: (_) => calculateValues()),
            buildInputField('Amount', itemAmountController,
                isNumeric: true, readOnly: true),
            buildInputField('Sub-Total 1', itemSubTotal1Controller,
                isNumeric: true, readOnly: true),
            buildInputField('Consumables % to be Charged',
                itemConsumablesPercentageController,
                isNumeric: true, onChanged: (_) => calculateValues()),
            buildInputField('Consumables', itemConsumablesController,
                isNumeric: true, readOnly: true),
            buildInputField(
                '% Labour to be Charged', itemLabourPercentageController,
                isNumeric: true, onChanged: (_) => calculateValues()),
            buildInputField('Labour', itemLabourController,
                isNumeric: true, readOnly: true),
            buildInputField('Sub-Total 2', itemSubTotal2Controller,
                isNumeric: true, readOnly: true),
            buildInputField('V.A.T (18%)', itemVATController,
                isNumeric: true, readOnly: true),
            buildInputField('Grand Total', itemGrandTotalController,
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
            const Text(
              'Items List',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Table(
              border: TableBorder.all(color: Colors.grey),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(3),
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
                    child: Text('Consumables',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                  const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                  const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      items.isNotEmpty
                          ? items
                              .map((e) => e['consumables'])
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
                    child: Text('Labour',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                  const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                  const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      items.isNotEmpty
                          ? items
                              .map((e) => e['labour'])
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
                    child: Text('Sub-Total 2',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                  const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                  const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      items.isNotEmpty
                          ? items
                              .map((e) => e['subTotal2'])
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
                    child: Text('V.A.T (18%)',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                  const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                  const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
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
                    child: Text('Grand Total',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                  const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                  const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: saveInvoice,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Invoice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
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
                    foregroundColor: Colors.white,
                  ),
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
