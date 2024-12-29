import 'package:flutter/material.dart';
import 'package:warranti_app/api/google_signin_api.dart';
import 'package:warranti_app/service/token_service.dart';
import 'package:warranti_app/service/user_service.dart';
import 'package:warranti_app/service/warranties_service.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> user = {};
  final UserService userService = UserService();
  List<dynamic> warranties = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    setUserData();
    setWarranties();
  }

  Future<void> setUserData() async {
    try {
      Map<String, dynamic>? storedUser = await userService.getStoredUser();

      if (storedUser != null) {
        setState(() {
          user = storedUser!;
          print("Fetched user data: $user");
        });
      } else {
        await userService.fetchUser();
        storedUser = await userService.getStoredUser();
        if (storedUser != null) {
          setState(() {
            user = storedUser!;
            print("Fetched user data: $user");
          });
        }
      }
    } catch (e) {
      print('Error setting user data: $e');
    }
  }

  Future<void> setWarranties() async {
    try {
      final fetchedWarranties = await WarrantiesService.fetchWarranties();
      setState(() {
        warranties = fetchedWarranties;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching warranties: $e');
    }
  }

  void logoutUser() async {
    try {
      await deleteToken();
      await GoogleSigninApi.logout();
      Navigator.of(context).pushNamed('/signin');
    } catch (e) {
      print('Error logging out: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warranties'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: CircleAvatar(
              radius: 18,
              backgroundImage:
                  user.isNotEmpty ? NetworkImage(user['profilePicture']) : null,
              child: user.isEmpty ? const Icon(Icons.person) : null,
            ),
            onPressed: () {},
          ),
          TextButton(
            onPressed: logoutUser,
            child: const Text("Logout"),
          ),
        ],
      ),
      body: user.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: warranties.length,
                          itemBuilder: (context, index) {
                            final warranty = warranties[index];

                            final productName =
                                warranty['productName'] ?? 'No Product Name';
                            final purchaseDate =
                                warranty['purchaseDate'] ?? 'No Purchase Date';
                            final warrantyDuration =
                                warranty['warrantyDuration'] ?? 'No Duration';
                            final warrantyDurationUnit =
                                warranty['warrantyDurationUnit'] ??
                                    'No Duration Unit';
                            final productPhoto =
                                warranty['productPhoto'] ?? 'No Product Photo';
                            final status = warranty['status'] ?? 'No Status';

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  productPhoto,
                                  width: 60, 
                                  height: 60, 
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(
                                productName,
                                style: const TextStyle(
                                  fontSize:
                                      20, 
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Purchased on: ${formatDate(purchaseDate)}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    'Warranty Duration: $warrantyDuration $warrantyDurationUnit',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    'Status: $status',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
