import 'package:flutter/material.dart';
import 'package:planejamento_urbano/contexts/authProvider.dart';
import 'package:planejamento_urbano/screens/app/feed_screen.dart';
import 'package:planejamento_urbano/screens/app/home_screen.dart';
import 'package:planejamento_urbano/screens/app/report_screen.dart';
import 'package:planejamento_urbano/screens/app/profile_screen.dart';
import 'package:provider/provider.dart';

class ConfigPage extends StatefulWidget {
  ConfigPage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<ConfigPage> {
  int paginaAtual = 0;
  late PageController pc;

  @override
  void initState() {
    super.initState();
    pc = PageController(initialPage: paginaAtual);
  }

  setPaginaAtual(pagina) {
    setState(() {
      paginaAtual = pagina;
    });
  }

  @override
  Widget build(BuildContext context) {
    
     final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: PageView(
        controller: pc,
        onPageChanged: (pagina) {
          setPaginaAtual(pagina); // Atualiza a página atual
          // Verifica se a página atual é a de perfil
          if (pagina == 3 && authProvider.token == null) {
            // Usuário não autenticado, navega para a tela de autenticação
            print('Usuário não autenticado. Redirecionando para a tela de login. : ${authProvider.token}');
            Navigator.of(context).pushReplacementNamed('/login');
          }
        },
        children: const [
          Home(),
          ReportScreen(),
          Feed(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: paginaAtual,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'Reclame'),
          BottomNavigationBarItem(icon: Icon(Icons.feed), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],

        onTap: (pagina) {
          if (pagina == 3) { // Índice da aba de Perfil
          print('Token do usuário: ${authProvider.token}');
            if (authProvider.token == null) {
              // Usuário não autenticado, navega para a tela de autenticação
               Navigator.of(context).pushReplacementNamed('/login');
            } else {
              // Usuário autenticado, vai para a página de Perfil
              pc.animateToPage(
                pagina,
                duration: Duration(milliseconds: 400),
                curve: Curves.ease,
              );
            }
          } else {
            // Para outras abas, navegue normalmente
            pc.animateToPage(
              pagina,
              duration: Duration(milliseconds: 400),
              curve: Curves.ease,
            );
          }
        },

        // backgroundColor: Colors.grey[100],
      ),
    );
  }
}
