import 'package:epic_dice_events/Authenticate.dart';
import 'package:epic_dice_events/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'CustomUser.dart';
import 'HomePage.dart';

class Wrapper extends StatelessWidget{
  Widget build(BuildContext context){

    final user = Provider.of<CustomUser?>(context);
    print(user);

    /// HomePage or Authenticate
    if (user == null) {
        return Authenticate();
    }
    else{
      return HomePage();
    }
  }
}