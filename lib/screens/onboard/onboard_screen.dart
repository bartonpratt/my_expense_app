import 'package:penniverse/screens/onboard/widgets/intro.dart';
import 'package:penniverse/screens/onboard/widgets/profile.dart';
import 'package:flutter/material.dart';


class OnboardScreen extends StatelessWidget {
  OnboardScreen({super.key});
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [

          Intro(onGetStarted: (){
            _pageController.animateToPage(1,duration: const Duration(milliseconds: 350), curve: Curves.easeIn);
          }),

          const ProfileWidget(),
        ],
      ),
    );
  }
}
