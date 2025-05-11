import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

Widget buildImage(String imageUrl) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 2),
    color: Colors.grey[300],
    child: imageUrl.isNotEmpty
        ? Image.network(
            imageUrl,
            height: 300,
            fit: BoxFit.cover,
          )
        : const Center(child: Text('No Image Available')),
  );
}

Widget buildIndicator(int activeIndex) {
  return AnimatedSmoothIndicator(
    activeIndex: activeIndex,
    count: 3,
    effect: const JumpingDotEffect(
      dotHeight: 12,
      dotWidth: 12,
      dotColor: Colors.black12,
      activeDotColor: Color(0xFFDAB8FC),
    ),
  );
}

Widget buildDetailRow(String label, String value, {Icon? icon}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        if (icon != null)
          icon
        else
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
      ],
    ),
  );
}
