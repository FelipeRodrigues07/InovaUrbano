import 'package:flutter/material.dart';
import 'package:planejamento_urbano/contexts/authProvider.dart';
import 'package:planejamento_urbano/controllers/update_email_controller.dart';
import 'package:planejamento_urbano/controllers/update_name_controller.dart';
import 'package:planejamento_urbano/controllers/update_password_controller.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  void _editData(String fieldName, String currentValue) {
    TextEditingController controller =
        TextEditingController(text: currentValue);
      print('Valor do controller: ${controller.text}');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar $fieldName'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Novo $fieldName',
              // enabledBorder: UnderlineInputBorder(
              //   borderSide: BorderSide(color: Colors.black),
              // ),
              // focusedBorder: UnderlineInputBorder(
              //   borderSide: BorderSide(color: Colors.blue),
              // ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () async {
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                final token = await authProvider.ensureAccessToken();

                if (fieldName == 'Nome' && token != null) {
                  final updateNameController = UpdateNameController();
                  await updateNameController.updateName(controller.text, token);
                  await authProvider.fetchProfile();
                  if (!updateNameController.isError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Nome atualizado com sucesso!')),
                    );
                  }
                } else if (fieldName == 'Email' && token != null) {
                  final updateEmailController = UpdateEmailController();
                  await updateEmailController.updateEmail(
                      controller.text, token);
                  await authProvider.fetchProfile();
                  print(authProvider.userProfile?.email);
                  if (!updateEmailController.isError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Email atualizado com sucesso!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(updateEmailController.errorMessage ??
                              'Erro desconhecido')),
                    );
                  }
                }

                Navigator.of(context).pop();
              },
              child: const Text('Salvar', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  void _editPassword() {
    TextEditingController currentPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alterar Senha'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha Atual',
                ),
              ),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nova Senha',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () async {
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                final token = await authProvider.ensureAccessToken();

                final updatePasswordController = UpdatePasswordController();

                try {
                  if (token != null) {
                    await updatePasswordController.updatePassword(
                      currentPasswordController.text,
                      newPasswordController.text,
                      token,
                    );

                    if (updatePasswordController.isError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Erro ao atualizar a senha'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Senha atualizada com sucesso!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                } catch (error) {
                  print(
                      'Erro ao atualizar senha: $error'); // Verifique o erro aqui
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erro ao atualizar a senha')),
                  );
                }
              },
              child: const Text('Salvar', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: true);
    final userProfile = authProvider.userProfile;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Dados da Conta',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Card(
          elevation: 4,
          margin: const EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Nome'),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _editData(
                    'Nome',
                    userProfile?.name ?? '',
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text('Email'),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _editData(
                    'Email',
                    userProfile?.email ?? '',
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text('Senha'),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _editPassword(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
