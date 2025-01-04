import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:warranti_app/service/warranties_service.dart';
import 'package:warranti_app/widgets/warranty_widgets.dart';

class WarrantyScreen extends StatefulWidget {
  final String id;
  const WarrantyScreen({super.key, required this.id});

  @override
  State<WarrantyScreen> createState() => _WarrantyScreenState();
}

class _WarrantyScreenState extends State<WarrantyScreen> {
  dynamic warranty;
  bool _isDeleting = false;
  int activeIndex = 0;

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

  String formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd MMM yyyy').format(parsedDate);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  Future<void> deleteWarranty() async {
    try {
      setState(() {
        _isDeleting = true;
      });

      await WarrantiesService.deleteWarranty(widget.id);

      setState(() {
        _isDeleting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Warranty deleted successfully!')),
      );

      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() {
        _isDeleting = false;
      });
      print('Error deleting warranty');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete warranty!')),
      );
    }
  }

  Future<void> showDeleteConfirmationDialog(BuildContext context) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure you want to delete?'),
          content: const Text('This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              onPressed: _isDeleting
                  ? null
                  : () {
                      Navigator.of(context).pop(true);
                    },
              child: _isDeleting
                  ? const CircularProgressIndicator(
                      color: Colors.black12, strokeWidth: 2)
                  : const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      deleteWarranty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: warranty == null
            ? const Text('Warranty Details')
            : Text(warranty['productName'] ?? 'Warranty Details'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDeleteConfirmationDialog(context);
            },
          ),
        ],
      ),
      body: warranty == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  // Carousel for displaying product, warranty, and receipt images
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: CarouselSlider.builder(
                      options: CarouselOptions(
                        height: 400,
                        enlargeCenterPage: true,
                        viewportFraction: 0.7,
                        enlargeStrategy: CenterPageEnlargeStrategy.height,
                        onPageChanged: (index, reason) {
                          setState(() {
                            activeIndex = index;
                          });
                        },
                      ),
                      itemCount: warranty['productPhoto'] != null ? 3 : 0,
                      itemBuilder: (context, index, realIndex) {
                        final List<String> images = [
                          warranty['productPhoto'] ?? '',
                          warranty['warrantyCardPhoto'] ?? '',
                          warranty['receiptPhoto'] ?? '',
                        ];
                        return buildImage(images[index]);
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Page indicator
                  buildIndicator(activeIndex),

                  const SizedBox(height: 30),

                  // Warranty details below carousel
                  Expanded(
                    child: ListView(
                      children: [
                        buildDetailRow(
                            'Purchase Date:',
                            warranty['purchaseDate'] != null
                                ? formatDate(warranty['purchaseDate'])
                                : 'Invalid Date'),
                        buildDetailRow('Warranty Duration:',
                            '${warranty['warrantyDuration']} ${warranty['warrantyDurationUnit']}'),
                        buildDetailRow(
                            'Warranty Expiry:',
                            warranty['warrantyEndDate'] != null
                                ? formatDate(warranty['warrantyEndDate'])
                                : 'Invalid Date'),
                        buildDetailRow('Status:', warranty['status'] ?? 'N/A'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
