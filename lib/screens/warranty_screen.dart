import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:warranti_app/service/warranties_service.dart';

class WarrantyScreen extends StatefulWidget {
  final String id;
  const WarrantyScreen({super.key, required this.id});

  @override
  State<WarrantyScreen> createState() => _WarrantyScreenState();
}

class _WarrantyScreenState extends State<WarrantyScreen> {
  dynamic warranty;
  bool _isDeleting = false;

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
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // Purchase Date
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Purchase Date:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        warranty['purchaseDate'] != null
                            ? formatDate(warranty['purchaseDate'])
                            : 'Invalid Date',
                        style: const TextStyle(fontSize: 16),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Warranty Duration
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Warranty Duration:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${warranty['warrantyDuration']} ${warranty['warrantyDurationUnit']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Warranty End Date
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Warranty Expiry:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        warranty['warrantyEndDate'] != null
                            ? formatDate(warranty['warrantyEndDate'])
                            : 'Invalid Date',
                        style: const TextStyle(fontSize: 16),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Warranty Status
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        warranty['status'] ?? 'N/A',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Product Image
                  if (warranty['productPhoto'] != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Product Image:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Image.network(
                          warranty['productPhoto'],
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  const SizedBox(height: 10),

                  // Warranty Card Image
                  if (warranty['warrantyCardPhoto'] != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Warranty Card Image:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Image.network(
                          warranty['warrantyCardPhoto'],
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  const SizedBox(height: 10),

                  // Receipt Image
                  if (warranty['receiptPhoto'] != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Receipt Image:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Image.network(
                          warranty['receiptPhoto'],
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}
