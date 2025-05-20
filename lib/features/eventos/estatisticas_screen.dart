import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../shared/services/evento_service.dart';
import '../../shared/services/ingresso_service.dart';
import '../../shared/models/evento_model.dart';
import '../../shared/models/ingresso_model.dart';
import '../../shared/widgets/background_image.dart';

class EstatisticasScreen extends StatefulWidget {
  const EstatisticasScreen({super.key});

  @override
  State<EstatisticasScreen> createState() => _EstatisticasScreenState();
}

class _EstatisticasScreenState extends State<EstatisticasScreen> {
  List<EventoModel> _eventos = [];
  EventoModel? _eventoSelecionado;
  List<IngressoModel> _ingressos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final eventos = await EventoService().listarEventos();
    EventoModel? evento = eventos.isNotEmpty ? eventos.first : null;
    List<IngressoModel> ingressos = [];
    if (evento != null) {
      ingressos = await IngressoService().buscarIngressosDoEvento(evento.id!);
    }
    setState(() {
      _eventos = eventos;
      _eventoSelecionado = evento;
      _ingressos = ingressos;
      _loading = false;
    });
  }

  Future<void> _onEventoSelecionado(EventoModel? evento) async {
    if (evento == null) return;
    setState(() {
      _loading = true;
      _eventoSelecionado = evento;
    });
    final ingressos = await IngressoService().buscarIngressosDoEvento(evento.id!);
    setState(() {
      _ingressos = ingressos;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = _ingressos.length;
    final presentes = _ingressos.where((i) => i.status == 'presente').length;
    final ausentes = _ingressos.where((i) => i.status != 'presente').length;
    final double percentPresentes = total > 0 ? (presentes / total) * 100 : 0;
    final double percentAusentes = total > 0 ? (ausentes / total) * 100 : 0;
    final ingressosPorDia = <String, int>{};
    for (final ingresso in _ingressos) {
      final dia = '${ingresso.dataCompra.day.toString().padLeft(2, '0')}/${ingresso.dataCompra.month.toString().padLeft(2, '0')}';
      ingressosPorDia[dia] = (ingressosPorDia[dia] ?? 0) + 1;
    }
    final dias = ingressosPorDia.keys.toList()..sort();
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
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButton<EventoModel>(
                      value: _eventoSelecionado,
                      isExpanded: true,
                      hint: const Text('Selecione um evento'),
                      items: _eventos.map((evento) {
                        return DropdownMenuItem(
                          value: evento,
                          child: Text(evento.titulo),
                        );
                      }).toList(),
                      onChanged: _onEventoSelecionado,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatCard(label: 'Ingressos', value: total, color: Colors.blue),
                        _StatCard(label: 'Presentes', value: presentes, color: Colors.green),
                        _StatCard(label: 'Ausentes', value: ausentes, color: Colors.red),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text('Ingressos gerados por dia', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          barGroups: [
                            for (int i = 0; i < dias.length; i++)
                              BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: ingressosPorDia[dias[i]]!.toDouble(),
                                    color: Colors.blueAccent,
                                    width: 18,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ],
                              ),
                          ],
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final idx = value.toInt();
                                  if (idx >= 0 && idx < dias.length) {
                                    return Text(dias[idx], style: const TextStyle(color: Colors.white, fontSize: 12));
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ),
                          gridData: FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text('Proporção de Presentes e Ausentes', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: presentes.toDouble(),
                              color: Colors.blue,
                              title: 'Presentes\n${percentPresentes.toStringAsFixed(1)}%',
                              radius: 60,
                              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            PieChartSectionData(
                              value: ausentes.toDouble(),
                              color: Colors.red,
                              title: 'Ausentes\n${percentAusentes.toStringAsFixed(1)}%',
                              radius: 60,
                              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                          sectionsSpace: 4,
                          centerSpaceRadius: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color, width: 3),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
              shadows: const [Shadow(color: Colors.black26, blurRadius: 4)],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              shadows: [Shadow(color: Colors.white, blurRadius: 2)],
            ),
          ),
        ],
      ),
    );
  }
} 