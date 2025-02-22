
import 'package:epic_dice_events/Authenticate.dart';
import 'package:epic_dice_events/Validation.dart';
import 'Authentication.dart';
import 'package:flutter/material.dart';
import 'Errors.dart';

class SignInPage extends StatefulWidget {

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _repeatPasswordController = TextEditingController();
  TextEditingController _cityController = TextEditingController();

  final AuthenticationService _auth = AuthenticationService();

  String errorMessage='';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Sign Up',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25.0,
            color: Colors.white,
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 80,),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: ' Nume Utilizator',
                      hintStyle: TextStyle(color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.orange.shade300, width: 1.5),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.orange.shade200, width: 3.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: ' Email',
                      hintStyle: TextStyle(color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.orange.shade300, width: 1.5),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.orange.shade200, width: 3.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: ' Parola',
                      hintStyle: TextStyle(color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.orange.shade300, width: 1.5),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.orange.shade200, width: 3.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextField(
                    controller: _repeatPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: ' Repeta Parola',
                      hintStyle: TextStyle(color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.orange.shade300, width: 1.5),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.orange.shade200, width: 3.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      hintText: ' Localitate',
                      hintStyle: TextStyle(color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.orange.shade300, width: 1.5),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.orange.shade200, width: 3.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () async {
                      String username = _usernameController.text;
                      String email = _emailController.text;
                      String password = _passwordController.text;
                      String repeat_password = _repeatPasswordController.text;
                      String city = _cityController.text;

                      if(!validateUsername(username) || !validatePassword(password)){
                        showIncorectLenghtError(context);
                        return;
                      }
                      else if(!validateEmail(email)){
                        showIncorectEmailError(context);
                      }
                      else if (validatePasswordRetype(password,repeat_password))
                      {
                        showIncorectPasswordRetyped(context);
                        return;
                      }
                      else
                      {
                        dynamic result = await _auth.registerNewUser(email,password);

                        if(result == null){

                          setState(() => errorMessage = 'Date invalide sau Utilizator deja existent' );
                        }
                        else{

                          _auth.addNewUserToDatabase(username, email, city);
                          _auth.signOut();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => Authenticate()),
                                (Route<dynamic> route) => false, // Elimină toate paginile anterioare
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Un email de confirmare al adresei a fost trimis',
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white
                                  ),
                                ),
                                backgroundColor: Colors.orangeAccent,
                              )
                          );
                        }

                      }

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
                          fontSize: 20.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 5.00,),
                  Visibility(
                      visible: errorMessage.length > 1,
                      child: Container(
                        padding: EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(5,140 ,250 , 50),
                        ),
                        child: Text(
                          errorMessage,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.00,
                            shadows: [
                              Shadow(
                                blurRadius: 15.0,
                                color: Colors.orangeAccent,
                                offset: Offset(0, 0),
                              ),
                              Shadow(
                                blurRadius: 15.0,
                                color: Colors.orangeAccent,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                      )
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

