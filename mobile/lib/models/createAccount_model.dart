class CreateAccountModel {
  String email;
  String password;
  String name;

  CreateAccountModel({
    required this.email,
    required this.password,
    required this.name,
  });


   Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
    };
  }
}
