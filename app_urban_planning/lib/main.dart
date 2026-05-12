import 'package:flutter/material.dart';
import 'package:planejamento_urbano/app_widget.dart';
import 'package:planejamento_urbano/contexts/authProvider.dart';
import 'package:provider/provider.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  runApp(
     ChangeNotifierProvider(
      create: (context) => AuthProvider(), // Cria uma instância do AuthProvider
      child: const AppWidget(),
    ),
  );
}  //runApp(const AppWidget());


//eatividade automática: O Provider atualiza automaticamente todos os widgets que dependem do estado. Quando o estado dentro do Provider muda, todos os widgets que escutam esse estado serão reconstruídos automaticamente.
