import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../shared/models/evento_model.dart';
import '../../shared/services/evento_service.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/models/user_model.dart';
import 'criar_evento_sucesso_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CriarEventoScreen extends StatefulWidget {
  const CriarEventoScreen({super.key});

  @override
  State<CriarEventoScreen> createState() => _CriarEventoScreenState();
}

class _CriarEventoScreenState extends State<CriarEventoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _localController = TextEditingController();
  DateTime? _dataInicio;
  DateTime? _dataFim;
  Uint8List? _banner;
  bool _loading = false;

  Future<void> _pickBanner() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tirar foto'),
              onTap: () async {
                Navigator.of(context).pop();
                final picker = ImagePicker();
                final picked = await picker.pickImage(source: ImageSource.camera);
                if (picked != null) {
                  final bytes = await picked.readAsBytes();
                  setState(() => _banner = bytes);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Selecionar da galeria'),
              onTap: () async {
                Navigator.of(context).pop();
                final picker = ImagePicker();
                final picked = await picker.pickImage(source: ImageSource.gallery);
                if (picked != null) {
                  final bytes = await picked.readAsBytes();
                  setState(() => _banner = bytes);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _salvarEvento() async {
    if (!_formKey.currentState!.validate() || _banner == null || _dataInicio == null || _dataFim == null) return;
    setState(() => _loading = true);
    try {
      final user = await AuthService().getCurrentUser();
      if (user == null) throw Exception('Usuário não autenticado');
      final evento = EventoModel(
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        dataInicio: _dataInicio!,
        dataFim: _dataFim!,
        local: _localController.text.trim(),
        bannerUrl: '', // será preenchido pelo serviço
        igrejaId: user.igrejaId!,
      );
      await EventoService().criarEvento(
        evento: evento,
        banner: _banner!,
        userId: user.id,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Evento criado com sucesso!')));
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const EventoCriadoSucessoScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao criar evento: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF833ab4), // Roxo Instagram
            Color(0xFFfd1d1d), // Rosa/laranja Instagram
            Color(0xFFfcb045), // Amarelo Instagram
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Criar Evento'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _tituloController,
                  decoration: InputDecoration(
                    labelText: 'Título do evento',
                    labelStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  ),
                  style: const TextStyle(color: Colors.black),
                  validator: (v) => v == null || v.isEmpty ? 'Informe o título' : null,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _descricaoController,
                  decoration: InputDecoration(
                    labelText: 'Descrição do evento',
                    labelStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  ),
                  style: const TextStyle(color: Colors.black),
                  maxLines: 3,
                  validator: (v) => v == null || v.isEmpty ? 'Informe a descrição' : null,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _localController,
                  decoration: InputDecoration(
                    labelText: 'Local do evento',
                    labelStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  ),
                  style: const TextStyle(color: Colors.black),
                  validator: (v) => v == null || v.isEmpty ? 'Informe o local' : null,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) {
                              setState(() {
                                _dataInicio = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
                              });
                            }
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Data início',
                            labelStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          ),
                          child: Text(_dataInicio != null ? _dataInicio.toString() : 'Selecionar', style: const TextStyle(color: Colors.black)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) {
                              setState(() {
                                _dataFim = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
                              });
                            }
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Data fim',
                            labelStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          ),
                          child: Text(_dataFim != null ? _dataFim.toString() : 'Selecionar', style: const TextStyle(color: Colors.black)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  icon: const Icon(Icons.image, color: Color(0xFF833ab4)),
                  label: Text(_banner == null ? 'Selecionar banner' : 'Banner selecionado', style: const TextStyle(color: Color(0xFF833ab4))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF833ab4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    backgroundColor: Colors.white.withOpacity(0.9),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  onPressed: _pickBanner,
                ),
                if (_banner == null)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('O banner é obrigatório', style: TextStyle(color: Colors.red)),
                  ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _loading ? null : _salvarEvento,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    backgroundColor: const Color(0xFF833ab4),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('Criar Evento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 