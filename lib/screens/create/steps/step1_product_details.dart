// step1_product_details.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:warranti_app/widgets/image_picker_field.dart';

class Step1ProductDetails extends StatelessWidget {
  final TextEditingController productNameController;
  final File? productImage;
  final VoidCallback onImagePick;

  const Step1ProductDetails({
    required this.productNameController,
    required this.productImage,
    required this.onImagePick,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: productNameController,
          decoration: InputDecoration(
            labelText: 'Product Name',
            suffixIcon: Icon(Icons.devices_other),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        SizedBox(height: 20),
        ImagePickerField(
          image: productImage,
          onTap: onImagePick,
          label: 'Upload Product Photo',
        ),
      ],
    );
  }
}
