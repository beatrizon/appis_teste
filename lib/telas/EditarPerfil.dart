import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:appis_app/assets/colors/colors.dart';

class EditPerfil extends StatefulWidget {
  const EditPerfil({Key? key}) : super(key: key);

  @override
  State<EditPerfil> createState() => _EditPerfilState();
}

class _EditPerfilState extends State<EditPerfil> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isEditingPassword = false;
  String? _oldPassword;
  String? _newPassword;
  String? _confirmPassword;
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto para as senhas
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Função para salvar a nova senha
  Future<void> _updatePassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = _auth.currentUser;

        // Reautenticação do usuário com a senha antiga
        final cred = EmailAuthProvider.credential(
          email: user!.email!,
          password: _oldPassword!,
        );
        await user.reauthenticateWithCredential(cred);

        // Atualizar a senha
        await user.updatePassword(_newPassword!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nova senha cadastrada')),
        );
        setState(() {
          _isEditingPassword = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      backgroundColor: paletaDeCores.fundoApp,
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 32,
                    color: paletaDeCores.preto,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Coloque todo o conteúdo do formulário dentro do container branco
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  TextFormField(
                    initialValue: user?.displayName ?? '',
                    decoration: const InputDecoration(labelText: 'Nome:'),
                    enabled: false,
                  ),
                  const Divider(color: paletaDeCores.cinza, thickness: 2.0),
                  TextFormField(
                    initialValue: user?.email ?? '',
                    decoration: const InputDecoration(labelText: 'Email:'),
                    enabled: false,
                  ),
                  const Divider(color: paletaDeCores.cinza, thickness: 2.0),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: '****', // senha mascarada
                          decoration:
                              const InputDecoration(labelText: 'Senha:'),
                          enabled: false,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          setState(() {
                            _isEditingPassword = true;
                          });
                        },
                      ),
                    ],
                  ),
                  if (_isEditingPassword)
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _oldPasswordController,
                            decoration: const InputDecoration(
                                labelText: 'Senha Anterior'),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira a senha antiga';
                              }
                              _oldPassword = value;
                              return null;
                            },
                          ),
                          const Divider(
                              color: paletaDeCores.cinza, thickness: 2.0),
                          TextFormField(
                            controller: _newPasswordController,
                            decoration:
                                const InputDecoration(labelText: 'Nova Senha'),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira a nova senha';
                              }
                              _newPassword = value;
                              return null;
                            },
                          ),
                          const Divider(
                              color: paletaDeCores.cinza, thickness: 2.0),
                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration: const InputDecoration(
                                labelText: 'Confirmar Nova Senha'),
                            obscureText: true,
                            validator: (value) {
                              if (value == null ||
                                  value != _newPasswordController.text) {
                                return 'As senhas não coincidem';
                              }
                              _confirmPassword = value;
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _updatePassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: paletaDeCores.amareloClaro,
                            ),
                            child: const Text(
                              'Confirmar',
                              style: TextStyle(
                                  color: Colors
                                      .black), // Define a cor preta para o texto
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
