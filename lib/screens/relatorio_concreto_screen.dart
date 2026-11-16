
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/conferencia_registro_model.dart';
import '../services/conferencia_repository.dart';

class RelatorioConcretoScreen extends StatefulWidget {
  const RelatorioConcretoScreen({super.key});

  @override
  State<RelatorioConcretoScreen> createState() =>
      _RelatorioConcretoScreenState();
}

class _RelatorioConcretoScreenState
    extends State<RelatorioConcretoScreen> {
  final ConferenciaRepository _repository = ConferenciaRepository();

  List<ConferenciaRegistroModel> _conferencias = [];

  bool _carregando = true;
  late DateTime _mesSelecionado;

  static const List<String> _meses = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  @override
  void initState() {
    super.initState();

    final agora = DateTime.now();
    _mesSelecionado = DateTime(agora.year, agora.month);

    _carregarDados();
  }

  Future<void> _carregarDados() async {
    if (mounted) {
      setState(() => _carregando = true);
    }

    try {
      final dados = await _repository.carregar();

      if (!mounted) return;

      setState(() {
        _conferencias = dados;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() => _carregando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao carregar relatório.'),
        ),
      );
    }
  }

  String _normalizarRodovia(String rodovia) {
    return rodovia.trim().toUpperCase();
  }

  List<ConferenciaRegistroModel> get _registrosDoMes {
    return _conferencias.where((registro) {
      final rodovia = _normalizarRodovia(registro.rodovia);

      final rodoviaValida =
          rodovia == 'GO-110' || rodovia == 'GO-236';

      final volume = registro.volumeConcretoM3;

      return registro.dataHora.year == _mesSelecionado.year &&
          registro.dataHora.month == _mesSelecionado.month &&
          rodoviaValida &&
          volume != null &&
          volume.isFinite &&
          volume > 0;
    }).toList();
  }

  double _somarVolume(String rodovia) {
    return _registrosDoMes
        .where(
          (registro) =>
              _normalizarRodovia(registro.rodovia) ==
              _normalizarRodovia(rodovia),
        )
        .fold<double>(
          0,
          (total, registro) =>
              total + registro.volumeConcretoM3!,
        );
  }

  double get _totalGeral {
    return _somarVolume('GO-110') + _somarVolume('GO-236');
  }

  int _quantidadePorRodovia(String rodovia) {
    return _registrosDoMes
        .where(
          (registro) =>
              _normalizarRodovia(registro.rodovia) ==
              _normalizarRodovia(rodovia),
        )
        .length;
  }

  void _alterarMes(int quantidade) {
    setState(() {
      _mesSelecionado = DateTime(
        _mesSelecionado.year,
        _mesSelecionado.month + quantidade,
      );
    });
  }

  String _formatarVolume(double volume) {
    return '${volume.toStringAsFixed(3)} m³';
  }

  Widget _cardResumo({
    required String titulo,
    required double volume,
    required int quantidade,
    required IconData icone,
    required Color cor,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: cor.withOpacity(0.12),
              child: Icon(icone, color: cor, size: 27),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _formatarVolume(volume),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 21,
                      color: cor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$quantidade dispositivos com volume registrado',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _seletorMes() {
    final mes =
        '${_meses[_mesSelecionado.month - 1]} ${_mesSelecionado.year}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 12,
        ),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Mês anterior',
              onPressed: () => _alterarMes(-1),
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Text(
                mes,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Próximo mês',
              onPressed: () => _alterarMes(1),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listaRegistros() {
    final registros = [..._registrosDoMes]
      ..sort((a, b) => b.dataHora.compareTo(a.dataHora));

    if (registros.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 45,
                color: Colors.grey.shade500,
              ),
              const SizedBox(height: 10),
              const Text(
                'Nenhum volume registrado neste mês.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text(
                'Os dispositivos com medidas de concreto válidas aparecerão aqui.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: registros.map((registro) {
        final data = DateFormat('dd/MM/yyyy').format(registro.dataHora);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.water_damage_outlined),
            ),
            title: Text(
              registro.codigoDrenagem,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${registro.rodovia} • '
              '${registro.estaca ?? 'Estaca não informada'} • $data',
            ),
            trailing: Text(
              _formatarVolume(registro.volumeConcretoM3!),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatório de Concreto'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Atualizar dados',
            onPressed: _carregarDados,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _carregarDados,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _seletorMes(),
                  const SizedBox(height: 12),
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text(
                            'TOTAL GERAL DE CONCRETO',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatarVolume(_totalGeral),
                            style: const TextStyle(
                              fontSize: 29,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${_registrosDoMes.length} dispositivos com volume registrado',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _cardResumo(
                    titulo: 'GO-110',
                    volume: _somarVolume('GO-110'),
                    quantidade: _quantidadePorRodovia('GO-110'),
                    icone: Icons.construction,
                    cor: Colors.blue,
                  ),
                  _cardResumo(
                    titulo: 'GO-236',
                    volume: _somarVolume('GO-236'),
                    quantidade: _quantidadePorRodovia('GO-236'),
                    icone: Icons.engineering,
                    cor: Colors.green,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'DETALHAMENTO DOS DISPOSITIVOS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _listaRegistros(),
                ],
              ),
            ),
    );
  }
}
