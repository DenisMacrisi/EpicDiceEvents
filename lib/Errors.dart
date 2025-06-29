
import 'package:epic_dice_events/Authenticate.dart';
import 'package:flutter/material.dart';

void showSimpleError(BuildContext context, String title, String contet){
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title,
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
        content: Text(contet,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
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
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
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
          ),
        ],
        backgroundColor: Color.fromRGBO(3, 220, 252,100),
      );
    },
  );
  return;
}


void showNetworkError(BuildContext context, String title, String contet){
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title,
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
        content: Text(contet,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
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
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Authenticate()),
              );
            },
            child: Text('OK',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
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
          ),
        ],
        backgroundColor: Color.fromRGBO(3, 220, 252,100),
      );
    },
  );
  return;
}

void showIncorectLenghtError(BuildContext context){
  showSimpleError(context,'Format Incorect', 'Numele si Parola trebuie sa aibă minim 5 caractere');
}
void showIncorectPasswordRetyped(BuildContext context){
  showSimpleError(context, 'Parola nu se potriveste', 'Parolele introduse sunt diferite');
}
void showIncorectEmailError(BuildContext context){
  showSimpleError(context, 'Email invalid', 'Adresa de email introdusă nu este validă');
}
void showAlreadyRegistatedforEvent(BuildContext context){
  showSimpleError(context,'Participant', 'Deja te-ai înscris pentru acest Eveniment');
}
void showAlreadyUnRegistatedforEvent(BuildContext context){
  showSimpleError(context,'Retras', 'Deja te-ai retras din acest Eveniment');
}
void showIncompleteDataError(BuildContext context){
  showSimpleError(context, 'Date Incomplete', 'Nu ai completat toate câmpurile necesare');
}
void showSelectedDateError(BuildContext context){
  showSimpleError(context,'Nepotrivire Date' ,'Data de început nu poate fi mai mare decât data de final');
}
void showNoConexionError(BuildContext context){
  showNetworkError(context, "Eroare Conexiune", "Nu există conexiune la internet");
}
