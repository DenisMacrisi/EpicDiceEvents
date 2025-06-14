
import 'dart:math';

bool validateUsername(String username){
  return username.length >=5;
}

bool validatePassword(String password){
  return password.length >= 5;
}
// return ok -> parolele nu sunt la fel
bool validatePasswordRetype(String password_1, String password_2){
  return !(password_1 == password_2);
}

bool validateEmail(String email){
  // Regex pentru validare email
  String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  RegExp regExp = RegExp(pattern);

  return regExp.hasMatch(email);
}

String generateEmail(int length){
  const String characters = "qwertyuiopasdfghjklzxcvbnm1234567890";
  final Random random = Random();

  String username = List.generate(length, (index) => characters[random.nextInt(characters.length)]).join();

  return "$username@domain.com";
}

String generateInvalidEmail(int length){
  const String characters = "qwertyuiopasdfghjklzxcvbnm1234567890";
  final Random random = Random();

  String username = List.generate(length, (index) => characters[random.nextInt(characters.length)]).join();

  return username;
}

String generatePassword(int length){
  const String characters = "qwertyuiopasdfghjklzxcvbnm1234567890";
  final Random random = Random();

  String password = List.generate(length, (index) => characters[random.nextInt(characters.length)]).join();

  return password;

}
