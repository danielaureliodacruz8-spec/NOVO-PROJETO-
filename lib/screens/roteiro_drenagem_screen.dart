
import 'package:flutter/material.dart';

import '../models/drenagem_model.dart';
import '../services/identificacao_drenagem_service.dart';
import '../services/calculo_concreto_service.dart';

class RoteiroDrenagemScreen extends StatefulWidget {
  final DrenagemModel drenagem;
  final double latitude;
  final double longitude;
  final double? precisaoMetros;
  final PontoDrenagemObra? pontoDrenagem;
  final double? distanciaMetros;

  const RoteiroDrenagemScreen({
    super.key,
    required this.drenagem,
    required this.latitude,
    required this.longitude,
    this.precisaoMetros,
    this.pontoDrenagem,
    this.distanciaMetros,
  });

  @override
  State<RoteiroDrenagemScreen> createState() =>
      _RoteiroDrenagemScreenState();
}

class _RoteiroDrenagemScreenState extends State<RoteiroDrenagemScreen> {
  late List<bool> _itensConcluidos;

  final TextEditingController _observacaoController =
      TextEditingController();

  final TextEditingController _larguraController =
      TextEditingController();

  final TextEditingController _comprimentoController =
      TextEditingController();

  final TextEditingController _espessuraController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    _itensConcluidos = List<bool>.filled(
      widget.drenagem.roteiroPadrao.length,
      false,
    );
  }

  @override
  void dispose() {
    _observacaoController.dispose();
    _larguraController.dispose();
    _comprimentoController.dispose();
    _espessuraController.dispose();
    super.dispose();
  }

  int get _quantidadeConcluida =>
      _itensConcluidos.where((item) => item).length;

  bool get _roteiroConcluido =>
      _itensConcluidos.isNotEmpty &&
      _quantidadeConcluida == _itensConcluidos.length;

  bool get _ehTss =>
      widget.drenagem.tipo == TipoDrenagem.transposicaoSarjeta;

  double? _converterMedida(String texto) {
    return double.tryParse(texto.trim().replaceAll(',', '.'));
  }

  double? get _volumeConcreto {
    if (!_ehTss) return null;

    final largura = _converterMedida(_larguraController.text);
    final comprimento = _converterMedida(_comprimentoController.text);
    final espessura = _converterMedida(_espessuraController.text);

    if (largura == null ||
        comprimento == null ||
        espessura == null) {
      return null;
    }

    return CalculoConcretoService.calcularTss(
      largura: largura,
      comprimento: comprimento,
      espessura: espessura,
    );
  }

  void _finalizarRoteiro() {
    final itensFinalizados = List.generate(
      _itensConcluidos.length,
      (index) => _itensConcluidos[index]
          ? widget.drenagem.roteiroPadrao[index]
          : null,
    ).whereType<String>().toList();

    final resultado = <String, dynamic>{
      'drenagem': widget.drenagem,
      'latitude': widget.latitude,
      'longitude': widget.longitude,
      'precisaoMetros': widget.precisaoMetros,
      'pontoDrenagem': widget.pontoDrenagem,
      'distanciaMetros': widget.distanciaMetros,
      'itensConcluidos': itensFinalizados,
      'observacao': _observacaoController.text.trim(),
      'dataHora': DateTime.now(),
    };

    if (_ehTss) {
      resultado['medidasConcreto'] = {
        'largura': _converterMedida(_larguraController.text),
        'comprimento': _converterMedida(_comprimentoController.text),
        'espessura': _converterMedida(_espessuraController.text),
      };

      resultado['volumeConcretoM3'] = _volumeConcreto;
    }

    Navigator.of(context).pop(resultado);
  }

  @override
  Widget build(BuildContext context) {
    final total = _itensConcluidos.length;
    final progresso =
        total == 0 ? 0.0 : _quantidadeConcluida / total;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Roteiro de conferência'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _cabecalho(progresso),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _cardLocalizacao(),
                  const SizedBox(height: 18),
                  const Text(
                    'ITENS DE CONFERÊNCIA',
                    style: TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.7,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(
                    widget.drenagem.roteiroPadrao.length,
                    _cardItemRoteiro,
                  ),
                  if (_ehTss) ...[
                    const SizedBox(height: 18),
                    _cardMedidasConcreto(),
                  ],
                  const SizedBox(height: 12),
                  _campoObservacao(),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _roteiroConcluido
                          ? _finalizarRoteiro
                          : null,
                      icon: const Icon(Icons.check_circle_rounded),
                      label: Text(
                        _roteiroConcluido
                            ? 'FINALIZAR CONFERÊNCIA'
                            : 'CONCLUA TODOS OS ITENS',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16803C),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            const Color(0xFFE2E8F0),
                        disabledForegroundColor:
                            const Color(0xFF64748B),
                      ),
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

  Widget _cabecalho(double progresso) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF073B72),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.drenagem.codigo,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.drenagem.identificacao,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 17),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PROGRESSO DO ROTEIRO',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              Text(
                '$_quantidadeConcluida/${_itensConcluidos.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progresso,
              minHeight: 9,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF65D58A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardLocalizacao() {
    final ponto = widget.pontoDrenagem;
    final estaca = ponto?.estaca;
    final lado = ponto?.lado;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: Color(0xFF0B5CAD),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'LOCALIZAÇÃO DA CONFERÊNCIA',
                style: TextStyle(
                  color: Color(0xFF0B5CAD),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (estaca != null && lado != null)
            _linhaInfo(
              Icons.signpost_outlined,
              'Estaca $estaca • $lado',
            ),
          if (widget.distanciaMetros != null) ...[
            const SizedBox(height: 8),
            _linhaInfo(
              Icons.near_me_outlined,
              'Distância do dispositivo: '
              '${widget.distanciaMetros!.toStringAsFixed(1)} m',
            ),
          ],
          const SizedBox(height: 8),
          _linhaInfo(
            Icons.gps_fixed_rounded,
            '${widget.latitude.toStringAsFixed(6)}, '
            '${widget.longitude.toStringAsFixed(6)}',
          ),
          if (widget.precisaoMetros != null) ...[
            const SizedBox(height: 8),
            _linhaInfo(
              Icons.my_location_rounded,
              'Precisão GPS: '
              '± ${widget.precisaoMetros!.toStringAsFixed(1)} m',
            ),
          ],
        ],
      ),
    );
  }

  Widget _cardItemRoteiro(int index) {
    final concluido = _itensConcluidos[index];
    final texto = widget.drenagem.roteiroPadrao[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: concluido ? const Color(0xFFEAF8F0) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: concluido
              ? const Color(0xFF86D5A5)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: CheckboxListTile(
        value: concluido,
        onChanged: (valor) {
          setState(() {
            _itensConcluidos[index] = valor ?? false;
          });
        },
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: const Color(0xFF16803C),
        checkboxShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        title: Text(
          '${index + 1}. $texto',
          style: TextStyle(
            color: concluido
                ? const Color(0xFF166534)
                : const Color(0xFF1E293B),
            fontSize: 14,
            fontWeight:
                concluido ? FontWeight.w700 : FontWeight.w500,
            decoration:
                concluido ? TextDecoration.lineThrough : null,
            height: 1.3,
          ),
        ),
      ),
    );
  }

  Widget _cardMedidasConcreto() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.calculate_outlined,
                color: Color(0xFF0B5CAD),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'MEDIDAS E VOLUME DE CONCRETO - TSS',
                  style: TextStyle(
                    color: Color(0xFF0B5CAD),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Informe as dimensões executadas em metros.',
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          _campoMedida(
            controller: _larguraController,
            label: 'Largura (m)',
          ),
          const SizedBox(height: 10),
          _campoMedida(
            controller: _comprimentoController,
            label: 'Comprimento (m)',
          ),
          const SizedBox(height: 10),
          _campoMedida(
            controller: _espessuraController,
            label: 'Espessura (m)',
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'VOLUME CALCULADO',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  CalculoConcretoService.formatarVolume(
                    _volumeConcreto,
                  ),
                  style: const TextStyle(
                    color: Color(0xFF166534),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _campoMedida({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        suffixText: 'm',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _campoObservacao() {
    return TextField(
      controller: _observacaoController,
      maxLines: 5,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: 'Observações da conferência',
        alignLabelWithHint: true,
        hintText:
            'Registre medidas, não conformidades, condições do dispositivo '
            'ou outras informações importantes.',
        prefixIcon: const Padding(
          padding: EdgeInsets.only(bottom: 78),
          child: Icon(Icons.notes_rounded),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFE2E8F0),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFE2E8F0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF0B5CAD),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _linhaInfo(IconData icone, String texto) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icone,
          size: 18,
          color: const Color(0xFF64748B),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
