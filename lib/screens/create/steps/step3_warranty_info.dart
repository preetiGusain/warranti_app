// step3_warranty_info.dart
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(2),
          ],
          decoration: InputDecoration(
            labelText: 'Warranty Duration',
            suffixText: isMonthSelected ? 'months' : 'years',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        SizedBox(height: 20),
        Row(
          children: [
            const Text('Duration Unit:'),
            const Spacer(),
            Text(
              'Month',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isMonthSelected
                    ? const Color.fromARGB(255, 133, 91, 176)
                    : const Color.fromARGB(255, 218, 198, 233),
              ),
            ),
            const SizedBox(width: 8),
            CupertinoSwitch(
              value: isMonthSelected,
              onChanged: onUnitToggle,
              activeTrackColor: const Color.fromARGB(255, 133, 91, 176),
            ),
            const SizedBox(width: 8),
            Text(
              'Year',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: !isMonthSelected
                    ? const Color.fromARGB(255, 133, 91, 176)
                    : const Color.fromARGB(255, 218, 198, 233),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ImagePickerField(
          image: warrantyCardImage,
          onTap: onWarrantyCardPick,
          label: 'Upload Warranty Card Photo',
        ),
      ],
    );
  }
}
