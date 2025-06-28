import 'package:epic_dice_events/CustomWidgets.dart';
import 'package:epic_dice_events/HomePage.dart';
import 'package:epic_dice_events/ResetPasswordPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Authentication.dart';


class LogInPage extends StatefulWidget {

  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  final AuthenticationService _auth = AuthenticationService();

  String errorMessage='';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(title: "EpicDiceEvents"),
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
                  SizedBox(
                    height: 80,
                  ),
                  basicTextField(Key('EmailField'), _emailController, ' Email'),
                  SizedBox(height: 20,),
                  basicTextField(Key('ParolaField'), _passwordController, ' Parola'),
                  SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: () async {
                      await _handleLogInIntoApp(_emailController, _passwordController);
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
                      width: 120.0,
                      height: 50.0,
                      alignment: Alignment.center,
                      child: Text(
                        'Conectare',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 5,),
                  Visibility(
                      visible: errorMessage.length > 1,
                      child: Container(
                        padding: EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(5,140 ,250 , 250),
                        ),
                        child: Text(
                          errorMessage,
                          style: customShadowTextStyle(),
                        ),
                      )
                  ),
                  SizedBox(height: 50),
                  CustomGoToElevatedButton(key:Key("ResetPasswordButton"),title: 'Resetare Parola', widthSize: 180, heightSize: 40, fontSize: 18.0, targetPage: ResetPasswordPage()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogInIntoApp(TextEditingController emailController, TextEditingController passwordController) async {
    String email = emailController.text;
    String password = passwordController.text;

    User? result = await _auth.logIn(email,password);

    if(result == null){
      setState(() => errorMessage = 'Email sau Parola Incorecte' );
      _auth.signOut();
    }
    else{
      if (!result.emailVerified) {
        setState(() => errorMessage = 'Email de validare retrimis');
        await result.sendEmailVerification();
        _auth.signOut();
      }
      else{
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    }
  }
}