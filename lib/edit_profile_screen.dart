import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:my_desbrava/main.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;

  String _currentName = '';
  String? _currentPhotoUrl;

  XFile? _pickedImage;

  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (_currentUser == null) return;
    setState(() { _isLoading = true; });

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        _currentName = data['name'] ?? _currentUser!.displayName ?? '';
        _currentPhotoUrl = data['photoUrl']; // Já pega o valor nulo se não existir
        _nameController.text = _currentName;
      }
    } catch (e) {
      _showErrorSnackBar("Erro ao carregar dados do perfil.");
    } finally {
      if(mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _changePhoto() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile == null) return;

    setState(() { _isLoading = true; });

    try {
      final ref = FirebaseStorage.instance.ref().child('profile_pictures').child(_currentUser!.uid).child('profile.jpg');
      if (kIsWeb) {
        await ref.putData(await pickedFile.readAsBytes());
      } else {
        await ref.putFile(File(pickedFile.path));
      }
      final newPhotoUrl = await ref.getDownloadURL();

      await _currentUser!.updatePhotoURL(newPhotoUrl);
      await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).update({'photoUrl': newPhotoUrl});

      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto atualizada com sucesso!')));
        await _loadUserData(); // Recarrega os dados para mostrar a nova foto
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao atualizar a foto: $e');
    } finally {
      if(mounted) setState(() { _isLoading = false; });
    }
  }

  // Lógica para remover a foto de perfil
  Future<void> _deletePhoto() async {
    if (_currentPhotoUrl == null) return;

    setState(() { _isLoading = true; });
    try {
      final ref = FirebaseStorage.instance.ref().child('profile_pictures').child(_currentUser!.uid).child('profile.jpg');
      await ref.delete();

      await _currentUser!.updatePhotoURL(null);
      await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).update({'photoUrl': null});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto de perfil removida.')));
        await _loadUserData(); // Recarrega os dados para remover a foto da tela
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao remover foto: $e');
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  Future<void> _showEditNameDialog() async {
    _nameController.text = _currentName;
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Alterar Nome'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: "Novo nome"),
            autofocus: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if(_nameController.text.trim().isEmpty) return;
                await _updateName(_nameController.text.trim());
                if(mounted) Navigator.of(context).pop();
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateName(String newName) async {
    setState(() { _isLoading = true; });
    try {
      await _currentUser?.updateDisplayName(newName);
      await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).update({'name': newName});
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nome atualizado com sucesso!')));
        await _loadUserData();
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao atualizar nome: $e');
    } finally {
      if(mounted) setState(() { _isLoading = false; });
    }
  }

  // Mostra a janela para alterar o e-mail
  Future<void> _showEditEmailDialog() async {
    final newEmailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Alterar E-mail'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Para sua segurança, por favor, insira sua senha atual.'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: newEmailController,
                  decoration: const InputDecoration(labelText: "Novo e-mail"),
                  validator: (value) => (value == null || !value.contains('@')) ? 'E-mail inválido.' : null,
                ),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Senha atual"),
                  validator: (value) => (value == null || value.isEmpty) ? 'Senha necessária.' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if(formKey.currentState!.validate()){
                  await _updateEmail(newEmailController.text.trim(), passwordController.text.trim());
                  if(mounted) Navigator.of(context).pop();
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  // Lógica para reautenticar e alterar o e-mail
  Future<void> _updateEmail(String newEmail, String password) async {
    setState(() { _isLoading = true; });
    try {
      final cred = EmailAuthProvider.credential(email: _currentUser!.email!, password: password);
      await _currentUser!.reauthenticateWithCredential(cred);

      await _currentUser!.verifyBeforeUpdateEmail(newEmail);
      await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).update({'email': newEmail});

      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('E-mail atualizado! Por favor, verifique a sua caixa de entrada para confirmar.')));
        _loadUserData();
      }
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBar(e.code == 'wrong-password' ? 'Senha incorreta.' : 'Erro: ${e.message}');
    } catch(e) {
      _showErrorSnackBar('Ocorreu um erro inesperado.');
    } finally {
      if(mounted) setState(() { _isLoading = false; });
    }
  }

  Future<void> _sendPasswordResetEmail() async {
    if (_currentUser?.email == null) {
      _showErrorSnackBar('Nenhum e-mail associado a esta conta.');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _currentUser!.email!);
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link para redefinir senha enviado para o seu e-mail.')));
    } catch (e) {
      _showErrorSnackBar('Erro ao enviar e-mail de redefinição: $e');
    }
  }

  Future<void> _deleteAccount() async {
    // A lógica de apagar a conta continua a mesma
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Conta Permanentemente?'),
        content: const Text('Esta ação é irreversível. Todos os seus dados serão perdidos. Pode ser necessário fazer login novamente por segurança antes de prosseguir.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sim, Excluir', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() { _isLoading = true; });

    try {
      final user = _currentUser!;
      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
      final photoRef = FirebaseStorage.instance.ref().child('profile_pictures').child(user.uid).child('profile.jpg');
      await photoRef.delete().catchError((_) {});
      await user.delete();

      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Conta excluída com sucesso.')));
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const WelcomeScreen()), (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBar('Erro: ${e.message}. É necessário fazer login novamente para executar esta ação por segurança.');
    } catch (e) {
      _showErrorSnackBar('Erro ao excluir conta: $e');
    } finally {
      if(mounted) setState(() { _isLoading = false; });
    }
  }

  void _showErrorSnackBar(String message) {
    if(mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações de Perfil'),
        backgroundColor: const Color(0xFF0A192F),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: _currentPhotoUrl != null ? NetworkImage(_currentPhotoUrl!) : null,
                  child: _currentPhotoUrl == null
                      ? const Icon(Icons.person, size: 60, color: Colors.white)
                      : null,
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // <<< LÓGICA DO BOTÃO ATUALIZADA >>>
                      // Se tem foto, mostra o botão de apagar
                      if (_currentPhotoUrl != null)
                        IconButton(
                          icon: const CircleAvatar(radius: 20, backgroundColor: Colors.red, child: Icon(Icons.delete, size: 20, color: Colors.white)),
                          onPressed: _deletePhoto,
                        ),
                      // Botão para adicionar/editar foto
                      IconButton(
                        icon: const CircleAvatar(radius: 20, backgroundColor: Colors.white70, child: Icon(Icons.edit, size: 20, color: Colors.black)),
                        onPressed: _changePhoto,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Nome'),
                  subtitle: Text(_currentName.isNotEmpty ? _currentName : 'Não definido'),
                  trailing: IconButton(icon: const Icon(Icons.edit), onPressed: _showEditNameDialog),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('E-mail'),
                  subtitle: Text(_currentUser?.email ?? 'Não definido'),
                  trailing: IconButton(icon: const Icon(Icons.edit), onPressed: _showEditEmailDialog),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Senha'),
                  subtitle: const Text('********'),
                  trailing: TextButton(child: const Text('Alterar'), onPressed: _sendPasswordResetEmail),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.delete_forever),
              label: const Text('Excluir Conta'),
              onPressed: _deleteAccount,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
