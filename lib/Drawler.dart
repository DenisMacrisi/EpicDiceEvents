import 'package:epic_dice_events/Authenticate.dart';
import 'package:epic_dice_events/MyApp.dart';
import 'package:flutter/material.dart';
import 'Authentication.dart';
import 'HomePage.dart';
class MyDrawer extends StatelessWidget {

  final AuthenticationService _auth = new AuthenticationService();


  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 150.00,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 120.00,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromRGBO(3, 230, 230, 100),
              ),
              child: Text(
                'Meniu',
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 30,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: InkWell(
                onTap: () async {
                  print('Text or icon pressed');
                  /* Redirectionare catre Profil
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Profile()),
                  );
                   */
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Profil          ',
                    ),
                    IconButton(
                      icon: Icon(Icons.person),
                      onPressed: () {
                        // Acțiuni pentru butonul de utilizator
                        //print('User icon pressed');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: InkWell(
                onTap: () async {

                  await _auth.signOut();
                  print('Text or icon pressed');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyApp()),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Logout          ',
                    ),
                    IconButton(
                      icon: Icon(Icons.logout),
                      onPressed: () {
                        // Acțiuni pentru butonul de utilizator
                        //print('User icon pressed');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
