import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:stock_price_forecasting_for_msx/screens/intro_screens/intro_page01.dart';
import 'package:stock_price_forecasting_for_msx/screens/intro_screens/intro_page02.dart';
import 'package:stock_price_forecasting_for_msx/screens/intro_screens/intro_page03.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {

  final PageController _controller = PageController();

  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
        PageView(
          controller: _controller,
          onPageChanged: (index) {
            setState(() {
              onLastPage = (index == 2);
            });
          },
          children: const [
            IntroPage01(),
            IntroPage02(),
            IntroPage03()
          ],
        ),
        Container(
          alignment: const Alignment(0,0.80),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              onLastPage
              ? const SizedBox.shrink()
              : GestureDetector(
                onTap: () {
                  _controller.jumpToPage(2);
                },
                child: const Text('Skip')),

              SmoothPageIndicator(controller: _controller, count: 3, 
              effect: WormEffect(
              dotHeight: 16,
              dotWidth: 16,
              activeDotColor: Colors.pinkAccent.shade400, // Color for the active dot
              dotColor: Colors.grey, // Color for inactive dots
              ),
              ),

              onLastPage
              ? GestureDetector(
                onTap: (){
                  Navigator.pushNamedAndRemoveUntil(context, '/mainscaffold', (Route<dynamic> route) => false);
                },
                child: const Text('Done'),
                )
              : GestureDetector(
                onTap: (){
                  _controller.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
                },
                child: const Text('Next'),
                ),
            ],
          ))
        ],
      ),
    );
  }
}