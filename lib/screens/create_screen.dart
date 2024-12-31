import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
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
  File? productPhoto;
  File? warrantyCardPhoto;
  File? receiptPhoto;

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
    print('Using token: $token');

    final url = Uri.parse('$backend_uri/warranty/create');
    final request = http.MultipartRequest('POST', url)
      ..headers.addAll({
        'Authorization': token,
      });

    request.fields['productName'] = productName;
    request.fields['purchaseDate'] = selectedDate?.toIso8601String() ?? '';
    request.fields['warrantyDuration'] = warrantyDuration;
    request.fields['warrantyDurationUnit'] = selectedUnit;

    if (productPhoto != null) {
      request.files.add(
          await http.MultipartFile.fromPath('product', productPhoto!.path));
    }
    if (warrantyCardPhoto != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'warrantyCard', warrantyCardPhoto!.path));
    }
    if (receiptPhoto != null) {
      request.files.add(
          await http.MultipartFile.fromPath('receipt', receiptPhoto!.path));
    }

    try {
      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      print('Response status: ${response.statusCode}');
      print('Response body: ${responseBody.body}');

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

  Future pickImage(String imageType, ImageSource source) async {
    final returnedImage = await ImagePicker().pickImage(source: source);
    if (returnedImage == null) return;

    setState(() {
      if (imageType == 'product') {
        productPhoto = File(returnedImage.path);
      } else if (imageType == 'warrantyCard') {
        warrantyCardPhoto = File(returnedImage.path);
      } else if (imageType == 'receipt') {
        receiptPhoto = File(returnedImage.path);
      }
    });
  }

  void showImageSourceOptions(BuildContext context, String imageType) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  await pickImage(imageType, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  await pickImage(imageType, ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Warranty'),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
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
              productPhoto != null
                  ? Image.file(
                      productPhoto!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : const Text("No Product Image Selected"),
              MaterialButton(
                color: Colors.lightBlue,
                onPressed: () {
                  showImageSourceOptions(context, 'product');
                },
                child: const Text(
                  "Select Product Image",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              warrantyCardPhoto != null
                  ? Image.file(
                      warrantyCardPhoto!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : const Text("No Warranty Card Image Selected"),
              MaterialButton(
                color: Colors.lightBlue,
                onPressed: () {
                  showImageSourceOptions(context, 'warrantyCard');
                },
                child: const Text(
                  "Select Warranty Card Image",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              receiptPhoto != null
                  ? Image.file(
                      receiptPhoto!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : const Text("No Receipt Image Selected"),
              MaterialButton(
                color: Colors.lightBlue,
                onPressed: () {
                  showImageSourceOptions(context, 'receipt');
                },
                child: const Text(
                  "Select Receipt Image",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
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
      ),
    );
  }
}
