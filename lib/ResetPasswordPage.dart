import 'package:epic_dice_events/Authenticate.dart';
import 'package:epic_dice_events/Validation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'CustomWidgets.dart';

class ResetPasswordPage extends StatefulWidget {

  @override
  _ResetPasswordPage createState() => _ResetPasswordPage();
}

class _ResetPasswordPage extends State<ResetPasswordPage> {

  TextEditingController emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(
        title: 'Resetare Parola',
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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20,
                ),
                TextField(
                  key: Key("EmailForPasswordReset"),
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: "Introduceti email"
                  ),
                ),
                SizedBox(
                  height: 100,
                ),
                ElevatedButton(
                    onPressed: (){
                      sendEmailForResetPassword(emailController.text);
                    },
                    child: Text(
                      "Trimite",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28.0,
                        color: Colors.black,
                      ),
                    ),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Future<void> sendEmailForResetPassword(String emailAddress) async{
    try{
      if(validateEmail(emailAddress)){
        await _auth.sendPasswordResetEmail(email: emailAddress);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Authenticate()),
              (Route<dynamic> route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Un email a fost trimis la adresa introdusa',
                style: customSnackBoxTextStyle(20, Colors.white),
              ),
              backgroundColor: Colors.orangeAccent,
            )
        );
      }
      else{
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Authenticate()),
              (Route<dynamic> route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Email-ul introdus nu este valid',
                style: customSnackBoxTextStyle(20, Colors.white),
              ),
              backgroundColor: Colors.orangeAccent,
            )
        );
      }
    }catch(e){
      throw("Eroare la trimitere email: $e");
    }
  }
}

