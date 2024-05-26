// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class Intro extends StatefulWidget {
  final VoidCallback onGetStarted;
  const Intro({super.key, required this.onGetStarted});

  @override
  _IntroState createState() => _IntroState();
}

const white = Color(0xFFFFFFFF);
const darkYellow = Color(0xFFFFB900);

class _IntroState extends State<Intro> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Flexible(
            flex: 5,
            child: Center(
              child: ClipOval(
                child: SizedBox(
                  width: 300.0, // Specify the desired width
                  height: 300.0, // Specify the desired height
                  child: RiveAnimation.asset(
                    'assets/rive/savings.riv',
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 250.0,
            child: DefaultTextStyle(
              style: const TextStyle(
                fontSize: 30.0,
                fontFamily: 'Bobbers',
                color: Colors.white,
              ),
              child: AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText('Control your spending,'),
                  TyperAnimatedText('Grow your savings,'),
                  TyperAnimatedText(
                    "Living your dreams isn't enough—plan for them.",
                  ),
                  TyperAnimatedText('- JB Pratt'),
                ],
                isRepeatingAnimation: true,
                repeatForever: true,
              ),
            ),
          ),
          const Spacer(),
          Flexible(
            flex: 2,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 4,
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              onPressed: widget.onGetStarted,
              child: const Text(
                'Get Started',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

