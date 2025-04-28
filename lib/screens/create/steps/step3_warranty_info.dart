// step3_warranty_info.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:warranti_app/widgets/image_picker_field.dart';

class Step3WarrantyInfo extends StatelessWidget {
  final TextEditingController warrantyDurationController;
  final bool isMonthSelected;
  final ValueChanged<bool> onUnitToggle;
  final File? warrantyCardImage;
  final VoidCallback onWarrantyCardPick;

  const Step3WarrantyInfo({
    required this.warrantyDurationController,
    required this.isMonthSelected,
    required this.onUnitToggle,
    required this.warrantyCardImage,
    required this.onWarrantyCardPick,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: warrantyDurationController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Warranty Duration',
            suffixText: isMonthSelected ? 'months' : 'years',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Text('Duration Unit:'),
            Spacer(),
            Switch(
              value: isMonthSelected,
              onChanged: onUnitToggle,
            ),
            Text(isMonthSelected ? 'Month' : 'Year'),
          ],
        ),
        SizedBox(height: 20),
        ImagePickerField(
          image: warrantyCardImage,
          onTap: onWarrantyCardPick,
          label: 'Upload Warranty Card Photo',
        ),
      ],
    );
  }
}
