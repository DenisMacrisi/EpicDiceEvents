import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Meniu Lateral',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: Text('Opțiune 1'),
            onTap: () {
              // Adăugați acțiunile pentru opțiunea 1
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Opțiune 2'),
            onTap: () {
              // Adăugați acțiunile pentru opțiunea 2
              Navigator.pop(context);
            },
          ),
          // ... adăugați mai multe opțiuni după nevoie
        ],
      ),
    );
  }
}
