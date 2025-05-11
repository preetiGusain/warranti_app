import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:warranti_app/widgets/step_indicator.dart';
import './steps/step1_product_details.dart';
import './steps/step2_purchase_info.dart';
import './steps/step3_warranty_info.dart';
import 'package:warranti_app/service/navigator_service.dart';
import 'package:warranti_app/service/warranties_service.dart';
import 'package:warranti_app/util/image_compressor.dart';

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
  bool isMonthSelected = true;

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _warrantyDurationController =
      TextEditingController();

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> pickImage(String imageType, ImageSource source) async {
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
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  NavigatorService.pop();
                  await pickImage(imageType, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  NavigatorService.pop();
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
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Discard Changes'),
        content: const Text('Are you sure you want to discard your changes?'),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: NavigatorService.pop,
            child: const Text('No', style: TextStyle(color: Colors.black)),
          ),
          const SizedBox(width: 10),
          OutlinedButton(
            onPressed: () {
              NavigatorService.pushNamed('/home');
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color(0xFF7E57C2),
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  Future<void> handleSubmit() async {
    warrantyDuration = _warrantyDurationController.text;

    if (productName.isEmpty ||
        warrantyDuration.isEmpty ||
        selectedDate == null ||
        warrantyCardPhoto == null ||
        receiptPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => savingWarranty = true);

    final compressedProductPhoto = productPhoto != null
        ? await ImageCompressor.compressImage(productPhoto!)
        : null;
    final compressedWarrantyCardPhoto =
        await ImageCompressor.compressImage(warrantyCardPhoto!);
    final compressedReceiptPhoto =
        await ImageCompressor.compressImage(receiptPhoto!);

    final adjustedDuration = warrantyDuration;

    bool success = await WarrantiesService.createWarranty(
      productName: productName,
      purchaseDate: selectedDate!.toIso8601String(),
      warrantyDuration: adjustedDuration.toString(),
      warrantyDurationUnit: selectedUnit,
      productPhoto: compressedProductPhoto,
      warrantyCardPhoto: compressedWarrantyCardPhoto,
      receiptPhoto: compressedReceiptPhoto,
    );

    setState(() => savingWarranty = false);

    if (success) {
      NavigatorService.pushNamed('/home');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Warranty saved successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create warranty')),
      );
    }
  }

  void goToNext() {
    if (step == 1 && _productNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields in step 1')),
      );
      return;
    }
    if (step == 2 && (selectedDate == null || receiptPhoto == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields in step 2')),
      );
      return;
    }
    setState(() {
      if (step == 1) productName = _productNameController.text;
      step++;
    });
  }

  void goToPrevious() {
    if (step > 1) setState(() => step--);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          showDiscardDialog();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 40,
          title: const Text(
            'Create Warranty',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 24,
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: showDiscardDialog,
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: StepIndicator(
                currentStep: step - 1,
                totalSteps: 3,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: _buildStepWidget(),
              ),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepWidget() {
    if (step == 1) {
      return Step1ProductDetails(
        productNameController: _productNameController,
        productImage: productPhoto,
        onImagePick: () => showImageSourceOptions(context, 'product'),
      );
    } else if (step == 2) {
      return Step2PurchaseInfo(
        selectedDate: selectedDate,
        onSelectDate: () => selectDate(context),
        receiptImage: receiptPhoto,
        onReceiptPick: () => showImageSourceOptions(context, 'receipt'),
      );
    } else {
      return Step3WarrantyInfo(
        warrantyDurationController: _warrantyDurationController,
        isMonthSelected: isMonthSelected,
        onUnitToggle: (value) {
          setState(() {
            isMonthSelected = value;
            selectedUnit = value ? 'Month' : 'Year';
          });
        },
        warrantyCardImage: warrantyCardPhoto,
        onWarrantyCardPick: () =>
            showImageSourceOptions(context, 'warrantyCard'),
      );
    }
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (step > 1)
            ElevatedButton(
              onPressed: savingWarranty ? null : goToPrevious,
              child: const Text('Back'),
            ),
          if (step < 3)
            ElevatedButton(
              onPressed: savingWarranty ? null : goToNext,
              child: const Text('Next'),
            ),
          if (step == 3)
            ElevatedButton(
              onPressed: savingWarranty ? null : handleSubmit,
              child: savingWarranty
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Save'),
            ),
        ],
      ),
    );
  }
}
