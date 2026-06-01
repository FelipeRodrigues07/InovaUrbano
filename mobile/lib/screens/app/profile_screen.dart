import 'package:flutter/material.dart';
import 'package:planejamento_urbano/config/api_constants.dart';
import 'package:planejamento_urbano/contexts/authProvider.dart';
import 'package:planejamento_urbano/components/ProfileMenuWidget.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' show basename;
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  pick(ImageSource source) async {
    final pickedFile = await imagePicker.pickImage(source: source);

    if (pickedFile != null) {
      await uploadProfilePicture(File(pickedFile.path));
    } else {
      print("Nenhum arquivo selecionado.");
    }
  }

  Future<void> uploadProfilePicture(File image) async {
     final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      final token = await authProvider.ensureAccessToken();
      if (token == null) return;

      String url = '$baseUrl/upload';
      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.files.add(await http.MultipartFile.fromPath(
        'File',
        image.path,
        filename: basename(image.path),
      ));

      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Envia a requisição
      var response = await request.send();

      if (response.statusCode == 200) {
        print("Imagem enviada com sucesso!");
        await authProvider
            .fetchProfile(); // Atualiza o perfil após enviar a imagem
      } else {
        print("Erro ao enviar a imagem: ${response.statusCode}");
      }
    } catch (e) {
      print("Erro: $e");
    }
  }

  Future<void> deleteProfilePicture() async {
     final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      final token = await authProvider.ensureAccessToken();
      if (token == null) return;

      String url = '$baseUrl/delete';
      var response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print("Foto de perfil removida com sucesso!");
        await authProvider.fetchProfile();
      } else {
        print("Erro ao remover a foto de perfil: ${response.statusCode}");
      }
    } catch (e) {
      print("Erro: $e");
    }
  }

  void _showOpcoesBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: Center(
                    child: Icon(
                      PhosphorIcons.image(),
                      color: Colors.grey[500],
                    ),
                  ),
                ),
                title: Text(
                  'Galeria',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  pick(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: Center(
                    child: Icon(
                      PhosphorIcons.camera(),
                      color: Colors.grey[500],
                    ),
                  ),
                ),
                title: Text(
                  'Câmera',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  pick(ImageSource.camera);
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: Center(
                    child: Icon(
                      PhosphorIcons.trash(),
                      color: Colors.grey[500],
                    ),
                  ),
                ),
                title: Text(
                  'Remover',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  deleteProfilePicture();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              // Imagem do perfil
              Stack(
                children: [
                  CircleAvatar(
                    radius: 75,
                    backgroundColor: Colors.grey[200],
                    child: CircleAvatar(
                      radius: 65,
                      backgroundColor: Colors.grey[300],
                      child: ClipOval(
                        child: (authProvider.userProfile?.profilePictureUrl
                                    ?.isNotEmpty ??
                                false)
                            ? CachedNetworkImage(
                                imageUrl: authProvider
                                        .userProfile?.profilePictureUrl ??
                                    '',
                                fit: BoxFit.cover,
                                width: 130,
                                height: 130,
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              )
                            : const Icon(Icons.person, size: 100, color: Colors.white),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      child: IconButton(
                        onPressed: _showOpcoesBottomSheet,
                        icon: Icon(
                          PhosphorIcons.pencilSimple(),
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20), // Espaçamento

              Text(
                authProvider.userProfile?.name ?? '',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 1),

              Text(
                authProvider.userProfile?.email ?? '',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/edit_profile');
                },
                child: const Text("Editar Perfil"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),
              ProfileMenuWidget(
                  title: "Configurações", icon: Icons.settings, onPress: () {}),
              ProfileMenuWidget(
                  title: "Informações", icon: Icons.info, onPress: () {}),
              ProfileMenuWidget(
                title: "Sair",
                icon: Icons.logout,
                textColor: Colors.red,
                endIcon: false,
                onPress: () async {
                  await authProvider.signOut(); // Chama o método de logout
                  // Redireciona para a tela de login
                  // Navigator.pushNamedAndRemoveUntil(
                  //     context, '/login', (route) => false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
