import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../../shared/services/ingresso_service.dart';
import '../../shared/models/ingresso_model.dart';
import '../../shared/models/evento_model.dart';
import '../../shared/widgets/background_image.dart';
import '../../shared/utils/responsive_utils.dart';
import '../../shared/widgets/ingresso_card.dart';
import '../../shared/widgets/ingresso_ticket.dart';

class IngressoDigitalScreen extends StatefulWidget {
  final String ingressoId;
  const IngressoDigitalScreen({super.key, required this.ingressoId});

  @override
  State<IngressoDigitalScreen> createState() => _IngressoDigitalScreenState();
}

class _IngressoDigitalScreenState extends State<IngressoDigitalScreen> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = IngressoService().buscarIngressoEEvento(widget.ingressoId);
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Image.asset('assets/images/logo_tickts.png', height: 38, fit: BoxFit.contain),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            }
            final ingresso = snapshot.data!['ingresso'] as IngressoModel;
            final evento = snapshot.data!['evento'] as EventoModel;
            final participante = ingresso.nomeUsuario ?? 'Não informado';
            final dataFormatada = DateFormat('dd "de" MMMM "de" yyyy', 'pt_BR').format(evento.dataInicio);
            final horaFormatada = DateFormat('HH:mm').format(evento.dataInicio) + 'h';
            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: ResponsiveUtils.getAdaptivePadding(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IngressoTicket(
                          titulo: 'Confirmação de ingresso',
                          numeroIngresso: ingresso.numeroIngresso,
                          nomeEvento: evento.titulo,
                          participante: participante,
                          data: dataFormatada,
                          hora: horaFormatada,
                          qrData: ingresso.codigoQr ?? '',
                          logoUrl: evento.logoEvento ?? '',
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: ResponsiveUtils.getAdaptiveFontSize(context, 16),
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveUtils.getAdaptiveFontSize(context, 16),
            ),
          ),
        ),
      ],
    );
  }
} 