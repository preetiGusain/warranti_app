import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:warranti_app/service/warranties_service.dart';

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
  int step = 1;
  bool savingWarranty = false;

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

  Future<void> handleSubmit() async {
    if (productName.isNotEmpty &&
        warrantyDuration.isNotEmpty &&
        selectedDate != null &&
        productPhoto != null &&
        warrantyCardPhoto != null &&
        receiptPhoto != null) {
      setState(() {
        savingWarranty = true;
      });

      bool success = await WarrantiesService.createWarranty(
        productName: productName,
        purchaseDate: selectedDate!.toIso8601String(),
        warrantyDuration: warrantyDuration,
        warrantyDurationUnit: selectedUnit,
        productPhoto: productPhoto,
        warrantyCardPhoto: warrantyCardPhoto,
        receiptPhoto: receiptPhoto,
      );
      setState(() {
        savingWarranty = false;
      });

      if (success) {
        Navigator.pushNamed(context, '/home');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Warranty saved successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create warranty')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
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

  Future<void> showDiscardDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Discard Changes'),
          content: const Text('Are you sure you want to discard your changes?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void goToNext() {
    setState(() {
      step += 1;
    });
  }

  void goToPrevious() {
    setState(() {
      step -= 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Warranty'),
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              showDiscardDialog();
            },
          ),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: step / 3,
                backgroundColor: Colors.grey[300],
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              // Step 1:
              if (step == 1) ...[
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
              ],

              // Step 2:
              if (step == 2) ...[
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
              ],

              // Step 3:
              if (step == 3) ...[
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
              ],

              const SizedBox(height: 20),

              Row(
                children: [
                  // Back button for steps 2 and 3
                  if (step > 1)
                    ElevatedButton(
                      onPressed: goToPrevious,
                      child: const Text('Back'),
                    ),

                  if (step > 1) const Spacer(),

                  // Next button for steps 1 and 2
                  if (step < 3)
                    ElevatedButton(
                      onPressed: goToNext,
                      child: const Text('Next'),
                    ),

                  // Save button for step 3
                  if (step == 3)
                    ElevatedButton(
                      onPressed: savingWarranty ? null : handleSubmit,
                      child: savingWarranty
                          ? const CircularProgressIndicator()
                          : const Text('Save'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
