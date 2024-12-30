import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:warranti_app/constants.dart';
import 'package:warranti_app/service/token_service.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  String productName = '';
  DateTime? selectedDate;
  String warrantyDuration = '';
  String selectedUnit = 'Month';

  Future<void> selectDate(BuildContext context) async {
    final DateTime initialDate = selectedDate ?? DateTime.now();
    final DateTime firstDate = DateTime(1900);
    final DateTime lastDate = DateTime(2100);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> createWarranty() async {
    String? token = await getToken();

    if (token == null) {
      print('No token found');
      return;
    }

    final url = Uri.parse('$backend_uri/warranty/create');
    final request = http.MultipartRequest('POST', url)
      ..headers.addAll({
        'Authorization': token,
      });

    request.fields['productName'] = productName;
    request.fields['purchaseDate'] = selectedDate?.toIso8601String() ?? '';
    request.fields['warrantyDuration'] = warrantyDuration;
    request.fields['warrantyDurationUnit'] = selectedUnit;

    try {
      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        print('Success: ${responseBody.body}');
        Navigator.pushNamed(context, '/home');
      } else {
        print('Error: ${response.statusCode}');
        print('Response Body: ${responseBody.body}');
      }
    } catch (error) {
      print('Request failed: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Warranty'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'Product Name',
              ),
              onChanged: (value) {
                setState(() {
                  productName = value;
                });
              },
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => selectDate(context),
              child: AbsorbPointer(
                child: TextField(
                  controller: TextEditingController(
                    text: selectedDate == null
                        ? ''
                        : '${selectedDate?.toLocal()}'.split(' ')[0],
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Purchase Date',
                    hintText: 'Tap to select a date',
                  ),
                  readOnly: true,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Warranty Duration',
              ),
              onChanged: (value) {
                setState(() {
                  warrantyDuration = value;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Warranty Duration Unit',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: selectedUnit,
              items: <String>['Month', 'Year'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedUnit = value ?? 'Month';
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (productName.isNotEmpty &&
                    warrantyDuration.isNotEmpty &&
                    selectedDate != null) {
                  createWarranty();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
