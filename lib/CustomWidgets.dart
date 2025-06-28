import 'package:flutter/material.dart';

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

TextStyle customOrangeShadowTextStyle(double fontSize) {
  return TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: fontSize,
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
  );
}
TextStyle customBasicTextStyle(double fontSize, bool bold, {Color? color}){
  return TextStyle(
    fontWeight: bold? FontWeight.bold : null,
    fontSize: fontSize,
    color: color ?? Colors.black
  );
}

TextStyle customSnackBoxTextStyle(double fontSize, Color color){
  return TextStyle(
    fontSize: fontSize,
    color: color,
  );
}
TextStyle customShadowTextStyle(){
  return const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 20.00,
    shadows: [
      Shadow(
        blurRadius: 15.0,
        color: Colors.orangeAccent,
        offset: Offset(0, 0),
      ),
      Shadow(
        blurRadius: 15.0,
        color: Colors.orangeAccent,
        offset: Offset(0, 0),
      ),
    ],
  );
}

BoxDecoration CustomBoxDecoration(){
  return BoxDecoration(
    image: DecorationImage(
      image: AssetImage('images/Color.jpg'),
      fit: BoxFit.cover,
    ),
  );
}

ButtonStyle SimpleButtonStyle(double borderRadius, double elevation, Color color, double width){
  return ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    ),
    elevation: elevation,
    side: BorderSide(
      color: color,
      width: width,
    )
  );
}

void showCustomSnackBar(BuildContext context, String message, Color backgroundColor) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: customSnackBoxTextStyle(20, Colors.white),
      ),
      backgroundColor: backgroundColor,
    ),
  );
}

TextField basicTextField(Key key, TextEditingController textController, String hintText ){
  return TextField(
    key: key,
    controller: textController,
    decoration: InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontStyle: FontStyle.italic),
      enabledBorder: UnderlineInputBorder(
        borderSide:  BorderSide(color: Colors.orange.shade300,width: 1.5),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.orange.shade200,width: 3.0),
      ),
    ),
  );
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