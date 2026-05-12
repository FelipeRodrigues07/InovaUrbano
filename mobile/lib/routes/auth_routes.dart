import 'package:flutter/material.dart';
import 'package:planejamento_urbano/screens/auth/createAccount_screen.dart';
import 'package:planejamento_urbano/screens/auth/login_screen.dart';


class AuthRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/login': (context) => const Login(),
    '/createAccount': (context) => const CreateAccountScreen(),
  };
}