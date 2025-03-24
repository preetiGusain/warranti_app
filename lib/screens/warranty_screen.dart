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
  int activeIndex = 0;

  @override
  void initState() {
    super.initState();
    // Access the id here using widget.id
    debugPrint('Warranty ID: ${widget.id}');
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
        warranty = null;
      });

      await WarrantiesService.deleteWarranty(widget.id);

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Warranty deleted successfully!')),
      );

      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() {});
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
        bool isDeleting = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              title: const Text('Are you sure you want to delete?'),
              content: const Text('This action cannot be undone.'),
              actionsAlignment: MainAxisAlignment.center,
              actions: <Widget>[
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF7E57C2)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(100, 48),
                    foregroundColor: isDeleting ? Colors.grey : Colors.black,
                  ),
                  onPressed: isDeleting
                      ? null
                      : () => Navigator.of(context).pop(false),
                  child: const Text('No'),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor:
                        isDeleting ? Colors.grey : const Color(0xFF7E57C2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(100, 48),
                  ),
                  onPressed: isDeleting
                      ? null
                      : () async {
                          setState(() => isDeleting = true);
                          await Future.delayed(const Duration(seconds: 2));

                          if (context.mounted) {
                            Navigator.of(context).pop(true);
                          }
                        },
                  child: isDeleting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
    );

    // Call deleteWarranty() if user confirms
    if (confirmed == true) {
      await deleteWarranty();
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
          : SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    // Carousel for displaying product, warranty, and receipt images
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: CarouselSlider.builder(
                        options: CarouselOptions(
                          height: 450,
                          enlargeCenterPage: true,
                          viewportFraction: 0.98,
                          enlargeStrategy: CenterPageEnlargeStrategy.height,
                          onPageChanged: (index, reason) {
                            setState(() {
                              activeIndex = index;
                            });
                          },
                          enableInfiniteScroll: false,
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
            
                    const SizedBox(height: 20),
            
                    // Warranty details below carousel
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: buildDetailRow(
                                'Purchase Date:',
                                warranty['purchaseDate'] != null
                                    ? formatDate(warranty['purchaseDate'])
                                    : 'Invalid Date',
                              ),
                            ),
                            Expanded(
                              child: buildDetailRow(
                                'Warranty Duration:',
                                '${warranty['warrantyDuration']} ${warranty['warrantyDurationUnit']}',
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: buildDetailRow(
                                'Warranty Expiry:',
                                warranty['warrantyEndDate'] != null
                                    ? formatDate(warranty['warrantyEndDate'])
                                    : 'Invalid Date',
                              ),
                            ),
                            Expanded(
                              child: buildDetailRow(
                                'Status:',
                                '',
                                icon: Icon(
                                  DateTime.parse(warranty['warrantyEndDate'])
                                          .isAfter(DateTime.now())
                                      ? Icons.check_circle_outline
                                      : Icons.error_outline,
                                  color:
                                      DateTime.parse(warranty['warrantyEndDate'])
                                              .isAfter(DateTime.now())
                                          ? Colors.green
                                          : Colors.red,
                                          size: 30,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ),
    );
  }
}
