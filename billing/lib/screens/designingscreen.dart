import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DesigningScreen extends StatefulWidget {
  @override
  _DesigningScreenState createState() => _DesigningScreenState();
}

class _DesigningScreenState extends State<DesigningScreen> {
  // Controllers for client and invoice fields
  final TextEditingController clientNameController = TextEditingController();
  final TextEditingController clientAddressController = TextEditingController();
  final TextEditingController clientEmailController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  // Item controllers
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController itemDescriptionController =
      TextEditingController();
  final TextEditingController itemQuantityController = TextEditingController();
  final TextEditingController itemRateController = TextEditingController();

  String invoiceSessionId = '';
  List<Map<String, dynamic>> items = [];
  double grandTotal = 0.0;

  // Function to add an item
  void addItem() {
    if (itemNameController.text.isNotEmpty &&
        itemQuantityController.text.isNotEmpty &&
        itemRateController.text.isNotEmpty) {
      final int quantity =
          int.tryParse(itemQuantityController.text.trim()) ?? 0;
      final double rate =
          double.tryParse(itemRateController.text.trim()) ?? 0.0;
      final double amount = quantity * rate;

      setState(() {
        items.add({
          'name': itemNameController.text.trim(),
          'description': itemDescriptionController.text.trim(),
          'quantity': quantity,
          'rate': rate,
          'amount': amount,
        });
        grandTotal += amount;

        // Clear input fields
        itemNameController.clear();
        itemDescriptionController.clear();
        itemQuantityController.clear();
        itemRateController.clear();
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

  // Function to save invoice to Firestore
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

    // Add entry to recentActivities collection
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

  Widget buildInputField(String label, TextEditingController controller,
      {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: 150,
        child: TextField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            labelText: label,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Designing', style: TextStyle(color: Colors.black)),
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
            // Client Information
            const Text('Client Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            buildInputField('Client Name', clientNameController),
            buildInputField('Client Address', clientAddressController),
            buildInputField('Client Email', clientEmailController),
            buildInputField('Date', dateController),

            // Item Input Section
            const SizedBox(height: 20),
            const Text('Add Item',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            buildInputField('Item Name', itemNameController),
            buildInputField('Item Description', itemDescriptionController),
            buildInputField('Quantity', itemQuantityController,
                isNumeric: true),
            buildInputField('Rate', itemRateController, isNumeric: true),
            ElevatedButton.icon(
              onPressed: addItem,
              icon: const Icon(Icons.add_box),
              label: const Text('Add Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),

            // Items List
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

            // Grand Total
            const SizedBox(height: 20),
            Text('Grand Total: UGX ${grandTotal.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            // Action Buttons
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
}
