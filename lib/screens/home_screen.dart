import 'dart:async';

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
  bool isUserLoading = true;
  bool isWarrantiesLoading = true;
  bool isLogoutLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
        print("User fetched from storage: $storedUser");
        setState(() {
          user = storedUser!;
          isUserLoading = false;
          print("Fetched user data: $user");
        });
      } else {
        print("No user data in storage, fetching from API...");
        await userService.fetchUser();
        storedUser = await userService.getStoredUser();
        if (storedUser != null) {
          print("User fetched after API call: $storedUser");
          setState(() {
            user = storedUser!;
            isUserLoading = false;
            print("Fetched user data: $user");
          });
        }
      }
    } catch (e) {
      setState(() {
        isUserLoading = false;
      });
      print('Error setting user data: $e');
    }
  }

  Future<void> setWarranties() async {
    try {
      final fetchedWarranties = await WarrantiesService.fetchWarranties();
      setState(() {
        warranties = fetchedWarranties;
        isWarrantiesLoading = false;
      });
    } catch (e) {
      setState(() {
        isWarrantiesLoading = false;
      });
      print('Error fetching warranties: $e');
    }
  }

  void logoutUser() async {
    setState(() {
      isLogoutLoading = true;
    });

    try {
      await TokenService.deleteToken();
      await userService.deleteUserData();
      await GoogleSigninApi.logout();
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        isLogoutLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged out successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pushNamed('/signin');
    } catch (e) {
      setState(() {
        isLogoutLoading = false;
      });
      print('Error logging out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logout failed!'),
          backgroundColor: Colors.red,
        ),
      );
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
    if (isUserLoading || isWarrantiesLoading) {
      return Scaffold(
          appBar: AppBar(
            title: const Text('Warranties'),
            centerTitle: true,
          ),
          body: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Loading your warranties...'),
              ],
            ),
          ));
    }

    return Scaffold(
      key: _scaffoldKey,
      //appbar
      appBar: AppBar(
        title: const Text('Warranties'),
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Stack(clipBehavior: Clip.none, children: [
              CircleAvatar(
                radius: 18,
                backgroundImage:
                    user.isNotEmpty && user['profilePicture'] != null
                        ? NetworkImage(user['profilePicture'])
                        : null,
                child: user.isEmpty || user['profilePicture'] == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              if (isUserLoading)
                const Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color.fromARGB(255, 130, 77, 160),
                      ),
                    ),
                  ),
                ),
            ]),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      // Right Drawer
      endDrawer: Drawer(
        child: Column(
          children: [
            Stack(
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(user['username'] ?? 'Guest'),
                  accountEmail: Text(user['email'] ?? 'Not logged in'),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage:
                        user.isNotEmpty && user['profilePicture'] != null
                            ? NetworkImage(user['profilePicture'])
                            : null,
                    child: user.isEmpty || user['profilePicture'] == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      _scaffoldKey.currentState?.closeEndDrawer();
                    },
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Expanded(child: Container()),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
              child: SizedBox(
                height: 60,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 119, 63, 176),
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: isLogoutLoading
                      ? null
                      : () {
                          logoutUser();
                        },
                  child: isLogoutLoading
                      ? const CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Logout',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),

      //body
      body: Column(
        children: [
          Expanded(
            child: warranties.isEmpty
                ? const Center(child: Text('No warranties available'))
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

                      Color statusColor =
                          (status == 'Expired') ? Colors.red : Colors.green;

                      return Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(10),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/warranty',
                                arguments: warranty['_id']);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    productPhoto,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        productName,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Purchased on: ${formatDate(purchaseDate)}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        'Warranty Duration: $warrantyDuration $warrantyDurationUnit',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        '$status',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: statusColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create');
        },
        tooltip: 'Create Warranty',
        child: const Icon(Icons.add),
      ),
    );
  }
}
