import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_desbrava/widgets/place_card.dart'; // Reutiliza a classe Place

class ReportProblemScreen extends StatefulWidget {
  final Place place;

  const ReportProblemScreen({super.key, required this.place});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  final _reportController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _reportController.dispose();
    super.dispose();
  }

  // Função para enviar o relatório para o Firestore
  Future<void> _sendReport() async {
    if (!_formKey.currentState!.validate()) {
      return; // Se o campo estiver vazio, não faz nada
    }

    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Idealmente, esta tela nem deveria ser acessível por utilizadores não logados
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você precisa estar logado para enviar um relatório.'), backgroundColor: Colors.red),
      );
      setState(() { _isLoading = false; });
      return;
    }

    try {
      // Adiciona o relatório a uma nova coleção 'reports'
      await FirebaseFirestore.instance.collection('reports').add({
        'placeId': widget.place.id,
        'placeName': widget.place.name,
        'reportText': _reportController.text.trim(),
        'userId': user.uid,
        'userEmail': user.email,
        'reportedAt': Timestamp.now(),
        'status': 'pending', // Status inicial para o relatório
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Relatório enviado com sucesso. Obrigado por ajudar!')),
        );
        Navigator.of(context).pop(); // Volta para a tela de detalhes
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ocorreu um erro ao enviar o relatório: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color darkBlue = Color(0xFF0A192F);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportar Problema'),
        backgroundColor: darkBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 80, color: Colors.amber),
              const SizedBox(height: 16),
              const Text(
                'REPORTAR',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: darkBlue),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Text(
                  'Sua avaliação é muito importante para nós, pois nos ajuda a coletar dados e repassá-los às autoridades responsáveis, para que possam nos ajudar a proteger e preservar os patrimônios que amamos!\nAbaixo, escreva detalhadamente o que há de errado com o local visitado e, se quiser, inclua sugestões de melhorias.\n\nDesde já, agradecemos sua colaboração!',
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _reportController,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: 'Digite seu relatório aqui...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, descreva o problema.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: darkBlue,
                        side: const BorderSide(color: darkBlue),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendReport,
                      child: _isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Enviar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
