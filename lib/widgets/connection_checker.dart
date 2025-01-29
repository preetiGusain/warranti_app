import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectionChecker extends StatefulWidget {
  final Widget child;
  final VoidCallback? onConnectionRestored;

  const ConnectionChecker({super.key, required this.child, this.onConnectionRestored});

  @override
  State<ConnectionChecker> createState() => _ConnectionCheckerState();
}

class _ConnectionCheckerState extends State<ConnectionChecker> {
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool isOffline = false;
  bool wasOffline = false; // Track previous state for transitions
  bool isFetchingData = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();

    // Subscribe to the connectivity changes stream and listen for the first result in the list
    _subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;

      setState(() {
        isOffline = result == ConnectivityResult.none;
      });

      // Check if the internet has been restored and we were offline previously
      if (!isOffline && wasOffline) {
        _showConnectionRestored();
      }

      // Update the offline state flag
      wasOffline = isOffline;
    });
  }

  // Function to check initial connectivity status
  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      isOffline = result == ConnectivityResult.none;
    });

    // Set initial offline state flag
    wasOffline = isOffline;
  }

  @override
  void dispose() {
    _subscription.cancel(); // Always cancel the subscription
    super.dispose();
  }

  // Function to show the "Connection Restored" message
  Future<void> _showConnectionRestored() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connection Restored!'),
        backgroundColor: Colors.green,
      ),
    );

    // Call the onConnectionRestored callback if it is provided
    if (widget.onConnectionRestored != null) {
      widget.onConnectionRestored!();
    }

    // Simulate fetching data or any other loading behavior
    setState(() {
      isFetchingData = true;
    });

    // Simulate data fetching delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isFetchingData = false; // Hide loading indicator after delay
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child, // Your main widget child
        if (isOffline) _buildNoInternetPage(), // Show the "No Internet" page when offline
        if (isFetchingData) _buildLoader(), // Show loader when fetching data
      ],
    );
  }

  // Widget for the "No Internet" page
  Widget _buildNoInternetPage() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.wifi_off,
              size: 80,
              color: Colors.black26,
            ),
            SizedBox(height: 20),
            Text(
              "No Internet Connection",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              "Oops! It seems you're offline. Please check your connection or try again later.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  // Loader widget for fetching data
  Widget _buildLoader() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
