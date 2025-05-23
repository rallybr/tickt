import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../shared/models/evento_model.dart';
import '../../../../shared/services/ingresso_service.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../eventos/ingresso_digital_screen.dart';

class TicktScreen extends StatelessWidget {
  final EventoModel evento;
  final bool detalhesSomente;

  const TicktScreen({
    super.key,
    required this.evento,
    this.detalhesSomente = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF833ab4), // Roxo Instagram
                Color(0xFF9c27b0), // Roxo mais claro
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(ResponsiveUtils.isMobile(context) ? 4 : 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF833ab4), // Roxo Instagram
                Color(0xFFfd1d1d), // Rosa/laranja Instagram
                Color(0xFFfcb045), // Amarelo Instagram
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(ResponsiveUtils.isMobile(context) ? 8 : 12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: ResponsiveUtils.getAdaptiveIconSize(context),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return CustomScrollView(
            slivers: [
              // App Bar com imagem do banner
              SliverAppBar(
                expandedHeight: ResponsiveUtils.isMobile(context) ? 200 : 250,
                pinned: true,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (evento.bannerUrl.isNotEmpty)
                        Image.network(
                          evento.bannerUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) => Container(
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.image_not_supported,
                              size: ResponsiveUtils.getAdaptiveIconSize(context) * 2,
                            ),
                          ),
                        ),
                      // Gradiente para melhorar a legibilidade
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Conteúdo do evento
              SliverToBoxAdapter(
                child: Padding(
                  padding: ResponsiveUtils.getAdaptivePadding(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título do evento
                      Text(
                        evento.titulo,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveUtils.getAdaptiveFontSize(context, 24),
                        ),
                      ).animate().fadeIn().slideY(begin: 0.3, end: 0),
                      
                      SizedBox(height: ResponsiveUtils.isMobile(context) ? 16 : 20),
                      
                      // Data e Hora
                      _buildInfoRow(
                        context,
                        Icons.calendar_today,
                        DateFormat('dd/MM/yyyy').format(evento.dataInicio),
                      ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                      
                      SizedBox(height: ResponsiveUtils.isMobile(context) ? 8 : 10),
                      
                      _buildInfoRow(
                        context,
                        Icons.access_time,
                        DateFormat('HH:mm').format(evento.dataInicio),
                      ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                      
                      SizedBox(height: ResponsiveUtils.isMobile(context) ? 8 : 10),
                      
                      // Local
                      _buildInfoRow(
                        context,
                        Icons.location_on,
                        evento.local,
                      ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                      
                      SizedBox(height: ResponsiveUtils.isMobile(context) ? 4 : 5),
                      
                      // Descrição
                      if (evento.descricao.isNotEmpty) ...[
                        Text(
                          'Sobre o Evento',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsiveUtils.getAdaptiveFontSize(context, 20),
                          ),
                        ).animate().fadeIn().slideY(begin: 0.3, end: 0),
                        
                        SizedBox(height: ResponsiveUtils.isMobile(context) ? 8 : 10),
                        
                        Text(
                          evento.descricao,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: ResponsiveUtils.getAdaptiveFontSize(context, 16),
                          ),
                        ).animate().fadeIn().slideY(begin: 0.3, end: 0),
                      ],
                      
                      SizedBox(height: ResponsiveUtils.isMobile(context) ? 32 : 40),
                      
                      // Botão de Gerar Ingresso
                      SizedBox(
                        width: double.infinity,
                        height: ResponsiveUtils.isMobile(context) ? 48 : 56,
                        child: ElevatedButton(
                          onPressed: detalhesSomente || evento.dataInicio.isBefore(DateTime.now()) ? null : () async {
                            final scaffoldMessenger = ScaffoldMessenger.of(context);
                            try {
                              final user = await AuthService().getCurrentUser();
                              if (user == null) {
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(content: Text('Usuário não autenticado.')),
                                );
                                return;
                              }
                              if (evento.id == null || evento.id!.isEmpty) {
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(content: Text('Evento inválido. Tente novamente ou selecione outro evento.')),
                                );
                                return;
                              }
                              if (user.id.isEmpty) {
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(content: Text('Usuário inválido. Faça login novamente.')),
                                );
                                return;
                              }
                              final ingressoId = await IngressoService().gerarIngressoParaEvento(
                                eventoId: evento.id!,
                                compradorId: user.id,
                                nomeUsuario: user.name ?? user.email,
                                nomeEvento: evento.titulo,
                              );
                              print('[DEBUG] ingressoId retornado: ' + (ingressoId ?? 'null'));
                              if (ingressoId != null) {
                                if (context.mounted) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => IngressoDigitalScreen(ingressoId: ingressoId),
                                    ),
                                  );
                                }
                              } else {
                                throw Exception('Erro ao gerar ingresso.');
                              }
                            } catch (e) {
                              final msg = e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString();
                              final isLimite = msg.contains('limite de 3 ingressos');
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      if (isLimite)
                                        const Icon(Icons.error_outline, color: Colors.white, size: 28),
                                      if (isLimite)
                                        const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          isLimite
                                            ? 'Você já atingiu o limite de 3 ingressos para este evento.'
                                            : 'Erro: $msg',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: isLimite ? Colors.redAccent : null,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  duration: const Duration(seconds: 4),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(ResponsiveUtils.isMobile(context) ? 8 : 12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            evento.dataInicio.isBefore(DateTime.now()) || detalhesSomente
                              ? 'Evento Encerrado'
                              : 'Gerar Meu Ingresso',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getAdaptiveFontSize(context, 18),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ).animate().fadeIn().slideY(begin: 0.3, end: 0),
                      
                      SizedBox(height: ResponsiveUtils.isMobile(context) ? 16 : 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: ResponsiveUtils.getAdaptiveIconSize(context),
        ),
        SizedBox(width: ResponsiveUtils.isMobile(context) ? 12 : 16),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: ResponsiveUtils.getAdaptiveFontSize(context, 16),
            ),
          ),
        ),
      ],
    );
  }
} 