import 'package:epic_dice_events/MyApp.dart';
import 'package:epic_dice_events/ProfilePage.dart';
import 'package:flutter/material.dart';
import 'AboutPage.dart';
import 'Authentication.dart';
import 'CustomWidgets.dart';
import 'RecommendationPage.dart';

class DrawerButton extends StatelessWidget{
  final String buttonName;
  final Future<void> Function()? action;
  final Widget pageNavigator;
  final Icon iconButton;

  const DrawerButton({
    Key? key,
    required this.buttonName,
    this.action,
    required this.pageNavigator,
    required this.iconButton,
  }): super(key: key);

  Widget build(BuildContext context){
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: InkWell(
          onTap: () async {
            await action?.call();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => pageNavigator),
            );

          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                buttonName,
                style: customBasicTextStyle(14.0, true),
              ),
              IconButton(
                icon: iconButton,
                onPressed: () async{
                  await action?.call();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => pageNavigator),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyDrawer extends StatelessWidget {

  final AuthenticationService _auth = new AuthenticationService();


  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 160.00,
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
          DrawerButton(key: Key('ProfileButton'), buttonName: 'Profil            ', iconButton: Icon(Icons.person), pageNavigator: ProfilePage()),
          DrawerButton(key: Key('SuggestionButton'), buttonName: "Sugestie      ", iconButton: Icon(Icons.recommend), pageNavigator: RecommendationPage()),
          DrawerButton(key: Key('AboutButton'), buttonName: 'Despre         ', iconButton: Icon(Icons.question_mark), pageNavigator: AboutPage()),
          DrawerButton(key: Key('LogOutButton'), buttonName: 'Deconectare', action: () async{await _auth.signOut();}, iconButton: Icon(Icons.logout), pageNavigator: MyApp()),
        ],
      ),
    );
  }
}
