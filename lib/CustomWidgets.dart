import 'package:flutter/material.dart';

import 'SignInPage.dart';

class CustomGoToElevatedButton extends StatelessWidget implements PreferredSizeWidget{

   final String title;
   final double widthSize;
   final double heightSize;
   final double fontSize;
   final Widget targetPage;

   const CustomGoToElevatedButton({
     Key? key,
     required this.title,
     required this.widthSize,
     required this.heightSize,
     required this.fontSize,
     required this.targetPage,
   }) : super(key: key);

   Widget build(BuildContext context) {
     return ElevatedButton(
       onPressed: () {
         Navigator.push(
           context,
           MaterialPageRoute(builder: (context) => targetPage),
         );
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
         width: widthSize,
         height: heightSize,
         alignment: Alignment.center,
         child: Text(
           title,
           style: TextStyle(
             fontWeight: FontWeight.bold,
             fontSize: fontSize,
             color: Colors.black,
           ),
         ),
       ),
     );
   }

   @override
   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color.fromRGBO(3, 220, 255, 100),
      elevation: 100,
      flexibleSpace: Padding(
        padding: const EdgeInsets.only(top:35.0),
        child: Center(
            child: Text(
              title,
              style: const TextStyle(
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/*
                ElevatedButton(
                  onPressed: () {
                    // Acțiunea pentru butonul de Sign Up
                    print('Buton Sign In apăsat');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignInPage()),
                    );
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
                    width: 110.0,
                    height: 60.0,
                    alignment: Alignment.center,
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
 */