import 'package:epic_dice_events/CustomWidgets.dart';
import 'package:flutter/material.dart';
import 'LogInPage.dart';
import 'SignUpPage.dart';

class Authenticate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(
        title: 'EpicDiceEvents',
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 125),
                CustomGoToElevatedButton(title: 'Log In', widthSize: 110.0, heightSize: 60.0, fontSize: 28.0, targetPage: LogInPage()),
                SizedBox(height: 50),
                CustomGoToElevatedButton(title: 'Sign Up', widthSize: 110.0, heightSize: 60.0, fontSize: 28.0, targetPage: SignUpPage()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}