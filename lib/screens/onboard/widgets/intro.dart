import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class Intro extends StatefulWidget {
  final VoidCallback onGetStarted;
  const Intro({super.key, required this.onGetStarted});

  @override
  _IntroState createState() => _IntroState();
}

const brightYellow = Color(0xFFFFFFFF);
const darkYellow = Color(0xFFFFB900);

class _IntroState extends State<Intro> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brightYellow,
      body: Column(
        children: [
          const Flexible(
              flex: 8,
              child: Center(
                child: RiveAnimation.asset(
                  'assets/rive/savings.riv',
                ),
              )),
          SizedBox(
            width: 250.0,
            child: DefaultTextStyle(
              style: const TextStyle(
                  fontSize: 30.0, fontFamily: 'Bobbers', color: Colors.black),
              child: AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText('Control your spending,'),
                  TyperAnimatedText('Grow your savings,'),
                  TyperAnimatedText(
                      "Living your dreams isn't enough—plan for them."),
                  TyperAnimatedText('- JB Pratt'),
                ],
                isRepeatingAnimation: true,
                repeatForever: true,
              ),
            ),
          ),
          Spacer(),
          Flexible(
            flex: 2,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: darkYellow,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              onPressed:
                  widget.onGetStarted,
              child: const Text(
                'Get Started',
                style: TextStyle(color: Colors.black54),
              ), // Accessing onGetStarted through widget
            ),
          ),
        ],
      ),
    );
  }
}
