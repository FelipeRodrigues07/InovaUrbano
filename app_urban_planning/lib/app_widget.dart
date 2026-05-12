import 'package:flutter/material.dart';
import 'package:planejamento_urbano/contexts/authProvider.dart';
import 'package:planejamento_urbano/routes/auth_routes.dart';
import 'package:planejamento_urbano/routes/app_routes.dart';
import 'package:provider/provider.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  _AppWidgetState createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  
  bool isLoggedIn = true; 

   @override
  void initState() {
    super.initState();
    //  método initialize do AuthProvider quando o widget é inicializado
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.initialize(); 
  }




  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: isLoggedIn ? '/home' : '/login',
      routes: {
        ...AuthRoutes.routes,
        ...AppRoutes.routes,
      },
    );
  }
}
