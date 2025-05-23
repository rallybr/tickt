import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../../shared/services/evento_service.dart';
import '../../shared/services/ingresso_service.dart';
import '../../shared/models/evento_model.dart';
import '../../shared/models/ingresso_model.dart';
import '../../shared/widgets/background_image.dart';
import '../../core/config/supabase_config.dart';
import '../../shared/utils/responsive_utils.dart';
import 'package:confetti/confetti.dart';

class SorteioScreen extends StatefulWidget {
  final String? eventoId;

  const SorteioScreen({
    super.key,
    this.eventoId,
  });

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
  bool _isLoading = false;
  String? _ganhador;
  String? _error;
  ConfettiController? _confettiController;

  @override
  void initState() {
    super.initState();
    _carregarEventos();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
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
    _confettiController?.play();
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
    _confettiController?.dispose();
    super.dispose();
  }

  Future<void> _realizarSorteio() async {
    setState(() {
      _isLoading = true;
      _ganhador = null;
      _error = null;
    });

    try {
      final result = await IngressoService().realizarSorteio(widget.eventoId!);
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _ganhador = result['ganhador'];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
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
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 360;
            
            return SingleChildScrollView(
              padding: ResponsiveUtils.getAdaptivePadding(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Container do sorteio
                  Container(
                    padding: ResponsiveUtils.getAdaptivePadding(context),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Ícone e confete acima do título
                        Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Icon(
                              Icons.celebration,
                              size: ResponsiveUtils.getAdaptiveIconSize(context) * 2,
                              color: Theme.of(context).primaryColor,
                            ).animate().scale(
                              duration: const Duration(seconds: 1),
                              curve: Curves.elasticOut,
                            ),
                            if (_nomeSorteado != null && _whatsappSorteado != null)
                              Positioned(
                                top: ResponsiveUtils.getAdaptiveIconSize(context) * 2 + 8, // logo abaixo do ícone
                                left: 0,
                                right: 0,
                                child: SizedBox(
                                  height: 120,
                                  child: IgnorePointer(
                                    child: ConfettiWidget(
                                      confettiController: _confettiController!,
                                      blastDirectionality: BlastDirectionality.explosive,
                                      shouldLoop: false,
                                      emissionFrequency: 0.05,
                                      numberOfParticles: 30,
                                      maxBlastForce: 20,
                                      minBlastForce: 8,
                                      gravity: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),

                        SizedBox(height: ResponsiveUtils.isMobile(context) ? 16 : 24),

                        Text(
                          'Sorteio do Evento',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getAdaptiveFontSize(context, 24),
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate().fadeIn().slideY(begin: 0.3, end: 0),

                        // Dropdown para seleção de evento
                        if (_eventos.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                            child: DropdownButton<EventoModel>(
                              value: _eventoSelecionado,
                              isExpanded: true,
                              hint: const Text('Selecione um evento'),
                              items: _eventos.map((evento) {
                                return DropdownMenuItem(
                                  value: evento,
                                  child: Text(evento.titulo),
                                );
                              }).toList(),
                              onChanged: (evento) {
                                _onEventoSelecionado(evento);
                              },
                            ),
                          ),

                        SizedBox(height: ResponsiveUtils.isMobile(context) ? 24 : 32),

                        if (_isLoading)
                          Column(
                            children: [
                              const CircularProgressIndicator(),
                              SizedBox(height: ResponsiveUtils.isMobile(context) ? 16 : 24),
                              Text(
                                'Realizando sorteio...',
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.getAdaptiveFontSize(context, 16),
                                ),
                              ),
                            ],
                          ).animate().fadeIn()
                        else if (_ganhador != null)
                          Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(ResponsiveUtils.isMobile(context) ? 16 : 24),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'Ganhador!',
                                      style: TextStyle(
                                        fontSize: ResponsiveUtils.getAdaptiveFontSize(context, 20),
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    SizedBox(height: ResponsiveUtils.isMobile(context) ? 8 : 12),
                                    Text(
                                      _ganhador!,
                                      style: TextStyle(
                                        fontSize: ResponsiveUtils.getAdaptiveFontSize(context, 18),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ).animate().scale(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.elasticOut,
                              ),
                            ],
                          )
                        else if (_error != null)
                          Container(
                            padding: ResponsiveUtils.getAdaptivePadding(context),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: ResponsiveUtils.getAdaptiveIconSize(context) * 1.5,
                                ),
                                SizedBox(height: ResponsiveUtils.isMobile(context) ? 8 : 12),
                                Text(
                                  _error!,
                                  style: TextStyle(
                                    fontSize: ResponsiveUtils.getAdaptiveFontSize(context, 16),
                                    color: Colors.red,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ).animate().fadeIn()
                        else if (_sorteando)
                          Column(
                            children: [
                              Icon(Icons.casino, size: 64, color: Theme.of(context).primaryColor),
                              const SizedBox(height: 16),
                              Text(
                                _nomeSorteado ?? '',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                  shadows: [Shadow(color: Colors.black26, blurRadius: 8)],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _whatsappSorteado ?? '',
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              Text('Sorteando...', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                            ],
                          )
                        else if (_nomeSorteado != null && _whatsappSorteado != null)
                          Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              Column(
                                children: [
                                  Icon(Icons.emoji_events, size: 64, color: Colors.amber[700]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Ganhador!',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _nomeSorteado!,
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _whatsappSorteado!,
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: ConfettiWidget(
                                    confettiController: _confettiController!,
                                    blastDirectionality: BlastDirectionality.explosive,
                                    shouldLoop: false,
                                    emissionFrequency: 0.05,
                                    numberOfParticles: 30,
                                    maxBlastForce: 20,
                                    minBlastForce: 8,
                                    gravity: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          )
                        else if (!_loading && _presentes.isEmpty)
                          Text(
                            'Nenhum participante presente para sorteio.',
                            style: TextStyle(fontSize: 16, color: Colors.red),
                            textAlign: TextAlign.center,
                          )
                        else
                          Text(
                            'Clique no botão abaixo para realizar o sorteio',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getAdaptiveFontSize(context, 16),
                            ),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(),

                        SizedBox(height: ResponsiveUtils.isMobile(context) ? 24 : 32),

                        SizedBox(
                          width: double.infinity,
                          height: ResponsiveUtils.isMobile(context) ? 48 : 56,
                          child: ElevatedButton(
                            onPressed: _sorteando || _presentes.isEmpty ? null : _iniciarSorteio,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              _sorteando ? 'Sorteando...' : 'Realizar Sorteio',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getAdaptiveFontSize(context, 16),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ).animate().fadeIn().slideY(begin: 0.3, end: 0),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
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