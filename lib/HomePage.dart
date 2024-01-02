import 'package:epic_dice_events/Drawler.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Center(
          child: Text(
            'EpicDiceEvents',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30.0,
              color: Colors.white, // Culoarea textului
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.orangeAccent,
                  offset: Offset(0, 0),
                ),
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.orangeAccent,
                  offset: Offset(0, 0),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 100, // Elimină umbra sub AppBar
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/Color.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
      drawer: MyDrawer(),
    );
  }
}