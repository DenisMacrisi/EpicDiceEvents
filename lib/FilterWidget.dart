import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'FilterPage.dart';

class FilterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50.0,
      height: 50.0,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(50.0),
        border: Border.all(
          color: Colors.orangeAccent,
          width: 5.0,
        ),
      ),
      child: Center(
        child: IconButton(
          icon: Icon(Icons.filter_list_alt,
            color: Colors.orangeAccent,
            size: 25.0,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FilterPage()),
            );
          },
        ),
      ),
    );
  }
}
void showFilterMenu(BuildContext context) {

}
