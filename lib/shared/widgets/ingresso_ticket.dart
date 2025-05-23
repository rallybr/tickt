import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class IngressoTicket extends StatelessWidget {
  final String titulo;
  final String numeroIngresso;
  final String nomeEvento;
  final String participante;
  final String data;
  final String hora;
  final String qrData;
  final String? logoUrl;

  const IngressoTicket({
    super.key,
    required this.titulo,
    required this.numeroIngresso,
    required this.nomeEvento,
    required this.participante,
    required this.data,
    required this.hora,
    required this.qrData,
    this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final layoutWidth = 350.0;
    final qrSize = layoutWidth * 0.8 * 0.9; // 10% menor que antes
    return Center(
      child: Container(
        width: layoutWidth,
        height: screenHeight * 0.75, // Ocupa 75% da altura da tela
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFd4145a), Color(0xFF833ab4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Stack(
          children: [
            // Recortes laterais (círculos) ao lado da linha tracejada
            Positioned(
              left: -18,
              top: 380, // Aproximadamente na altura da linha tracejada
              child: _circleCutout(),
            ),
            Positioned(
              right: -18,
              top: 380, // Aproximadamente na altura da linha tracejada
              child: _circleCutout(),
            ),
            // Conteúdo do ingresso
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      'INGRESSO ELETRÔNICO',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: QrImageView(
                        data: qrData,
                        size: qrSize,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.circle,
                          color: Color(0xFFd4145a),
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.circle,
                          color: Color(0xFF1a237e),
                        ),
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nº $numeroIngresso',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _dottedLine(),
                    const SizedBox(height: 14),
                    Text(
                      nomeEvento,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person, color: Colors.white, size: 22),
                        const SizedBox(width: 4),
                        Text(
                          participante,
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        const SizedBox(width: 12),
                        const Text('#EuVou', style: TextStyle(color: Colors.white70, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.white, size: 22),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            data,
                            style: const TextStyle(color: Colors.white, fontSize: 18),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.access_time, color: Colors.white, size: 22),
                        const SizedBox(width: 4),
                        Text(
                          hora,
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    if (logoUrl != null && logoUrl!.isNotEmpty)
                      Image.network(
                        logoUrl!,
                        height: 126,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleCutout() {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _dottedLine() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(30, (index) =>
        Container(
          width: 4,
          height: 2,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          color: index % 2 == 0 ? Colors.white : Colors.transparent,
        ),
      ),
    );
  }
} 