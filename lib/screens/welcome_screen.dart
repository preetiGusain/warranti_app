import 'package:flutter/material.dart';
import 'package:warranti_app/widgets/custom_scaffold.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        child: Column(
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 40.0,
            ),
            child: Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  children: [
                    TextSpan(
                        text: "Warranti\n",
                        style: TextStyle(
                          fontSize: 45.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepPurple,
                        )),
                    TextSpan(
                      text: "\nStore, Track and Never Lose a Warranty Again.",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.deepPurple,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        const Flexible(
          child: Text("Signup"),
        )
      ],
    ));
  }
}
