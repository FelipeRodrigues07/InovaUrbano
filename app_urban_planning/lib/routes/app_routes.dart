import 'package:flutter/material.dart';
import 'package:planejamento_urbano/screens/app/Widgets/Widget_config_pages.dart';
import 'package:planejamento_urbano/screens/app/edit_profile_screen.dart';



class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/home': (context) =>  ConfigPage(),
    '/edit_profile': (context) => EditProfile(),
  };
}