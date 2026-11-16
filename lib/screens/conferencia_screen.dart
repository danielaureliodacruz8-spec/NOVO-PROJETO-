
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/conferencia_registro_model.dart';
import '../models/drenagem_model.dart';
import 'localizacao_automatica_screen.dart';

class ConferenciaScreen extends StatefulWidget {
  const ConferenciaScreen({super.key});

  @override
  State<ConferenciaScreen> createState() => _ConferenciaScreenState();
}

class _ConferenciaScreenState extends State<ConferenciaScreen> {
  final Uuid _uuid = Uuid();

  final List<ConferenciaRegistroModel> _historico =
      <ConferenciaRegistroModel>[];

  bool _carregando = false;

  Future<void> _iniciarConferencia() async {
    if (_carregando) return;

    setState(() => _carregando = true);

    try {
      final resultado = await Navigator.of(context).push<dynamic>(
        MaterialPageRoute(
          builder: (context) => const LocalizacaoAutomaticaScreen(),
        ),
      );

      if (!mounted || resultado == null) return;

      if (resultado is! Map) {
        _mostrarMensagem(
          'Não foi possível obter os dados da conferência.',
          erro: true,
        );
        return;
      }

      final dados = Map<String, dynamic>.from(resultado);
      final registro = _criarRegistro(dados);

      if (registro == null) {
        _mostrarMensagem(
          'Não foi possível salvar. Os dados da drenagem estão incompletos.',
          erro: true,
        );
        return;
      }

      setState(() {
        _historico.insert(0, registro);
      });

      _mostrarMensagem('Conferência salva com sucesso.');
    } catch (erro) {
      if (!mounted) return;

      _mostrarMensagem(
        'Erro ao iniciar conferência: $erro',
        erro: true,
      );
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  void _mostrarMensagem(String mensagem, {bool erro = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: erro
            ? const Color(0xFFB42318)
            : const Color(0xFF16803C),
        content: Text(
          mensagem,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _abrirDetalhes(
    ConferenciaRegistroModel registro,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DetalheConferenciaSheet(
        registro: registro,
      ),
    );
  }

  Future<void> _confirmarExclusao(
    ConferenciaRegistroModel registro,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir conferência?'),
        content: Text(
          'Deseja excluir a conferência '
          '${registro.codigoDrenagem} do histórico?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCELAR'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB42318),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('EXCLUIR'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    setState(() {
      _historico.removeWhere((item) => item.id == registro.id);
    });

    _mostrarMensagem('Conferência removida do histórico.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            _cabecalho(),
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF0B5CAD),
                onRefresh: () async {
                  await Future<void>.delayed(
                    const Duration(milliseconds: 600),
                  );
                  if (mounted) setState(() {});
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                  children: [
                    _cardStatus(),
                    const SizedBox(height: 18),
                    _botaoIniciar(),
                    const SizedBox(height: 28),
                    _tituloHistorico(),
                    const SizedBox(height: 12),
                    if (_historico.isEmpty)
                      _historicoVazio()
                    else
                      ..._historico.map(_cardHistorico),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cabecalho() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: const BoxDecoration(
        color: Color(0xFF073B72),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.engineering_rounded,
                  color: Color(0xFF073B72),
                  size: 29,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STRATA ENGENHARIA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Fiscalização de Drenagem',
                      style: TextStyle(
                        color: Color(0xFFBFDBFE),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.account_balance_rounded,
                color: Colors.white,
                size: 29,
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'GO-236',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Flores de Goiás – Entr. BR-020',
            style: TextStyle(
              color: Color(0xFFBFDBFE),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardStatus() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: Color(0xFFEAF8F0),
            child: Icon(
              Icons.gps_fixed_rounded,
              color: Color(0xFF16803C),
              size: 25,
            ),
          ),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SISTEMA PRONTO',
                  style: TextStyle(
                    color: Color(0xFF16803C),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'GPS, identificação e roteiro de conferência disponíveis.',
                  style: TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 13,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _botaoIniciar() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: _carregando ? null : _iniciarConferencia,
        icon: _carregando
            ? const SizedBox(
                width: 23,
                height: 23,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Icon(
                Icons.add_location_alt_rounded,
                size: 25,
              ),
        label: Text(
          _carregando
              ? 'OBTENDO LOCALIZAÇÃO...'
              : 'INICIAR CONFERÊNCIA AUTOMÁTICA',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0B5CAD),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF7CA8CF),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _tituloHistorico() {
    return Row(
      children: [
        const Icon(
          Icons.history_rounded,
          color: Color(0xFF0B5CAD),
          size: 22,
        ),
        const SizedBox(width: 9),
        const Text(
          'HISTÓRICO DE CONFERÊNCIAS',
          style: TextStyle(
            color: Color(0xFF334155),
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2FE),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_historico.length}',
            style: const TextStyle(
              color: Color(0xFF075985),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _historicoVazio() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 38,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 46,
            color: Color(0xFF94A3B8),
          ),
          SizedBox(height: 13),
          Text(
            'Nenhuma conferência registrada',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF334155),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Inicie uma conferência para identificar o dispositivo e registrar as medições de campo.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardHistorico(ConferenciaRegistroModel registro) {
    final possuiVolume = registro.volumeConcretoM3 != null;
    final possuiTss = registro.tipoTss != null &&
        registro.tipoTss!.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C0F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _abrirDetalhes(registro),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 15, 10, 15),
          child: Row(
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: possuiTss
                      ? const Color(0xFFF3E8FF)
                      : const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  possuiTss
                      ? Icons.architecture_rounded
                      : Icons.water_damage_rounded,
                  color: possuiTss
                      ? const Color(0xFF7E22CE)
                      : const Color(0xFF0B5CAD),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      registro.codigoDrenagem,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      registro.identificacaoDrenagem,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (registro.estaca != null || registro.lado != null) ...[
                      const SizedBox(height: 7),
                      Text(
                        _textoEstacaLado(registro),
                        style: const TextStyle(
                          color: Color(0xFF0B5CAD),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                    if (possuiVolume) ...[
                      const SizedBox(height: 7),
                      Text(
                        'Concreto: ${registro.volumeConcretoM3!.toStringAsFixed(3)} m³',
                        style: const TextStyle(
                          color: Color(0xFF16803C),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: Color(0xFF64748B),
                ),
                onSelected: (acao) {
                  if (acao == 'detalhes') _abrirDetalhes(registro);
                  if (acao == 'excluir') _confirmarExclusao(registro);
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<String>(
                    value: 'detalhes',
                    child: Row(
                      children: [
                        Icon(Icons.visibility_outlined),
                        SizedBox(width: 10),
                        Text('Ver detalhes'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'excluir',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFFB42318),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Excluir',
                          style: TextStyle(color: Color(0xFFB42318)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _textoEstacaLado(ConferenciaRegistroModel registro) {
    final partes = <String>[];

    if (registro.estaca != null && registro.estaca!.trim().isNotEmpty) {
      partes.add('Estaca ${registro.estaca}');
    }

    if (registro.lado != null && registro.lado!.trim().isNotEmpty) {
      partes.add(registro.lado!);
    }

    return partes.isEmpty
        ? 'Localização registrada'
        : partes.join(' • ');
  }

  ConferenciaRegistroModel? _criarRegistro(
    Map<String, dynamic> resultado,
  ) {
    final drenagem = resultado['drenagem'];

    if (drenagem is! DrenagemModel) return null;

    final itens = _converterItens(resultado['itensConcluidos']);

    final estaca = resultado['estaca']?.toString() ??
        _obterPropriedade(resultado['pontoDrenagem'], 'estaca');

    final lado = resultado['lado']?.toString() ??
        _obterPropriedade(resultado['pontoDrenagem'], 'lado');

    final medidasConcreto =
        _converterMapaDouble(resultado['medidasConcreto']);

    return ConferenciaRegistroModel(
      id: _uuid.v4(),
      codigoDrenagem: drenagem.codigo,
      identificacaoDrenagem: drenagem.identificacao,
      rodovia: drenagem.rodovia,
      estaca: estaca,
      lado: lado,
      latitude: _converterDouble(resultado['latitude']),
      longitude: _converterDouble(resultado['longitude']),
      precisaoMetros: _converterDoubleNulo(resultado['precisaoMetros']),
      distanciaDispositivoMetros:
          _converterDoubleNulo(resultado['distanciaMetros']),
      itensConcluidos: itens,
      observacao: resultado['observacao']?.toString() ?? '',
      dataHora: resultado['dataHora'] is DateTime
          ? resultado['dataHora'] as DateTime
          : DateTime.now(),
      medidasExecutadas: medidasConcreto,
      volumeConcretoM3:
          _converterDoubleNulo(resultado['volumeConcretoM3']),
      tipoTss: resultado['tipoTss']?.toString(),
      calculadoPorMedicaoReal:
          resultado['calculadoPorMedicaoReal'] == true,
      resultadoTss: _converterMapaDinamico(resultado['resultadoTss']),
    );
  }

  List<String> _converterItens(dynamic valor) {
    if (valor is! List) return <String>[];

    return valor
        .where((item) => item != null)
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  String? _obterPropriedade(dynamic objeto, String propriedade) {
    if (objeto == null) return null;

    if (objeto is Map) {
      final valor = objeto[propriedade];
      if (valor == null) return null;

      final texto = valor.toString().trim();
      return texto.isEmpty ? null : texto;
    }

    if (objeto is PontoDrenagemObra) {
      switch (propriedade) {
        case 'estaca':
          return objeto.estaca;
        case 'lado':
          return objeto.lado;
      }
    }

    return null;
  }

  double _converterDouble(dynamic valor) {
    return _converterDoubleNulo(valor) ?? 0.0;
  }

  double? _converterDoubleNulo(dynamic valor) {
    if (valor == null) return null;

    if (valor is double) {
      return valor.isFinite ? valor : null;
    }

    if (valor is int) return valor.toDouble();

    final textoOriginal = valor.toString().trim();
    if (textoOriginal.isEmpty) return null;

    String textoNormalizado = textoOriginal
        .replaceAll('m³', '')
        .replaceAll('m2', '')
        .replaceAll('m²', '')
        .replaceAll('kg', '')
        .replaceAll('m', '')
        .replaceAll(' ', '')
        .trim();

    if (textoNormalizado.contains(',') &&
        textoNormalizado.contains('.')) {
      textoNormalizado = textoNormalizado
          .replaceAll('.', '')
          .replaceAll(',', '.');
    } else if (textoNormalizado.contains(',')) {
      textoNormalizado = textoNormalizado.replaceAll(',', '.');
    }

    final numero = double.tryParse(textoNormalizado);

    if (numero == null || !numero.isFinite) return null;

    return numero;
  }

  Map<String, double> _converterMapaDouble(dynamic valor) {
    if (valor is! Map) return <String, double>{};

    final resultado = <String, double>{};

    for (final entrada in valor.entries) {
      final numero = _converterDoubleNulo(entrada.value);

      if (numero != null) {
        resultado[entrada.key.toString()] = numero;
      }
    }

    return resultado;
  }

  Map<String, dynamic> _converterMapaDinamico(dynamic valor) {
    if (valor is! Map) return <String, dynamic>{};

    final resultado = <String, dynamic>{};

    for (final entrada in valor.entries) {
      resultado[entrada.key.toString()] = entrada.value;
    }

    return resultado;
  }
}

class _DetalheConferenciaSheet extends StatelessWidget {
  final ConferenciaRegistroModel registro;

  const _DetalheConferenciaSheet({
    required this.registro,
  });

  @override
  Widget build(BuildContext context) {
    final resultadoTss = registro.resultadoTss;
    final possuiTss = registro.tipoTss != null &&
        registro.tipoTss!.trim().isNotEmpty;

    return Container(
      height: MediaQuery.of(context).size.height * 0.84,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              width: 45,
              height: 5,
              margin: const EdgeInsets.only(top: 12, bottom: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),
                children: [
                  Text(
                    registro.codigoDrenagem,
                    style: const TextStyle(
                      color: Color(0xFF073B72),
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    registro.identificacaoDrenagem,
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _secao(
                    titulo: 'LOCALIZAÇÃO',
                    icone: Icons.location_on_rounded,
                    filho: Column(
                      children: [
                        _linha('Rodovia', registro.rodovia),
                        _linha('Estaca', registro.estaca ?? 'Não informada'),
                        _linha('Lado', registro.lado ?? 'Não informado'),
                        _linha(
                          'Latitude',
                          registro.latitude.toStringAsFixed(6),
                        ),
                        _linha(
                          'Longitude',
                          registro.longitude.toStringAsFixed(6),
                        ),
                        if (registro.precisaoMetros != null)
                          _linha(
                            'Precisão GPS',
                            '± ${registro.precisaoMetros!.toStringAsFixed(1)} m',
                          ),
                        if (registro.distanciaDispositivoMetros != null)
                          _linha(
                            'Distância do dispositivo',
                            '${registro.distanciaDispositivoMetros!.toStringAsFixed(1)} m',
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (possuiTss)
                    _secao(
                      titulo: 'TRANSPOSIÇÃO DE SARJETA',
                      icone: Icons.architecture_rounded,
                      filho: Column(
                        children: [
                          _linha('Tipo TSS', registro.tipoTss!),
                          _linha(
                            'Método de cálculo',
                            registro.calculadoPorMedicaoReal
                                ? 'Medição real de campo'
                                : 'Consumo de projeto',
                          ),
                          if (resultadoTss['volumeBaseFck20'] != null)
                            _linha(
                              'Base fck ≥ 20 MPa',
                              '${_numero(resultadoTss['volumeBaseFck20'])} m³',
                            ),
                          if (resultadoTss['volumeLajeFck25'] != null)
                            _linha(
                              'Laje fck ≥ 25 MPa',
                              '${_numero(resultadoTss['volumeLajeFck25'])} m³',
                            ),
                          if (resultadoTss['volumeTotalConcreto'] != null)
                            _linha(
                              'Total TSS',
                              '${_numero(resultadoTss['volumeTotalConcreto'])} m³',
                              destaque: true,
                            ),
                        ],
                      ),
                    ),
                  if (possuiTss) const SizedBox(height: 14),
                  if (registro.volumeConcretoM3 != null)
                    _secao(
                      titulo: 'CONCRETO',
                      icone: Icons.format_color_fill_rounded,
                      filho: _linha(
                        'Volume total registrado',
                        '${registro.volumeConcretoM3!.toStringAsFixed(3)} m³',
                        destaque: true,
                      ),
                    ),
                  if (registro.volumeConcretoM3 != null)
                    const SizedBox(height: 14),
                  _secao(
                    titulo: 'ITENS CONCLUÍDOS',
                    icone: Icons.checklist_rounded,
                    filho: registro.itensConcluidos.isEmpty
                        ? const Text(
                            'Nenhum item registrado.',
                            style: TextStyle(color: Color(0xFF64748B)),
                          )
                        : Column(
                            children: registro.itensConcluidos.map((item) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 9),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: Color(0xFF16803C),
                                      size: 19,
                                    ),
                                    const SizedBox(width: 9),
                                    Expanded(
                                      child: Text(
                                        item,
                                        style: const TextStyle(
                                          color: Color(0xFF334155),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                  const SizedBox(height: 14),
                  _secao(
                    titulo: 'OBSERVAÇÕES',
                    icone: Icons.notes_rounded,
                    filho: Text(
                      registro.observacao.trim().isEmpty
                          ? 'Nenhuma observação registrada.'
                          : registro.observacao,
                      style: const TextStyle(
                        color: Color(0xFF334155),
                        fontSize: 13,
                        height: 1.4,
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

  Widget _secao({
    required String titulo,
    required IconData icone,
    required Widget filho,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, color: const Color(0xFF0B5CAD), size: 20),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: const TextStyle(
                  color: Color(0xFF0B5CAD),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          filho,
        ],
      ),
    );
  }

  Widget _linha(
    String titulo,
    String valor, {
    bool destaque = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              valor,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: destaque
                    ? const Color(0xFF16803C)
                    : const Color(0xFF1E293B),
                fontSize: 13,
                fontWeight:
                    destaque ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _numero(dynamic valor) {
    if (valor is num) {
      return valor.toDouble().toStringAsFixed(3);
    }

    final texto = valor.toString().replaceAll(',', '.');
    final numero = double.tryParse(texto);

    if (numero == null) return valor.toString();

    return numero.toStringAsFixed(3);
  }
}
