import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:warranti_app/constants.dart';
import 'package:warranti_app/service/token_service.dart';
import 'package:warranti_app/service/warranties_service.dart';

class WarrantyScreen extends StatefulWidget {
  final String id;
  const WarrantyScreen({super.key, required this.id});

  @override
  State<WarrantyScreen> createState() => _WarrantyScreenState();
}

class _WarrantyScreenState extends State<WarrantyScreen> {
  dynamic warranty;


  @override
  void initState() {
    super.initState();
    // Access the id here using widget.id
    print('Warranty ID: ${widget.id}');
    setWarranty(widget.id);
  }

  Future<void> setWarranty(String id) async {
    try {
      final fetchedWarranty = await WarrantiesService.fetchWarranty(id);
      setState(() {
        warranty = fetchedWarranty;
      });
    } catch (e) {
      print('Error fetching warranty: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Warranty Details'),
      ),
      body: Center(
        child: Text('Warranty ID: $warranty}'),
      ),
    );
  }
}
