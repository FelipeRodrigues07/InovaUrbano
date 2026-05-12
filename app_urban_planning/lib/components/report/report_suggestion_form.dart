import 'dart:io';

import 'package:flutter/material.dart';
import 'package:planejamento_urbano/controllers/create_suggestion_controller.dart';

/// Type, description, optional image, and submit (Report flow).
class ReportSuggestionForm extends StatelessWidget {
  const ReportSuggestionForm({
    super.key,
    required this.suggestionTypes,
    required this.selectedType,
    required this.onTypeChanged,
    required this.descriptionController,
    required this.imageFile,
    required this.onSelectImage,
    required this.onDeleteImage,
    required this.controller,
    required this.onSubmit,
  });

  final List<String> suggestionTypes;
  final String? selectedType;
  final ValueChanged<String?> onTypeChanged;
  final TextEditingController descriptionController;
  final File? imageFile;
  final VoidCallback onSelectImage;
  final VoidCallback onDeleteImage;
  final CreateSuggestionController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: selectedType,
            decoration: const InputDecoration(
              labelText: 'Tipo de Sugestão',
              border: OutlineInputBorder(),
            ),
            items: suggestionTypes.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: onTypeChanged,
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: descriptionController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Descrição',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8.0),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onSelectImage,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                side: const BorderSide(
                  color: Color.fromARGB(255, 131, 124, 124),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Selecionar Imagem (opcional)',
                style: TextStyle(
                  color: Color.fromARGB(255, 153, 142, 142),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6.0),
          if (imageFile != null) ...[
            Container(
              margin: const EdgeInsets.only(top: 6.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(
                  color: const Color.fromARGB(255, 131, 124, 124),
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Imagem selecionada',
                    style: TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDeleteImage,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 6.0),
          ListenableBuilder(
            listenable: controller,
            builder: (context, child) {
              return ElevatedButton(
                onPressed: controller.isLoading ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 80, 144, 227),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: controller.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Enviar Sugestão'),
              );
            },
          ),
        ],
      ),
    );
  }
}
