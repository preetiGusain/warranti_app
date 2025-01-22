import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  const CustomScaffold({super.key, this.child});
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Image.asset(
            'assets/images/background.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration:  BoxDecoration(
                color: Colors.white.withOpacity(0.05), 
                borderRadius: const BorderRadius.all(Radius.circular(40.0)),
              ),
              padding:
                  const EdgeInsets.only(top: 20, bottom: 20), 
              child: SafeArea(
                top: false,
                child: child!,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
