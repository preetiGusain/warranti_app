import 'package:flutter/material.dart';

class WarrantyScreen extends StatefulWidget {
  const WarrantyScreen({super.key});

  @override
  State<WarrantyScreen> createState() => _WarrantyScreenState();
}

class _WarrantyScreenState extends State<WarrantyScreen> {
  @override
  Widget build(BuildContext context) {
    final id =
        ModalRoute.of(context)?.settings.arguments as String;
    return Text('Hello you are in warranty page $id');
  }
}
