import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:warranti_app/api/google_signin_api.dart';
import 'package:warranti_app/constants.dart';
import 'package:warranti_app/service/navigator_service.dart';
import 'package:warranti_app/service/token_service.dart';
import 'package:warranti_app/service/user_service.dart';
import 'package:warranti_app/service/warranties_service.dart';
import 'package:intl/intl.dart';
import 'package:warranti_app/widgets/connection_checker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> user = {};
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
      Map<String, dynamic>? storedUser = await UserService.getStoredUser();

      if (storedUser != null) {
        print("User fetched from storage: $storedUser");
        setState(() {
          user = storedUser!;
          isUserLoading = false;
          print("Fetched user data: $user");
        });
      } else {
        print("No user data in storage, fetching from API...");
        await UserService.fetchUser();
        storedUser = await UserService.getStoredUser();
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

  void refreshWarranties() {
    setWarranties();
  }

  void logoutUser() async {
    setState(() {
      isLogoutLoading = true;
    });

    try {
      await TokenService.deleteToken();
      await UserService.deleteUserData();
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

      NavigatorService.pushNamed('/login');
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

  void _openPrivacyPolicy() async {
    final Uri url = Uri.parse(privacyPolicyUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      print("Could not launch $privacyPolicyUrl");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open Privacy Policy")),
      );
    }
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.power_settings_new,
                size: 40,
                color: Color.fromARGB(255, 133, 91, 176),
              ),
              const SizedBox(height: 20),
              const Text(
                "Are you sure you want to quit?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF7E57C2)),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(100, 48),
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                  child:
                      const Text("No", style: TextStyle(color: Colors.black)),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFF7E57C2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(100, 48),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Yes"),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        bool? shouldExit = await _showExitDialog(context);
        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: ConnectionChecker(
        onConnectionRestored: refreshWarranties,
        child: isUserLoading || isWarrantiesLoading
            ? Scaffold(
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
                ),
              )
            : Scaffold(
                key: _scaffoldKey,
                //appbar
                appBar: AppBar(
                  title: const Text('Warranties'),
                  automaticallyImplyLeading: false,
                  centerTitle: true,
                  actions: [
                    IconButton(
                      icon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: user.isNotEmpty &&
                                    user['profilePicture'] != null &&
                                    user['profilePicture'].isNotEmpty
                                ? NetworkImage(user['profilePicture'])
                                : null,
                            backgroundColor: user['profilePicture'] == null ||
                                    user['profilePicture'].isEmpty
                                ? Colors.blueGrey
                                : Colors.transparent,
                            child: user.isEmpty ||
                                    user['profilePicture'] == null ||
                                    user['profilePicture'].isEmpty
                                ? Text(
                                    user['username']?.isNotEmpty == true
                                        ? user['username'][0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  )
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
                        ],
                      ),
                      onPressed: () {
                        debugPrint('Profile icon pressed');
                        debugPrint(
                            'Profile Picture URL: ${user['profilePicture']}');
                        _scaffoldKey.currentState?.openEndDrawer();
                      },
                    ),
                  ],
                ),
                // Right Drawer
                endDrawer: Drawer(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: AbsorbPointer(
                    absorbing: isLogoutLoading,
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            UserAccountsDrawerHeader(
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 133, 91, 176),
                              ),
                              accountName: Text(user['username'] ?? 'Guest'),
                              accountEmail:
                                  Text(user['email'] ?? 'Not logged in'),
                              currentAccountPicture: CircleAvatar(
                                backgroundImage: user.isNotEmpty &&
                                        user['profilePicture'] != null &&
                                        user['profilePicture'].isNotEmpty
                                    ? NetworkImage(user['profilePicture'])
                                    : null,
                                backgroundColor:
                                    user['profilePicture'] == null ||
                                            user['profilePicture'].isEmpty
                                        ? Colors.blueGrey
                                        : Colors.transparent,
                                child: user.isEmpty ||
                                        user['profilePicture'] == null ||
                                        user['profilePicture'].isEmpty
                                    ? Text(
                                        user.isNotEmpty &&
                                                user['username'] != null
                                            ? user['username'][0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      )
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
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 30),
                          child: Column(
                            children: [
                              //Privacy policy button
                              SizedBox(
                                height: 60,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Color.fromARGB(255, 218, 198, 233),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 18, horizontal: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: _openPrivacyPolicy,
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.description,
                                          color: Colors.black),
                                      SizedBox(width: 8),
                                      Text('Privacy Policy',
                                          style:
                                              TextStyle(color: Colors.black)),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              //Logout button
                              SizedBox(
                                height: 60,
                                width: double.infinity,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor:
                                        const Color.fromARGB(255, 133, 91, 176),
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
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.logout,
                                                color: Colors.white),
                                            SizedBox(width: 8),
                                            Text('Logout',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                //body
                body: Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          await setWarranties();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Page refreshed!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        child: warranties.isEmpty
                            ? const Center(
                                child: Text('No warranties available'))
                            : ListView.builder(
                                itemCount: warranties.length,
                                itemBuilder: (context, index) {
                                  final warranty = warranties[index];

                                  final productName = warranty['productName'] ??
                                      'No Product Name';
                                  final purchaseDate =
                                      warranty['purchaseDate'] ??
                                          'No Purchase Date';
                                  final productPhoto =
                                      warranty['productPhoto'] ??
                                          'No Product Photo';
                                  final warrantyEndDate =
                                      warranty['warrantyEndDate'] ??
                                          'Invalid Date';

                                  DateTime endDate;
                                  try {
                                    endDate = DateTime.parse(warrantyEndDate);
                                  } catch (e) {
                                    endDate = DateTime.now();
                                  }

                                  DateTime now = DateTime.now();
                                  // Check if the warranty is expired
                                  bool isExpired = endDate.isBefore(now);

                                  // Determine the text and color based on the expiry status
                                  String statusText = isExpired
                                      ? 'Expired on:'
                                      : 'Valid until:';
                                  Color statusColor =
                                      isExpired ? Colors.red : Colors.green;

                                  return Card(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    margin: const EdgeInsets.all(10),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, '/warranty',
                                            arguments: warranty['_id']);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    'Purchased on ${formatDate(purchaseDate)}',
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  statusText,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: statusColor,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  formatDate(warrantyEndDate),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: statusColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
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
              ),
      ),
    );
  }
}
