bool validateUsername(String username){
  return username.length >=5;
}

bool validatePassword(String password){
  return password.length >= 5;
}
bool checkPassword(String password_1, String password_2){
  return password_1 == password_2;
}