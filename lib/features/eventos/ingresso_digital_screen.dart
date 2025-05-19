import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../../shared/services/ingresso_service.dart';
import '../../shared/models/ingresso_model.dart';
import '../../shared/models/evento_model.dart';
import '../../shared/widgets/background_image.dart';

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
          title: const Text('Confirmação de ingresso'),
          backgroundColor: const Color(0xFFd4145a),
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
            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _IngressoTicket(
                    codigoQr: ingresso.codigoQr,
                    numeroIngresso: ingresso.id,
                    tituloEvento: evento.titulo,
                    local: evento.local,
                    dataInicio: evento.dataInicio,
                    logoPath: 'assets/images/logo_evento.png', // ajuste conforme seu asset
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _IngressoTicket extends StatelessWidget {
  final String codigoQr;
  final String numeroIngresso;
  final String tituloEvento;
  final String local;
  final DateTime dataInicio;
  final String logoPath;

  const _IngressoTicket({
    required this.codigoQr,
    required this.numeroIngresso,
    required this.tituloEvento,
    required this.local,
    required this.dataInicio,
    required this.logoPath,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.7, // Ocupa 90% da altura da tela
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFd4145a), Color(0xFF3a1c71)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          const Text(
            'MEU INGRESSO ELETRÔNICO',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(12),
            child: QrImageView(
              data: codigoQr,
              version: QrVersions.auto,
              size: 240,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.circle,
                color: Colors.red,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.circle,
                color: Colors.blue,
              ),
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Nº $numeroIngresso',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              children: [
                Expanded(child: Divider(color: Colors.white54, thickness: 1, endIndent: 8)),
                const Icon(Icons.circle, color: Colors.white54, size: 14),
                Expanded(child: Divider(color: Colors.white54, thickness: 1, indent: 8)),
              ],
            ),
          ),
          Text(
            tituloEvento,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 20),
              const SizedBox(width: 6),
              Text(local, style: const TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today, color: Colors.white, size: 20),
              const SizedBox(width: 6),
              Text(DateFormat('dd/MM/yyyy').format(dataInicio), style: const TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(width: 20),
              const Icon(Icons.access_time, color: Colors.white, size: 20),
              const SizedBox(width: 6),
              Text(DateFormat('HH:mm').format(dataInicio), style: const TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 24),
          Image.asset(logoPath, height: 80), // Logo do evento (aumentado)
          const SizedBox(height: 24),
        ],
      ),
    );
  }
} 