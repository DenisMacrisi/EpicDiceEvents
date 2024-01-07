import 'package:flutter/material.dart';
import 'LogInPage.dart';
import 'SignInPage.dart';

class Authenticate extends StatelessWidget {
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
                ElevatedButton(
                  onPressed: () {
                    // Acțiunea pentru butonul de Log In
                    print('Buton Log In apăsat');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LogInPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.5),
                    ),
                    elevation: 10.0,
                    side: BorderSide(
                      color: Colors.orangeAccent,
                      width: 3.0,
                    ),
                  ),
                  child: Container(
                    width: 90.0,
                    height: 50.0,
                    alignment: Alignment.center,
                    child: Text(
                      'Log In',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28.0,
                        color: Colors.black, // Culoarea textului
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 50), // Spațiu între butoane
                ElevatedButton(
                  onPressed: () {
                    // Acțiunea pentru butonul de Sign In
                    print('Buton Sign In apăsat');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignInPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.5),
                    ),
                    elevation: 10.0,
                    side: BorderSide(
                      color: Colors.orangeAccent,
                      width: 3.0,
                    ),
                  ),
                  child: Container(
                    width: 90.0,
                    height: 50.0,
                    alignment: Alignment.center,
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28.0,
                        color: Colors.black, // Culoarea textului
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}