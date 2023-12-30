import 'package:flutter/material.dart';

class LogInPage extends StatelessWidget {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Log In',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25.0,
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
        backgroundColor: Colors.transparent,
        elevation: 100,
      ),
      // Adăugați conținutul specific paginii LogIn aici
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
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: ' Nume Utilizator',
                    hintStyle: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontStyle: FontStyle.italic),
                    enabledBorder: UnderlineInputBorder(
                      borderSide:  BorderSide(color: Colors.orange.shade300,width: 1.5),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange.shade200,width: 3.0),
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: ' Parola',
                    hintStyle: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontStyle: FontStyle.italic),
                    enabledBorder: UnderlineInputBorder(
                      borderSide:  BorderSide(color: Colors.orange.shade300,width: 1.5),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange.shade200,width: 3.0),
                    ),
                  ),
                ),
                SizedBox(height: 50), // Adăugat un spațiu vertical între câmpuri
                ElevatedButton(
                  onPressed: () {
                    String username = _usernameController.text;
                    print("Username: $username");

                    print("Password: ${_passwordController.text}");
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
                        fontSize: 20.0,
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