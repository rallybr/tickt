import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../shared/services/evento_service.dart';
import '../../shared/services/ingresso_service.dart';
import '../../shared/models/evento_model.dart';
import '../../shared/models/ingresso_model.dart';
import '../../shared/widgets/background_image.dart';
import '../../core/config/supabase_config.dart';

class SorteioScreen extends StatefulWidget {
  const SorteioScreen({super.key});

  @override
  State<SorteioScreen> createState() => _SorteioScreenState();
}

class _SorteioScreenState extends State<SorteioScreen> {
  List<EventoModel> _eventos = [];
  EventoModel? _eventoSelecionado;
  List<ParticipanteSorteio> _presentes = [];
  bool _loading = true;
  bool _sorteando = false;
  String? _nomeSorteado;
  String? _whatsappSorteado;
  Timer? _timer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _carregarEventos();
  }

  Future<void> _carregarEventos() async {
    final eventos = await EventoService().listarEventos();
    setState(() {
      _eventos = eventos;
      _eventoSelecionado = eventos.isNotEmpty ? eventos.first : null;
    });
    if (eventos.isNotEmpty) {
      await _carregarPresentes(eventos.first);
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _carregarPresentes(EventoModel evento) async {
    setState(() {
      _loading = true;
      _presentes = [];
    });
    final ingressos = await IngressoService().buscarIngressosDoEvento(evento.id!);
    final presentes = ingressos.where((i) => i.status == 'presente').toList();
    // Buscar perfis dos presentes
    List<ParticipanteSorteio> participantes = [];
    for (final ingresso in presentes) {
      final perfil = await SupabaseConfig.client
          .from('perfis')
          .select('nome, whatsapp')
          .eq('id', ingresso.compradorId)
          .maybeSingle();
      if (perfil != null) {
        participantes.add(ParticipanteSorteio(
          nome: perfil['nome'] ?? '---',
          whatsapp: perfil['whatsapp'] ?? '',
        ));
      }
    }
    setState(() {
      _presentes = participantes;
      _loading = false;
    });
  }

  void _onEventoSelecionado(EventoModel? evento) async {
    if (evento == null) return;
    setState(() {
      _eventoSelecionado = evento;
    });
    await _carregarPresentes(evento);
  }

  void _iniciarSorteio() {
    if (_presentes.isEmpty) return;
    setState(() {
      _sorteando = true;
      _nomeSorteado = null;
      _whatsappSorteado = null;
    });
    _timer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      final sorteado = _presentes[_random.nextInt(_presentes.length)];
      setState(() {
        _nomeSorteado = sorteado.nome ?? '---';
        _whatsappSorteado = _mascararWhatsapp(sorteado.whatsapp ?? '');
      });
    });
    Future.delayed(const Duration(seconds: 4), _pararSorteio);
  }

  void _pararSorteio() {
    _timer?.cancel();
    if (_presentes.isEmpty) return;
    final sorteado = _presentes[_random.nextInt(_presentes.length)];
    setState(() {
      _nomeSorteado = sorteado.nome ?? '---';
      _whatsappSorteado = _mascararWhatsapp(sorteado.whatsapp ?? '');
      _sorteando = false;
    });
  }

  String _mascararWhatsapp(String whatsapp) {
    final regex = RegExp(r'\((\d{2})\)\s?(\d{5})-(\d{4})');
    final match = regex.firstMatch(whatsapp);
    if (match != null) {
      final ddd = match.group(1);
      final ultimos = match.group(3);
      return '($ddd) *****$ultimos';
    }
    // fallback para outros formatos
    if (whatsapp.length >= 4) {
      return '*****${whatsapp.substring(whatsapp.length - 4)}';
    }
    return whatsapp;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Container(
            child: Image.asset('assets/images/logo_tickts.png', height: 38, fit: BoxFit.contain),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DropdownButton<EventoModel>(
                      value: _eventoSelecionado,
                      isExpanded: true,
                      hint: const Text('Selecione um evento'),
                      items: _eventos.map((evento) {
                        return DropdownMenuItem(
                          value: evento,
                          child: Text(evento.titulo),
                        );
                      }).toList(),
                      onChanged: _onEventoSelecionado,
                    ),
                    const SizedBox(height: 32),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _nomeSorteado == null
                          ? Column(
                              children: [
                                Icon(Icons.casino, size: 80, color: Colors.white.withOpacity(0.7)),
                                const SizedBox(height: 16),
                                Text(
                                  _presentes.isEmpty ? 'Nenhum presente para sortear.' : 'Clique em sortear para começar!',
                                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )
                          : Column(
                              key: ValueKey(_nomeSorteado),
                              children: [
                                const SizedBox(height: 16),
                                Text(
                                  _nomeSorteado!,
                                  style: TextStyle(
                                    color: Colors.yellow[700],
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(color: Colors.black, blurRadius: 12, offset: Offset(0, 2)),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _whatsappSorteado ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      icon: Icon(_sorteando ? Icons.stop : Icons.casino),
                      label: Text(_sorteando ? 'Sorteando...' : 'Sortear'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _sorteando || _presentes.isEmpty ? null : _iniciarSorteio,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class ParticipanteSorteio {
  final String nome;
  final String whatsapp;
  ParticipanteSorteio({required this.nome, required this.whatsapp});
} 