import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../models/conferencia_registro_model.dart';
import '../models/drenagem_model.dart';
import '../services/conferencia_repository.dart';
import 'localizacao_automatica_screen.dart';

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
    }
  }

  Future<void> _iniciarConferencia() async {
    if (_iniciando) return;

    setState(() {
      _iniciando = true;
    });

    try {
      final resultado = await Navigator.of(context).push<Map<String, dynamic>>(
        MaterialPageRoute(
          builder: (_) => const LocalizacaoAutomaticaScreen(),
        ),
      );

      if (!mounted || resultado == null) return;

      final conferencia = _criarRegistro(resultado);

      if (conferencia == null) {
        _mostrarMensagem(
          'Não foi possível preparar os dados da conferência.',
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
    } catch (_) {
      if (!mounted) return;

      _mostrarMensagem(
        'Não foi possível salvar a conferência.',
        erro: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _iniciando = false;
        });
      }
    }
  }

  ConferenciaRegistroModel? _criarRegistro(
    Map<String, dynamic> resultado,
  ) {
    final drenagem = resultado['drenagem'];

    if (drenagem is! DrenagemModel) {
      return null;
    }

    final ponto = resultado['pontoDrenagem'];
    final itens = resultado['itensConcluidos'];

    String? estaca;
    String? lado;

    try {
      estaca = ponto?.estaca?.toString();
      lado = ponto?.lado?.toString();
    } catch (_) {}

    return ConferenciaRegistroModel(
      id: _uuid.v4(),
      codigoDrenagem: drenagem.codigo,
      identificacaoDrenagem: drenagem.identificacao,
      estaca: estaca,
      lado: lado,
      latitude: _converterDouble(resultado['latitude']),
      longitude: _converterDouble(resultado['longitude']),
      precisaoMetros: _converterDoubleNulo(resultado['precisaoMetros']),
      distanciaDispositivoMetros:
          _converterDoubleNulo(resultado['distanciaMetros']),
      itensConcluidos: _converterItens(itens),
      observacao: resultado['observacao']?.toString() ?? '',
      dataHora: resultado['dataHora'] is DateTime
          ? resultado['dataHora'] as DateTime