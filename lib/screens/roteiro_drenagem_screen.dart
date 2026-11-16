
import 'package:flutter/material.dart';

import '../models/drenagem_model.dart';
import '../services/identificacao_drenagem_service.dart';
import '../services/calculo_tss_service.dart';

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

  final CalculoTssService _calculoTssService = CalculoTssService();

  TipoTssProjeto _tipoTss = tiposTssProjeto.first;
  bool _usarMedicaoReal = false;

  final TextEditingController _observacaoController =
      TextEditingController();

  final TextEditingController _comprimentoTssController =
      TextEditingController();

  final TextEditingController _areaBaseController =
      TextEditingController();

  final TextEditingController _larguraLajeController =
      TextEditingController();

  final TextEditingController _espessuraLajeController =
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
    _comprimentoTssController.dispose();
    _areaBaseController.dispose();
    _larguraLajeController.dispose();
    _espessuraLajeController.dispose();
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
    final valor = double.tryParse(
      texto.trim().replaceAll(',', '.'),
    );

    if (valor == null || !valor.isFinite || valor <= 0) {
      return null;
    }

    return valor;
  }

  ResultadoVolumeTss? get _resultadoTss {
    if (!_ehTss) return null;

    final comprimento = _converterMedida(
      _comprimentoTssController.text,
    );

    if (comprimento == null) return null;

    try {
      if (!_usarMedicaoReal) {
        return _calculoTssService.calcularPorProjeto(
          tipo: _tipoTss,
          comprimentoExecutadoMetros: comprimento,
        );
      }

      final areaBase = _converterMedida(
        _areaBaseController.text,
      );

      final larguraLaje = _converterMedida(
        _larguraLajeController.text,
      );

      final espessuraLaje = _converterMedida(
        _espessuraLajeController.text,
      );

      if (areaBase == null ||
          larguraLaje == null ||
          espessuraLaje == null) {
        return null;
      }

      return _calculoTssService.calcularPorMedicaoReal(
        tipo: _tipoTss,
        comprimentoExecutadoMetros: comprimento,
        areaLiquidaBaseMetrosQuadrados: areaBase,
        larguraLajeMetros: larguraLaje,
        espessuraLajeMetros: espessuraLaje,
      );
    } catch (_) {
      return null;
    }
  }

  bool get _podeFinalizar =>
      _roteiroConcluido &&
      (!_ehTss || _resultadoTss != null);

  void _finalizarRoteiro() {
    final resultadoTss = _ehTss ? _resultadoTss : null;

    if (_ehTss && resultadoTss == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Preencha corretamente as medidas da TSS.',
          ),
        ),
      );
      return;
    }

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

    if (resultadoTss != null) {
      resultado['medidasConcreto'] = {
        'comprimentoExecutado':
            resultadoTss.comprimentoExecutadoMetros,
        'areaLiquidaBase':
            resultadoTss.areaLiquidaBaseMedida,
        'areaLiquidaBaseProjeto':
            resultadoTss.areaLiquidaBaseProjeto,
        'larguraLaje':
            resultadoTss.larguraLajeMedida,
        'espessuraLaje':
            resultadoTss.espessuraLajeMedida,
      };

      resultado['tipoTss'] = resultadoTss.tipo.codigo;
      resultado['calculadoPorMedicaoReal'] =
          resultadoTss.calculadoPorMedicaoReal;

      resultado['resultadoTss'] = resultadoTss.toMap();

      resultado['volumeConcretoM3'] =
          resultadoTss.volumeTotalConcreto;
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
                    _cardMedidasTss(),
                  ],
                  const SizedBox(height: 12),
                  _campoObservacao(),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          _podeFinalizar ? _finalizarRoteiro : null,
                      icon: const Icon(Icons.check_circle_rounded),
                      label: Text(
                        !_roteiroConcluido
                            ? 'CONCLUA TODOS OS ITENS'
                            : (_ehTss && _resultadoTss == null)
                                ? 'PREENCHA AS MEDIDAS DA TSS'
                                : 'FINALIZAR CONFERÊNCIA',
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

  Widget _cardMedidasTss() {
    final resultado = _resultadoTss;

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
                  'CÁLCULO DE CONCRETO - TSS',
                  style: TextStyle(
                    color: Color(0xFF0B5CAD),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'TIPO DE TSS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 7),
          DropdownButtonFormField<TipoTssProjeto>(
            value: _tipoTss,
            isExpanded: true,
            decoration: _decoracaoCampo('Selecione o tipo'),
            items: tiposTssProjeto.map((tipo) {
              return DropdownMenuItem<TipoTssProjeto>(
                value: tipo,
                child: Text(tipo.codigo),
              );
            }).toList(),
            onChanged: (tipo) {
              if (tipo == null) return;
              setState(() {
                _tipoTss = tipo;
              });
            },
          ),
          const SizedBox(height: 8),
          Text(
            _tipoTss.descricao,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'MÉTODO DE CÁLCULO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 7),
          DropdownButtonFormField<bool>(
            value: _usarMedicaoReal,
            decoration: _decoracaoCampo('Método'),
            items: const [
              DropdownMenuItem(
                value: false,
                child: Text('Consumo de projeto'),
              ),
              DropdownMenuItem(
                value: true,
                child: Text('Medidas reais executadas'),
              ),
            ],
            onChanged: (valor) {
              if (valor == null) return;
              setState(() {
                _usarMedicaoReal = valor;
              });
            },
          ),
          const SizedBox(height: 16),
          _campoMedida(
            controller: _comprimentoTssController,
            label: 'Comprimento executado',
            unidade: 'm',
          ),
          const SizedBox(height: 8),
          const Text(
            'Limite cadastrado: 3,00 m por segmento.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
            ),
          ),
          if (_usarMedicaoReal) ...[
            const SizedBox(height: 16),
            const Text(
              'MEDIDAS REAIS DA BASE E DA LAJE',
              style: TextStyle(
                color: Color(0xFF0B5CAD),
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            _campoMedida(
              controller: _areaBaseController,
              label: 'Área líquida da seção da base',
              unidade: 'm²',
            ),
            const SizedBox(height: 8),
            _campoMedida(
              controller: _larguraLajeController,
              label: 'Largura real da laje',
              unidade: 'm',
            ),
            const SizedBox(height: 8),
            _campoMedida(
              controller: _espessuraLajeController,
              label: 'Espessura real da laje',
              unidade: 'm',
            ),
            const SizedBox(height: 8),
            const Text(
              'A área da base deve representar somente o concreto '
              'da base, sem incluir a laje nem o vazio da sarjeta.',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11,
              ),
            ),
          ],
          const SizedBox(height: 18),
          if (resultado == null)
            _cardResultadoVazio()
          else
            _cardResultadoTss(resultado),
        ],
      ),
    );
  }

  Widget _cardResultadoVazio() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Preencha as medidas para visualizar o cálculo.',
        style: TextStyle(
          color: Color(0xFF64748B),
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _cardResultadoTss(ResultadoVolumeTss resultado) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            resultado.calculadoPorMedicaoReal
                ? 'RESULTADO PELAS MEDIDAS REAIS'
                : 'RESULTADO PELO CONSUMO DE PROJETO',
            style: const TextStyle(
              color: Color(0xFF0B5CAD),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          _linhaResultado(
            'Base - fck ≥ 20 MPa',
            resultado.volumeBaseFck20,
          ),
          const SizedBox(height: 7),
          _linhaResultado(
            'Laje - fck ≥ 25 MPa',
            resultado.volumeLajeFck25,
          ),
          const Divider(height: 22),
          const Text(
            'TOTAL DE CONCRETO',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${resultado.volumeTotalConcreto.toStringAsFixed(3)} m³',
            style: const TextStyle(
              color: Color(0xFF166534),
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'COMPARAÇÃO COM O PROJETO',
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          _linhaComparacao(
            'Base',
            resultado.volumeBaseFck20Projeto,
            resultado.volumeBaseFck20Diferenca,
          ),
          const SizedBox(height: 6),
          _linhaComparacao(
            'Laje',
            resultado.volumeLajeFck25Projeto,
            resultado.volumeLajeFck25Diferenca,
          ),
          const SizedBox(height: 10),
          Text(
            'Diferença total: '
            '${resultado.diferencaTotalConcreto >= 0 ? '+' : ''}'
            '${resultado.diferencaTotalConcreto.toStringAsFixed(3)} m³ '
            '(${resultado.percentualDiferencaTotal.toStringAsFixed(1)}%)',
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Escavação, formas e aço são estimativas calculadas '
            'pelos consumos de projeto, não medições reais.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _linhaResultado(String titulo, double volume) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            titulo,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 12,
            ),
          ),
        ),
        Text(
          '${volume.toStringAsFixed(3)} m³',
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _linhaComparacao(
    String titulo,
    double projeto,
    double diferenca,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$titulo: projeto ${projeto.toStringAsFixed(3)} m³',
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 11,
            ),
          ),
        ),
        Text(
          '${diferenca >= 0 ? '+' : ''}'
          '${diferenca.toStringAsFixed(3)} m³',
          style: const TextStyle(
            color: Color(0xFF334155),
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  InputDecoration _decoracaoCampo(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _campoMedida({
    required TextEditingController controller,
    required String label,
    required String unidade,
  }) {
    return TextField(
      controller: controller,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        suffixText: unidade,
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
