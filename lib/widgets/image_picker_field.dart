import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

class ImagePickerField extends StatelessWidget {
  final File? image;
  final VoidCallback onTap;
  final String label;

  const ImagePickerField({
    required this.image,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        color: Colors.purpleAccent,
        borderType: BorderType.RRect,
        radius: Radius.circular(12),
        dashPattern: [6, 4],
        child: Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color.fromARGB(255, 218, 198, 233),
          ),
          child: image == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 40),
                    SizedBox(height: 8),
                    Text(label),
                  ],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(image!, fit: BoxFit.cover),
                ),
        ),
      ),
    );
  }
}
