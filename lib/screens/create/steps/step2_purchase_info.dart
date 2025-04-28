// step2_purchase_info.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:warranti_app/widgets/image_picker_field.dart';

class Step2PurchaseInfo extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onSelectDate;
  final File? receiptImage;
  final VoidCallback onReceiptPick;

  const Step2PurchaseInfo({
    required this.selectedDate,
    required this.onSelectDate,
    required this.receiptImage,
    required this.onReceiptPick,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController dateController = TextEditingController(
      text: selectedDate != null
          ? '${selectedDate!.toLocal()}'.split(' ')[0]
          : '',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onSelectDate,
          child: AbsorbPointer(
            child: TextField(
              controller: dateController,
              decoration: InputDecoration(
                labelText: 'Purchase Date',
                hintText: 'Tap to select a date',
                suffixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ImagePickerField(
          image: receiptImage,
          onTap: onReceiptPick,
          label: 'Upload Receipt Photo',
        ),
      ],
    );
  }
}
