import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth/bloc/auth_bloc.dart';
import '../eventos/criar_evento_screen.dart';
import '../eventos/gerar_ingresso_screen.dart';
import '../eventos/ingresso_digital_screen.dart';
import '../tickt/presentation/screens/tickt_screen.dart';
import '../../shared/services/evento_service.dart';
import '../../shared/models/evento_model.dart';
import '../../shared/widgets/background_image.dart';
import 'dart:async';
import '../../shared/widgets/flip_countdown.dart';
import '../auth/presentation/perfil_screen.dart';
import '../eventos/leitor_qr_screen.dart';
import '../eventos/estatisticas_screen.dart';
import '../eventos/sorteio_screen.dart';
import '../../shared/models/user_model.dart';
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
  final int _infiniteScrollOffset = 10000;

  @override
  void initState() {
    super.initState();
    _eventosFuture = EventoService().listarEventos();
    // Inicializa o carrossel no meio do range virtual para permitir rolagem infinita para ambos os lados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_eventos.isNotEmpty) {
        _pageController.jumpToPage(_infiniteScrollOffset * _eventos.length);
        _currentPage = _infiniteScrollOffset * _eventos.length;
      }
    });
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
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _currentPage = nextPage;
      }
    });
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
        drawer: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            UserModel? user;
            if (state is AuthAuthenticated) {
              user = state.user as UserModel;
            }
            final nivel = user?.nivel ?? 'usuario';
            return Drawer(
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
                  if (nivel == 'adm') ...[
                    ListTile(
                      leading: const Icon(Icons.qr_code_scanner),
                      title: const Text('Ler QR Code'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LeitorQrScreen()),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.celebration),
                      title: const Text('Sorteio'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SorteioScreen()),
                        );
                      },
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
                      leading: const Icon(Icons.bar_chart),
                      title: const Text('Estatísticas'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const EstatisticasScreen()),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Meu Perfil'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const PerfilScreen()),
                        );
                      },
                    ),
                  ] else if (nivel == 'colaborador') ...[
                    ListTile(
                      leading: const Icon(Icons.qr_code_scanner),
                      title: const Text('Ler QR Code'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LeitorQrScreen()),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.bar_chart),
                      title: const Text('Estatísticas'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const EstatisticasScreen()),
                        );
                      },
                    ),
                  ] else ...[
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Meu Perfil'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const PerfilScreen()),
                        );
                      },
                    ),
                  ],
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    onTap: () {
                      context.read<AuthBloc>().add(AuthSignOutRequested());
                    },
                  ),
                ],
              ),
            );
          },
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
              // Separar eventos futuros e passados
              final agora = DateTime.now();
              final eventosFuturos = eventos.where((e) => e.dataInicio.isAfter(agora)).toList();
              final eventosPassados = eventos.where((e) => e.dataInicio.isBefore(agora)).toList()
                ..sort((a, b) => b.dataInicio.compareTo(a.dataInicio));
              if (_eventos.isEmpty && eventosFuturos.isNotEmpty) {
                _eventos = eventosFuturos;
                _startAutoPlay();
              }
              if (eventosFuturos.isEmpty && eventosPassados.isEmpty) {
                return const Center(child: Text('Nenhum evento cadastrado ainda.', style: TextStyle(color: Colors.white)));
              }
              // Próximo evento futuro para o countdown
              final proximoEvento = eventosFuturos.isNotEmpty ? (eventosFuturos..sort((a, b) => a.dataInicio.compareTo(b.dataInicio))).first : null;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Carrossel de banners dos próximos eventos
                    if (eventosFuturos.isNotEmpty)
                    SizedBox(
                      height: 320,
                      child: Stack(
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            itemCount: null, // infinito
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              final evento = eventosFuturos[index % eventosFuturos.length];
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
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              // Informações do evento à esquerda
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
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
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              // Botão à direita
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
                          // Sombra 3D na parte inferior
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: IgnorePointer(
                              child: Container(
                                height: 32,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Color.fromRGBO(0, 0, 0, 0.18),
                                      Color.fromRGBO(0, 0, 0, 0.28),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromRGBO(0, 0, 0, 0.22),
                                      blurRadius: 16,
                                      spreadRadius: 2,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Título acima do countdown
                    if (proximoEvento != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Próximo Evento: ${proximoEvento.titulo}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Countdown animado para o evento mais próximo
                    if (proximoEvento != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: FlipCountdown(targetDate: proximoEvento.dataInicio),
                      ),
                    ),
                    // Lista dos últimos eventos passados
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              'Eventos Recentes',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54,
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 400,
                            child: eventosPassados.isEmpty
                              ? const Center(child: Text('Nenhum evento passado.', style: TextStyle(color: Colors.white)))
                              : ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: eventosPassados.length,
                                  itemBuilder: (context, index) {
                                    final evento = eventosPassados[index];
                                    return Card(
                                      color: Colors.white.withOpacity(0.8),
                                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      child: ListTile(
                                        leading: const Icon(Icons.event, color: Colors.deepPurple),
                                        title: Text(evento.titulo),
                                        subtitle: Text(_formatarData(evento.dataInicio)),
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => TicktScreen(evento: evento, detalhesSomente: true),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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