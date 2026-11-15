
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../models/conferencia_registro_model.dart';
import '../models/drenagem_model.dart';
import '../services/conferencia_repository.dart';
import 'localizacao_automatica_screen.dart';
import 'relatorio_concreto_screen.dart';

class ConferenciaScreen extends StatefulWidget {
  const ConferenciaScreen({super.key});

  @override
  State<ConferenciaScreen> createState() => _ConferenciaScreenState();
}

class _ConferenciaScreenState extends State<ConferenciaScreen> {
  final ConferenciaRepository _repository = ConferenciaRepository();
  final Uuid _uuid = const Uuid();

  List<ConferenciaRegistroModel> _conferencias = [];

  bool _carregandoHistorico = true;
  bool _iniciando = false;

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  Future<void> _carregarHistorico() async {
    try {
      final conferencias = await _repository.carregar();

      if (!mounted) return;

      setState(() {
        _conferencias = conferencias;
        _carregandoHistorico = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _carregandoHistorico = false;
      });

      _mostrarMensagem('Erro ao carregar histórico.', erro: true);
    }
  }

  Future<void> _abrirRelatorio() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const RelatorioConcretoScreen(),
      ),
    );
  }

  Future<void> _iniciarConferencia() async {
    if (_iniciando) return;

    setState(() => _iniciando = true);

    try {
      final resultado =
          await Navigator.of(context).push<Map<String, dynamic>>(
        MaterialPageRoute(
          builder: (_) => const LocalizacaoAutomaticaScreen(),
        ),
      );

      if (!mounted || resultado == null) return;

      final conferencia = _criarRegistro(resultado);

      if (conferencia == null) {
        _mostrarMensagem(
          'Dados incompletos. Confira a drenagem e tente novamente.',
          erro: true,
        );
        return;
      }

      await _repository.adicionar(conferencia);

      if (!mounted) return;

      setState(() {
        _conferencias.insert(0, conferencia);
      });

      _mostrarMensagem('Conferência salva no celular com sucesso.');
    } catch (e) {
      if (!mounted) return;

      _mostrarMensagem(
        'Erro ao salvar conferência: $e',
        erro: true,
      );
    } finally {
      if (mounted) {
        setState(() => _iniciando = false);
      }
    }
  }

  ConferenciaRegistroModel? _criarRegistro(
    Map<String, dynamic> resultado,
  ) {
    final drenagem = resultado['drenagem'];

    if (drenagem is! DrenagemModel) return null;

    final itens = _converterItens(resultado['itensConcluidos']);

    final estaca =
        resultado['estaca']?.toString() ??
        _obterPropriedade(resultado['pontoDrenagem'], 'estaca');

    final lado =
        resultado['lado']?.toString() ??
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
      precisaoMetros:
          _converterDoubleNulo(resultado['precisaoMetros']),
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
    );
  }

  String? _obterPropriedade(dynamic objeto, String propriedade) {
    if (objeto == null) return null;

    try {
      if (propriedade == 'estaca') {
        return objeto.estaca?.toString();
      }

      if (propriedade == 'lado') {
        return objeto.lado?.toString();
      }
    } catch (_) {}

    return null;
  }

  double _converterDouble(dynamic valor) {
    if (valor is double) return valor;
    if (valor is int) return valor.toDouble();

    return double.tryParse(
          valor?.toString().replaceAll(',', '.') ?? '',
        ) ??
        0;
  }

  double? _converterDoubleNulo(dynamic valor) {
    if (valor == null) return null;
    if (valor is double) return valor;
    if (valor is int) return valor.toDouble();

    return double.tryParse(
      valor.toString().replaceAll(',', '.'),
    );
  }

  Map<String, double> _converterMapaDouble(dynamic valor) {
    if (valor is! Map) return {};

    final resultado = <String, double>{};

    valor.forEach((chave, medida) {
      final numero = _converterDoubleNulo(medida);

      if (numero != null) {
        resultado[chave.toString()] = numero;
      }
    });

    return resultado;
  }

  List<bool> _converterItens(dynamic itens) {
    if (itens is List<bool>) return itens;

    if (itens is List<String>) {
      return itens.map((_) => true).toList();
    }

    if (itens is List) {
      return itens.map((item) => item == true).toList();
    }

    return [];
  }

  void _mostrarMensagem(
    String mensagem, {
    bool erro = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor:
            erro ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  Future<void> _excluirConferencia(
    ConferenciaRegistroModel conferencia,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir conferência'),
        content: Text(
          'Deseja excluir a conferência '
          '${conferencia.codigoDrenagem}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade700,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('EXCLUIR'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await _repository.excluir(conferencia.id);

      if (!mounted) return;

      setState(() {
        _conferencias.removeWhere(
          (item) => item.id == conferencia.id,
        );
      });

      _mostrarMensagem('Conferência excluída.');
    } catch (_) {
      if (!mounted) return;

      _mostrarMensagem(
        'Não foi possível excluir a conferência.',
        erro: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Strata Conferência'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Atualizar histórico',
            onPressed: _carregarHistorico,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _carregarHistorico,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _cabecalho(theme),
              const SizedBox(height: 16),
              _cardStatusGps(),
              const SizedBox(height: 16),
              _botaoIniciar(),
              const SizedBox(height: 12),
              _botaoRelatorio(),
              const SizedBox(height: 26),
              _tituloHistorico(),
              const SizedBox(height: 10),
              _conteudoHistorico(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cabecalho(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.engineering, color: Colors.white, size: 40),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'CONFERÊNCIA DE DRENAGEM',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 18),
          Text(
            'GOINFRA • STRATA ENGENHARIA',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Fiscalização e conferência técnica de dispositivos de drenagem.',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _cardStatusGps() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.gps_fixed,
                color: Colors.blue.shade800,
                size: 27,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LOCALIZAÇÃO AUTOMÁTICA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'GPS, estaca, offset e lado da rodovia.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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

  Widget _botaoIniciar() {
    return FilledButton(
      onPressed: _iniciando ? null : _iniciarConferencia,
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 64),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: _iniciando
          ? const SizedBox(
              height: 25,
              width: 25,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_location_alt, size: 27),
                SizedBox(width: 12),
                Text(
                  'INICIAR CONFERÊNCIA AUTOMÁTICA',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _botaoRelatorio() {
    return OutlinedButton.icon(
      onPressed: _abrirRelatorio,
      icon: const Icon(Icons.assessment_outlined),
      label: const Text(
        'RELATÓRIO MENSAL DE CONCRETO',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _tituloHistorico() {
    return Row(
      children: [
        const Icon(Icons.history),
        const SizedBox(width: 8),
        const Text(
          'HISTÓRICO DE CONFERÊNCIAS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            letterSpacing: 0.3,
          ),
        ),
        const Spacer(),
        Text(
          '${_conferencias.length}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _conteudoHistorico() {
    if (_carregandoHistorico) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_conferencias.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 48,
                color: Colors.grey.shade500,
              ),
              const SizedBox(height: 12),
              const Text(
                'Nenhuma conferência registrada.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                'Inicie uma conferência para salvar os dados de drenagem.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _conferencias.map(_cardConferencia).toList(),
    );
  }

  Widget _cardConferencia(ConferenciaRegistroModel conferencia) {
    final dataFormatada = DateFormat(
      'dd/MM/yyyy HH:mm',
      'pt_BR',
    ).format(conferencia.dataHora);

    final estaca = conferencia.estaca?.isNotEmpty == true
        ? conferencia.estaca!
        : 'Estaca não informada';

    final lado = conferencia.lado?.isNotEmpty == true
        ? conferencia.lado!
        : 'Lado não informado';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _mostrarDetalhes(conferencia),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.green.shade100,
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green.shade800,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conferencia.codigoDrenagem,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      conferencia.identificacaoDrenagem,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${conferencia.rodovia.isNotEmpty ? conferencia.rodovia : 'Rodovia não informada'} • $estaca • $lado',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (conferencia.volumeConcretoM3 != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Concreto: '
                        '${conferencia.volumeConcretoM3!.toStringAsFixed(3)} m³',
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    const SizedBox(height: 3),
                    Text(
                      dataFormatada,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Excluir',
                onPressed: () => _excluirConferencia(conferencia),
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDetalhes(ConferenciaRegistroModel conferencia) {
    final dataFormatada = DateFormat(
      'dd/MM/yyyy HH:mm:ss',
      'pt_BR',
    ).format(conferencia.dataHora);

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'DETALHES DA CONFERÊNCIA',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 20),
                _linhaDetalhe('Código', conferencia.codigoDrenagem),
                _linhaDetalhe(
                  'Dispositivo',
                  conferencia.identificacaoDrenagem,
                ),
                _linhaDetalhe(
                  'Rodovia',
                  conferencia.rodovia.isNotEmpty
                      ? conferencia.rodovia
                      : 'Não informada',
                ),
                _linhaDetalhe(
                  'Estaca',
                  conferencia.estaca ?? 'Não informada',
                ),
                _linhaDetalhe(
                  'Lado',
                  conferencia.lado ?? 'Não informado',
                ),
                _linhaDetalhe(
                  'Latitude',
                  conferencia.latitude.toStringAsFixed(6),
                ),
                _linhaDetalhe(
                  'Longitude',
                  conferencia.longitude.toStringAsFixed(6),
                ),
                _linhaDetalhe(
                  'Precisão GPS',
                  conferencia.precisaoMetros != null
                      ? '± ${conferencia.precisaoMetros!.toStringAsFixed(1)} m'
                      : 'Não informada',
                ),
                _linhaDetalhe(
                  'Distância ao dispositivo',
                  conferencia.distanciaDispositivoMetros != null
                      ? '${conferencia.distanciaDispositivoMetros!.toStringAsFixed(2)} m'
                      : 'Não informada',
                ),
                _linhaDetalhe('Data e hora', dataFormatada),
                _linhaDetalhe(
                  'Itens concluídos',
                  '${conferencia.quantidadeItensConcluidos} de '
                  '${conferencia.quantidadeItens}',
                ),
                if (conferencia.volumeConcretoM3 != null) ...[
                  const Divider(height: 24),
                  _linhaDetalhe(
                    'Volume de concreto',
                    '${conferencia.volumeConcretoM3!.toStringAsFixed(3)} m³',
                  ),
                ],
                if (conferencia.medidasExecutadas.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'MEDIDAS EXECUTADAS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...conferencia.medidasExecutadas.entries.map(
                    (item) => _linhaDetalhe(
                      item.key.toUpperCase(),
                      '${item.value.toStringAsFixed(3)} m',
                    ),
                  ),
                ],
                if (conferencia.observacao.trim().isNotEmpty)
                  _linhaDetalhe(
                    'Observação',
                    conferencia.observacao,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _linhaDetalhe(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              '$titulo:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }
}
