import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../../shared/services/ingresso_service.dart';
import '../../shared/models/ingresso_model.dart';
import '../../shared/models/evento_model.dart';

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
    return Scaffold(
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
                  numeroIngresso: ingresso.numeroIngresso,
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
    return Container(
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
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          const Text(
            'MEU INGRESSO ELETRÔNICO',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(12),
            child: QrImageView(
              data: codigoQr,
              version: QrVersions.auto,
              size: 180,
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
          const SizedBox(height: 8),
          Text(
            'Nº $numeroIngresso',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Expanded(child: Divider(color: Colors.white54, thickness: 1, endIndent: 8)),
                const Icon(Icons.circle, color: Colors.white54, size: 12),
                Expanded(child: Divider(color: Colors.white54, thickness: 1, indent: 8)),
              ],
            ),
          ),
          Text(
            tituloEvento,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 18),
              const SizedBox(width: 4),
              Text(local, style: const TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today, color: Colors.white, size: 18),
              const SizedBox(width: 4),
              Text(DateFormat('dd/MM/yyyy').format(dataInicio), style: const TextStyle(color: Colors.white)),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, color: Colors.white, size: 18),
              const SizedBox(width: 4),
              Text(DateFormat('HH:mm').format(dataInicio), style: const TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),
          Image.asset(logoPath, height: 48), // Logo do evento
          const SizedBox(height: 16),
        ],
      ),
    );
  }
} 