import 'package:flutter/material.dart';
import 'package:planejamento_urbano/contexts/authProvider.dart';
import 'package:planejamento_urbano/screens/app/feed_screen.dart';
import 'package:planejamento_urbano/screens/app/home_screen.dart';
import 'package:planejamento_urbano/screens/app/report_screen.dart';
import 'package:planejamento_urbano/screens/app/profile_screen.dart';
import 'package:provider/provider.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  int paginaAtual = 0;
  late PageController _pageController;
  final GlobalKey<FeedState> _feedKey = GlobalKey<FeedState>();
  final List<Widget?> _lazyPages = List<Widget?>.filled(4, null);

  @override
  void initState() {
    super.initState();
    _lazyPages[0] = const Home();
    _pageController = PageController(initialPage: paginaAtual);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _ensurePageBuilt(int index) {
    if (_lazyPages[index] != null) return;

    switch (index) {
      case 0:
        _lazyPages[0] = const Home();
        break;
      case 1:
        _lazyPages[1] = const ReportScreen();
        break;
      case 2:
        _lazyPages[2] = Feed(key: _feedKey);
        break;
      case 3:
        _lazyPages[3] = const ProfilePage();
        break;
    }
  }

  void _refreshFeedAfterOpen() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _feedKey.currentState?.reloadFromPrefs();
    });
  }

  void _onPageChanged(int pagina, AuthProvider authProvider) {
    if (pagina == 3 && authProvider.token == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pageController.jumpToPage(paginaAtual);
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return;
    }

    final firstOpen = _lazyPages[pagina] == null;

    setState(() {
      _ensurePageBuilt(pagina);
      paginaAtual = pagina;
    });

    if (pagina == 2 && !firstOpen) {
      _refreshFeedAfterOpen();
    }
  }

  void _goToTab(int pagina, AuthProvider authProvider) {
    if (pagina == 3 && authProvider.token == null) {
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    final firstOpen = _lazyPages[pagina] == null;
    _ensurePageBuilt(pagina);

    if (pagina != paginaAtual) {
      setState(() => paginaAtual = pagina);
      _pageController.animateToPage(
        pagina,
        duration: const Duration(milliseconds: 400),
        curve: Curves.ease,
      );
    } else if (firstOpen) {
      setState(() => paginaAtual = pagina);
    }

    if (pagina == 2 && !firstOpen) {
      _refreshFeedAfterOpen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (pagina) => _onPageChanged(pagina, authProvider),
        itemCount: 4,
        itemBuilder: (context, index) {
          _ensurePageBuilt(index);
          return _lazyPages[index]!;
        },
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
        onTap: (pagina) => _goToTab(pagina, authProvider),
      ),
    );
  }
}
