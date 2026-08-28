class CustomUser {

  final String uid;
  final String email;
  final String username;
  String role;
  List<dynamic>? permissions = [];
  CustomUser({ required this.uid , this.email = "", required this.username, this.role="", this.permissions = const []});

}

class UserData {

  final String uid;
  UserData({ required this.uid });

}