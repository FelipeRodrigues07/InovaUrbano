import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  static const String appName = 'Inova Urbano';
  static const String appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informações'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    width: 110,
                    height: 110,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  appName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'Versão $appVersion',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Sobre o aplicativo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'O Inova Urbano é um aplicativo de planejamento urbano participativo. '
                'Por aqui, cidadãos podem enviar sugestões e solicitações sobre a cidade, '
                'acompanhar as respostas oficiais da prefeitura e visualizar no mapa as '
                'demandas da sua região.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Como funciona',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _InfoItem(
                icon: Icons.add_location_alt_outlined,
                text: 'Envie sugestões com foto e localização no mapa.',
              ),
              _InfoItem(
                icon: Icons.feed_outlined,
                text: 'Acompanhe o feed de solicitações e respostas oficiais.',
              ),
              _InfoItem(
                icon: Icons.verified_outlined,
                text: 'Veja o status de cada solicitação atualizado pela gestão.',
              ),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  '© ${DateTime.now().year} Inova Urbano',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
