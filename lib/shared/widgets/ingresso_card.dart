import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class IngressoCard extends StatelessWidget {
  final String evento;
  final String participante;
  final String numeroIngresso;
  final String status;
  final String qrData;

  const IngressoCard({
    super.key,
    required this.evento,
    required this.participante,
    required this.numeroIngresso,
    required this.status,
    required this.qrData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF833ab4), Color(0xFFfd1d1d), Color(0xFFfcb045)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          QrImageView(
            data: qrData,
            size: 120,
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            evento,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.white54, thickness: 1),
          const SizedBox(height: 8),
          _infoRow(Icons.person, "Participante", participante),
          _infoRow(Icons.confirmation_num, "Nº do Ingresso", numeroIngresso),
          _infoRow(Icons.verified, "Status", status),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            "$label:",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
} 