
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

void showIncorectLenghtError(BuildContext context){
  showSimpleError(context,'Format Incorect', 'Numele si Parola trebuie sa aiba minim 5 caractere');
}
void showAlreadyRegistatedforEvent(BuildContext context){
  showSimpleError(context,'Participant', 'Deja te-ai inscris pentru acest Eveniment');
}
void showAlreadyUnRegistatedforEvent(BuildContext context){
  showSimpleError(context,'Retras', 'Deja te-ai retras din acest Eveniment');
}
void showIncompleteDataError(BuildContext context){
  showSimpleError(context, 'Date Incomplete', 'Nu ai completat toate câmpurile necesare');
}
void showSelectedDateError(BuildContext context){
  showSimpleError(context,'Nepotrivire Date' ,'Data de inceput nu poate fi mai mare decat data de final');
}
