import 'package:epic_dice_events/Authenticate.dart';
import 'package:epic_dice_events/CustomWidgets.dart';
import 'package:epic_dice_events/Validation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Authentication.dart';
import 'package:flutter/material.dart';
import 'Errors.dart';

class SignUpPage extends StatefulWidget {

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
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
      appBar: CustomAppBar(title: "EpicDiceEvents"),
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
                  basicTextField(Key('nume utilizator'), _usernameController, ' Nume Utilizator'),
                  SizedBox(height: 20,),
                  basicTextField(Key('email'), _emailController, ' Email'),
                  SizedBox(height: 20,),
                  basicTextField(Key('parola'), _passwordController, ' Parola'),
                  SizedBox(height: 20,),
                  basicTextField(Key('parola repetata'), _repeatPasswordController, ' Repeta Parola'),
                  SizedBox(height: 20,),
                  basicTextField( Key('localitate'), _cityController, ' Localitate'),
                  SizedBox(height: 40),
                  ElevatedButton(
                    key: Key("SignUpButton"),
                    onPressed: () async {
                      _handleSingUpIntoApp();
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
                      width: 130.0,
                      height: 50.0,
                      alignment: Alignment.center,
                      child: Text(
                        'Înregistrare',
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
                          style: customShadowTextStyle(),
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
  Future<void> _handleSingUpIntoApp() async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String repeat_password = _repeatPasswordController.text;
    String city = _cityController.text;

    if (!validateUsername(username) || !validatePassword(password)) {
      showIncorectLenghtError(context);
      return;
    }
    else if (!validateEmail(email)) {
      showIncorectEmailError(context);
    }
    else if (validatePasswordRetype(password, repeat_password)) {
      showIncorectPasswordRetyped(context);
      return;
    }
    else {
      User? result = await _auth.registerNewUser(email, password);

      if (result == null) {
        setState(() =>
        errorMessage = 'Date invalide sau Utilizator deja existent');
      }
      else {
        _auth.addNewUserToDatabase(username, email, city);
        _auth.signOut();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Authenticate()),
              (Route<
              dynamic> route) => false, // Elimină toate paginile anterioare
        );
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Un email de confirmare a fost trimis la adresa introdusă',
                style: customSnackBoxTextStyle(20, Colors.white),
              ),
              backgroundColor: Colors.orangeAccent,
            )
        );
      }
    }
  }
}

