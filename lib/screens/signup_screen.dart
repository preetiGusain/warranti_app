import 'package:flutter/material.dart';
import 'package:warranti_app/screens/signin_screen.dart';
import 'package:warranti_app/service/auth_service.dart';
import 'package:warranti_app/theme/theme.dart';
import 'package:warranti_app/widgets/custom_scaffold.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formSignUpKey = GlobalKey<FormState>();

  String username = '';
  String email = '';
  String password = '';
  bool _isGoogleLoading = false;
  bool _isSignupLoading = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: CustomScaffold(
        child: Column(
          children: [
            const Expanded(flex: 1, child: SizedBox(height: 10)),
            Expanded(
              flex: 7,
              child: Container(
                padding: const EdgeInsets.fromLTRB(25, 50, 25, 20),
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(255, 255, 255, 0.95),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.0),
                    topRight: Radius.circular(40.0),
                    bottomLeft: Radius.circular(40.0),
                    bottomRight: Radius.circular(40.0),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formSignUpKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: lightColorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 25.0),
      
                        // Google signup button (simplified to match SigninScreen)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.all(10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              side: const BorderSide(color: Colors.grey),
                            ),
                            icon: _isGoogleLoading
                                ? const CircularProgressIndicator(
                                    color: Color.fromARGB(255, 130, 77, 160),
                                    strokeWidth: 3)
                                : Image.asset('assets/images/google_logo.png',
                                    height: 18),
                            label: Text(
                              'Sign up with Google',
                              style: TextStyle(
                                fontSize: 16,
                                color: lightColorScheme.primary,
                              ),
                            ),
                            onPressed: () async {
                              if (_isGoogleLoading) return;
                              setState(() => _isGoogleLoading = true);
                              bool success =
                                  await AuthService.signInWithGoogle(context);
                              setState(() => _isGoogleLoading = false);
                              if (!success) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text('Google sign-up failed!'),
                                  backgroundColor: Colors.red,
                                ));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Signed up with Google!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
      
                        const SizedBox(height: 20.0),
      
                        Text(
                          'Or sign up with Email and Password',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: lightColorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 15.0),
      
                        // Full name
                        TextFormField(
                          onChanged: (value) {
                            setState(() {
                              username = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            label: const Text('Full Name'),
                            hintText: 'Enter Full Name',
                            hintStyle: const TextStyle(color: Colors.black26),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
      
                        // Email
                        TextFormField(
                          onChanged: (value) {
                            setState(() {
                              email = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Email';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            label: const Text('Email'),
                            hintText: 'Enter Email',
                            hintStyle: const TextStyle(color: Colors.black26),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25.0),
      
                        // Password
                        TextFormField(
                          obscureText: true,
                          obscuringCharacter: '*',
                          onChanged: (value) {
                            setState(() {
                              password = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Password';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            label: const Text('Password'),
                            hintText: 'Enter Password',
                            hintStyle: const TextStyle(color: Colors.black26),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12),
                            ),
                          ),
                        ),
      
                        const SizedBox(height: 40.0),
      
                        // Sign-up button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSignupLoading
                                ? null
                                : () async {
                                    if (_formSignUpKey.currentState?.validate() ??
                                        false) {
                                      setState(() {
                                        _isSignupLoading = true;
                                      });
                                      final (success, message) = await AuthService
                                          .signUpWithEmailPassword(
                                        username,
                                        email,
                                        password,
                                        context,
                                      );
                                      setState(() {
                                        _isSignupLoading = false;
                                      });
                                      if (!success) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(message),
                                          backgroundColor: Colors.red,
                                        ));
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(message),
                                          backgroundColor: Colors.green,
                                        ));
                                      }
                                    }
                                  },
                            child: _isSignupLoading
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: const CircularProgressIndicator(
                                      color: Color.fromARGB(255, 130, 77, 160),
                                    ),
                                  )
                                : const Text("Sign up"),
                          ),
                        ),
      
                        const SizedBox(height: 25.0),
      
                        // Divider with "or" style
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 0.7,
                                color: Colors.grey.withOpacity(0.5),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 0.7,
                                color: Colors.grey.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25.0),
      
                        // Already have an account link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account?',
                              style: TextStyle(color: Colors.black45),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (e) => const SigninScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Sign In',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: lightColorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
