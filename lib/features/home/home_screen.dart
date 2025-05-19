import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth/bloc/auth_bloc.dart';
import '../eventos/criar_evento_screen.dart';
import '../eventos/gerar_ingresso_screen.dart';
import '../eventos/ingresso_digital_screen.dart';
import '../tickt/presentation/screens/tickt_screen.dart';
import '../../shared/services/evento_service.dart';
import '../../shared/models/evento_model.dart';
import 'dart:async';
// Importe outras telas conforme necessário

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<EventoModel> _eventos = [];
  Timer? _autoPlayTimer;
  late Future<List<EventoModel>> _eventosFuture;

  @override
  void initState() {
    super.initState();
    _eventosFuture = EventoService().listarEventos();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    if (_eventos.length <= 1) return;
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients && _eventos.isNotEmpty) {
        int nextPage = _currentPage + 1;
        if (nextPage >= _eventos.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
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
          title: const Text('Tickt'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF833ab4),
                      Color(0xFFfd1d1d),
                      Color(0xFFfcb045),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
              ListTile(
                leading: const Icon(Icons.event),
                title: const Text('Criar Evento'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CriarEventoScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.confirmation_num),
                title: const Text('Gerar Ingresso'),
                onTap: () {
                  // Navegar para tela de gerar ingresso
                  // (Removido: GerarIngressoScreen)
                  // O fluxo correto é pelo botão na tela de detalhes do evento
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Acesse um evento e clique em "Gerar Meu Ingresso".')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.confirmation_num),
                title: const Text('Ver Ingresso Exemplo'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => IngressoDigitalScreen(ingressoId: '6b84cc6c-df85-40a1-8624-f1d1b31d87e7'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Meu Perfil'),
                onTap: () {
                  // Navegar para tela de perfil
                },
              ),
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text('Login'),
                onTap: () {
                  // Navegar para tela de login
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  context.read<AuthBloc>().add(AuthSignOutRequested());
                },
              ),
              ListTile(
                leading: const Icon(Icons.app_registration),
                title: const Text('Cadastre-se'),
                onTap: () {
                  // Navegar para tela de cadastro
                },
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: FutureBuilder<List<EventoModel>>(
            future: _eventosFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Erro ao carregar eventos: ${snapshot.error}', style: TextStyle(color: Colors.white)));
              }
              final eventos = snapshot.data ?? [];
              if (_eventos.isEmpty && eventos.isNotEmpty) {
                _eventos = eventos;
                _startAutoPlay();
              }
              if (eventos.isEmpty) {
                return const Center(child: Text('Nenhum evento cadastrado ainda.', style: TextStyle(color: Colors.white)));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Carrossel de banners dos próximos eventos
                  SizedBox(
                    height: 320,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: eventos.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final evento = eventos[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              color: Colors.white.withOpacity(0.15),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  if (evento.bannerUrl.isNotEmpty)
                                    Image.network(
                                      evento.bannerUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stack) => Container(color: Colors.grey[300]),
                                    ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 16,
                                    right: 16,
                                    bottom: 24,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          evento.titulo,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          evento.local,
                                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatarData(evento.dataInicio),
                                          style: const TextStyle(color: Colors.white, fontSize: 15),
                                        ),
                                        const SizedBox(height: 12),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => TicktScreen(evento: evento),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF833ab4),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          child: const Text('Participar do evento', style: TextStyle(color: Colors.white)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Countdown animado para o evento mais próximo
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Column(
                        children: [
                          const Text('Evento mais próximo:', style: TextStyle(color: Colors.white, fontSize: 18)),
                          const SizedBox(height: 8),
                          // Substituir pelo countdown real
                          TweenAnimationBuilder<Duration>(
                            duration: const Duration(hours: 2),
                            tween: Tween(begin: const Duration(hours: 2), end: Duration.zero),
                            builder: (context, value, child) {
                              final hours = value.inHours;
                              final minutes = value.inMinutes % 60;
                              final seconds = value.inSeconds % 60;
                              return Text(
                                '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                              );
                            },
                            onEnd: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Lista dos últimos 5 eventos
                  Expanded(
                    child: ListView.builder(
                      itemCount: 5, // Substituir pelo número real de eventos
                      itemBuilder: (context, index) {
                        return Card(
                          color: Colors.white.withOpacity(0.8),
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: const Icon(Icons.event, color: Colors.deepPurple),
                            title: Text('Evento ${index + 1}'),
                            subtitle: const Text('Resumo do evento...'),
                            onTap: () {
                              // Navegar para detalhes do evento
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  static String _formatarData(DateTime data) {
    // Exemplo: 25/12/2024 18:00
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}' ;
  }
} 