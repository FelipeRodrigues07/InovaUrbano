import 'package:flutter/material.dart';

class TypesSuggestions extends StatelessWidget {
  const TypesSuggestions({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> _suggestionTypes = [
      'Infraestrutura',
      'Trânsito',
      'Limpeza',
      'Segurança',
      'Acessibilidade',
      'Saúde Pública',
      'Outros',
    ];

    Color getMarkerColor(String type) {
      switch (type) {
        case 'Trânsito':
          return const Color(0xFFE57373); 
        case 'Segurança':
            return const Color(0xFFFFB74D);
        case 'Limpeza':
          return const Color(0xFF81C784); 
        case 'Acessibilidade':
          return const Color(0xFFFFF176); 
        case 'Saúde Pública':
          return const Color(0xFFF48FB1); 
        case 'Infraestrutura':
          return const Color(0xFF64B5F6);
        default:
          return const Color(0xFFB0BEC5); 
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Center(
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center, // Centraliza horizontalmente
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Primeira coluna com 4 itens
            Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Alinha à direita
              children: _suggestionTypes.sublist(0, 4).map((type) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0), // Espaço entre os itens
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        color: getMarkerColor(type),
                      ),
                      const SizedBox(
                          width: 8), // Espaçamento entre a cor e o texto
                      Text(type),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(width: 32), // Espaço entre as duas colunas
            // Segunda coluna com 3 itens
            Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Alinha à esquerda
              children: _suggestionTypes.sublist(4).map((type) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0), // Espaço entre os itens
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        color: getMarkerColor(type),
                      ),
                      const SizedBox(
                          width: 8), // Espaçamento entre a cor e o texto
                      Text(type),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
