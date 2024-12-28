import 'package:flutter/material.dart';
import 'package:warranti_app/api/google_signin_api.dart';
import 'package:warranti_app/service/token_service.dart';
import 'package:warranti_app/service/user_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> user = {};
  final UserService userService = UserService();

  @override
  void initState() {
    super.initState();
    setUserData();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: logoutUser,
            child: const Text("Logout"),
          ),
        ],
      ),
      body: user.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(user['profilePicture']),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    'Name: ${user['username']}',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Email: ${user['email']}',
                  ),
                ],
              ),
            ),
    );
  }

  // void fetchUser() async {
  //   try {
  //     String? token = await getToken();

  //     if (token == null) {
  //       print('No token found');
  //       return;
  //     }

  //     final response = await http.get(
  //       Uri.parse('https://warranti-backend.onrender.com/user/profile'),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //         'Authorization': token,
  //       },
  //     );
  //     if (response.statusCode == 200) {
  //       final body = response.body;
  //       final json = jsonDecode(body);

  //       setState(() {
  //         user = json;
  //       });
  //     } else {
  //       print(
  //           'Failed to load user profile, Status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error fetching user: $e');
  //   }
  // }

  void logoutUser() async {
    try {
      await deleteToken();
      await GoogleSigninApi.logout();
      Navigator.of(context).pushNamed('/signin');
    } catch (e) {
      print('Error logging out: $e');
    }
  }
}
