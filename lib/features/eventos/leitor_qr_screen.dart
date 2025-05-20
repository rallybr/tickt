import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../shared/widgets/background_image.dart';
import 'ingresso_digital_screen.dart';
import 'package:audioplayers/audioplayers.dart';

class LeitorQrScreen extends StatefulWidget {
  const LeitorQrScreen({super.key});

  @override
  State<LeitorQrScreen> createState() => _LeitorQrScreenState();
}

class _LeitorQrScreenState extends State<LeitorQrScreen> {
  String? _qrCode;
  bool _found = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> _playBeep() async {
    await _audioPlayer.play(AssetSource('bip.mp3'));
  }

  void _onDetect(BarcodeCapture capture) {
    if (_found) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode != null && barcode.rawValue != null) {
      setState(() {
        _qrCode = barcode.rawValue;
        _found = true;
      });
      _playBeep();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => IngressoDigitalScreen(ingressoId: barcode.rawValue!),
        ),
      ).then((_) {
        setState(() {
          _found = false;
        });
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
            final double boxSize = constraints.maxWidth * 0.7;
            return Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 80),
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Borda 3D com gradiente e sombra
                          Container(
                            width: boxSize + 36,
                            height: boxSize + 36,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF42a5f5), Color(0xFF66bb6a)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                          ),
                          // Quadrado da câmera
                          Container(
                            width: boxSize,
                            height: boxSize,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: MobileScanner(
                                onDetect: _onDetect,
                              ),
                            ),
                          ),
                          // Overlay para escurecer o fundo fora do quadrado
                          Positioned.fill(
                            child: IgnorePointer(
                              child: CustomPaint(
                                painter: _ScannerOverlayPainter(boxSize: boxSize),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Nova área de dados ocupando toda a parte inferior
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  top: 80 + boxSize + 36 + 16, // 80 topo + scanner + margem
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.32),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Dados do QR Code',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 18),
                        if (_qrCode == null)
                          const Text(
                            'Aponte a câmera para um QR Code válido.',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                            textAlign: TextAlign.center,
                          )
                        else
                          Text(
                            _qrCode!,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        // Espaço extra para visual mais clean
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  final double boxSize;
  _ScannerOverlayPainter({required this.boxSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    final rect = Offset.zero & size;
    final scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, boxSize / 2 + 80),
      width: boxSize,
      height: boxSize,
    );
    // Desenha o overlay escuro
    canvas.drawRect(rect, paint);
    // Recorta o quadrado central
    canvas.saveLayer(rect, Paint());
    paint.blendMode = BlendMode.clear;
    canvas.drawRRect(
      RRect.fromRectAndRadius(scanRect, Radius.circular(20)),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 