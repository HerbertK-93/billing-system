import 'package:flutter/material.dart';

class FabricationScreen extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.black), // Arrow color changed to black
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Fabrication',
          style: TextStyle(color: Colors.black), // Text color changed to black
        ),
        backgroundColor: Colors.grey[300], // Light grey color
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary:
                      Color.fromARGB(255, 199, 184, 51), // Background color
                  onPrimary: Colors.black, // Text color
                  padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16), // Adjusted padding for reduced height
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () {
                  // Logic for creating a new invoice
                },
                child: const Text(
                  'Create New Invoice',
                  style: TextStyle(
                    fontWeight: FontWeight.bold, // Make text bolder
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: 600, // Adjust the width as needed for better presentation
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            shrinkWrap: true, // Center the content
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary:
                      Color.fromARGB(255, 199, 184, 51), // Background color
                  onPrimary: Colors.black, // Text color
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () {
                  // Logic to save the invoice
                },
                child: const Text(
                  'Save Invoice',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
