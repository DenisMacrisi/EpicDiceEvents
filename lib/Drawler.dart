import 'package:epic_dice_events/MyApp.dart';
import 'package:epic_dice_events/ProfilePage.dart';
import 'package:flutter/material.dart';
import 'Authentication.dart';
import 'CustomWidgets.dart';
import 'RecommendationPage.dart';
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
                image: DecorationImage(
                  image: AssetImage('images/Color.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Text(
                'Meniu',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30.0,
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
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: InkWell(
                onTap: () async {
                 // print('Text or icon pressed');
                  // Redirectionare catre Profil
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );

                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Profil          ',
                      style: customBasicTextStyle(14.0, true),
                    ),
                    IconButton(
                      icon: Icon(Icons.person),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProfilePage()),
                        );
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyApp()),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Logout        ',
                      style: customBasicTextStyle(14.0, true),
                    ),
                    IconButton(
                      icon: Icon(Icons.logout),
                      onPressed: () async {
                        await _auth.signOut();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyApp()),
                        );
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RecommendationPage()),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        "Sugestie      ",
                      style: customBasicTextStyle(14.0, true),
                    ),
                    IconButton(
                      icon: Icon(Icons.recommend),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RecommendationPage()),
                        );
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyApp()),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ' About         ',
                      style: customBasicTextStyle(14.0, true),
                    ),
                    IconButton(
                      icon: Icon(Icons.question_mark),
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
