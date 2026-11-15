
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/drenagem_model.dart';
import '../services/eixo_estaca_service.dart';
import 'roteiro_drenagem_screen.dart';

class LocalizacaoAutomaticaScreen extends StatefulWidget {
  const LocalizacaoAutomaticaScreen({super.key});

  @override
  State<LocalizacaoAutomaticaScreen> createState() =>
      _LocalizacaoAutomaticaScreenState();
}

class _LocalizacaoAutomaticaScreenState
    extends State<LocalizacaoAutomaticaScreen> {
  final EixoEstacaService _eixoEstacaService = EixoEstacaService();

  String _rodoviaSelecionada = 'GO-110';

  bool _carregando = false;
  bool _abrindoRoteiro = false;

  String? _erro;
  Position? _posicao;
  ResultadoEstaca? _resultado;

  DrenagemModel? _drenagemSelecionada;

  @override
  void initState() {
    super.initState();
    _atualizarLocalizacao();
  }

  Future<void> _atualizarLocalizacao() async {
    setState(() {
      _carregando = true;
      _erro = null;
      _resultado = null;
    });

    try {
      final servicoAtivo =
          await Geolocator.isLocationServiceEnabled();

      if (!servicoAtivo) {
        throw Exception(
          'O GPS do celular está desligado. Ative a localização.',
        );
      }

      LocationPermission permissao =
          await Geolocator.checkPermission();

      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
      }

      if (permissao == LocationPermission.denied) {
        throw Exception(
          'Permissão de localização não autorizada.',
        );
      }

      if (permissao == LocationPermission.deniedForever) {
        throw Exception(
          'A permissão foi bloqueada. Autorize a localização '
          'nas configurações do aplicativo.',
        );
      }

      final posicao = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );

      ResultadoEstaca resultado;

      if (_rodoviaSelecionada == 'GO-236') {
        resultado = await _eixoEstacaService.calcularGo236(
          latitude: posicao.latitude,
          longitude: posicao.longitude,
        );
      } else {
        resultado = await _eixoEstacaService.calcularGo110(
          latitude: posicao.latitude,
          longitude: posicao.longitude,
        );
      }

      if (!mounted) return;

      setState(() {
        _posicao = posicao;
        _resultado = resultado;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _carregando = false;
        _erro = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _continuar() async {
    final resultado = _resultado;
    final drenagem = _drenagemSelecionada;

    if (resultado == null || drenagem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selecione um dispositivo de drenagem.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _abrindoRoteiro = true;
    });

    try {
      final dados = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (_) => RoteiroDrenagemScreen(
            drenagem: drenagem,
            resultadoEstaca: resultado,
            precisaoMetros: _posicao?.accuracy,
            distanciaMetros: null,
            pontoDrenagem: null,
          ),
        ),
      );

      if (!mounted) return;

      if (dados != null) {
        Navigator.pop(context, dados);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao abrir roteiro: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _abrindoRoteiro = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Localização Automática'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _atualizarLocalizacao,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _cabecalho(tema),
              const SizedBox(height: 20),
              _seletorRodovia(),
              const SizedBox(height: 16),

              if (_carregando) _cardCarregando(),
              if (_erro != null) _cardErro(),
              if (_resultado != null) ...[
                _cardResultado(),
                const SizedBox(height: 16),
                _seletorDispositivo(),
              ],

              if (!_carregando &&
                  _erro == null &&
                  _resultado == null)
                _cardAguardando(),

              const SizedBox(height: 24),

              OutlinedButton.icon(
                onPressed:
                    _carregando ? null : _atualizarLocalizacao,
                icon: const Icon(Icons.my_location),
                label: const Text('ATUALIZAR GPS E ESTACA'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                ),
              ),

              const SizedBox(height: 12),

              FilledButton.icon(
                onPressed: _resultado == null ||
                        _drenagemSelecionada == null ||
                        _abrindoRoteiro
                    ? null
                    : _continuar,
                icon: _abrindoRoteiro
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.arrow_forward),
                label: Text(
                  _abrindoRoteiro
                      ? 'ABRINDO ROTEIRO...'
                      : 'CONTINUAR CONFERÊNCIA',
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cabecalho(ThemeData tema) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: tema.colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.route,
            size: 42,
            color: Colors.white,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'POSICIONAMENTO NO EIXO',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Estaca automática por GPS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _seletorRodovia() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DropdownButtonFormField<String>(
          value: _rodoviaSelecionada,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Rodovia / eixo da obra',
            prefixIcon: Icon(Icons.alt_route),
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: 'GO-110',
              child: Text('GO-110 — Estiva / São Domingos'),
            ),
            DropdownMenuItem(
              value: 'GO-236',
              child: Text('GO-236 — Flores de Goiás / BR-020'),
            ),
          ],
          onChanged: _carregando
              ? null
              : (valor) {
                  if (valor == null) return;

                  setState(() {
                    _rodoviaSelecionada = valor;
                    _resultado = null;
                    _erro = null;
                    _drenagemSelecionada = null;
                  });

                  _atualizarLocalizacao();
                },
        ),
      ),
    );
  }

  Widget _seletorDispositivo() {
    if (_rodoviaSelecionada != 'GO-236') {
      return Card(
        color: Colors.orange.shade50,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'O catálogo de dispositivos disponível atualmente '
            'é da GO-236. Para a GO-110, precisamos cadastrar '
            'os dispositivos específicos dessa rodovia.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    final dispositivos =
        CatalogoDrenagemSuperficial.dispositivos;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.water_damage_outlined),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'SELECIONAR DISPOSITIVO',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Escolha o tipo e modelo encontrado em campo.',
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<DrenagemModel>(
              value: _drenagemSelecionada,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Dispositivo de drenagem',
                prefixIcon: Icon(Icons.construction),
                border: OutlineInputBorder(),
              ),
              items: dispositivos.map((dispositivo) {
                return DropdownMenuItem<DrenagemModel>(
                  value: dispositivo,
                  child: Text(
                    dispositivo.codigo,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (valor) {
                setState(() {
                  _drenagemSelecionada = valor;
                });
              },
            ),
            if (_drenagemSelecionada != null) ...[
              const SizedBox(height: 14),
              Text(
                _drenagemSelecionada!.identificacao,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(_drenagemSelecionada!.dimensoesResumidas),
              if (_drenagemSelecionada!.norma != null)
                Text(
                  'Norma: ${_drenagemSelecionada!.norma}',
                ),
              if (_drenagemSelecionada!.observacao != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _drenagemSelecionada!.observacao!,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _cardCarregando() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 18),
            Text(
              'Obtendo GPS e calculando a estaca no eixo...',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6),
            Text(
              'Aguarde alguns segundos.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardAguardando() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.gps_fixed,
              size: 48,
              color: Colors.blue,
            ),
            SizedBox(height: 12),
            Text(
              'Aguardando localização do GPS.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardErro() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 44,
              color: Colors.red.shade700,
            ),
            const SizedBox(height: 10),
            Text(
              'Não foi possível calcular a estaca',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red.shade900,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _erro ?? 'Erro desconhecido.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade900),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardResultado() {
    final resultado = _resultado!;
    final posicao = _posicao;
    final offsetAlto = resultado.offsetMetros > 50;

    return Column(
      children: [
        Card(
          elevation: 2,
          color: Colors.green.shade50,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade700,
                  size: 44,
                ),
                const SizedBox(height: 8),
                Text(
                  'EIXO IDENTIFICADO',
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  resultado.rodovia,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  resultado.nomeEixo,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _linhaInformacao(
          icone: Icons.signpost,
          titulo: 'ESTACA AUTOMÁTICA',
          valor: resultado.estacaFormatada,
          destaque: true,
        ),
        _linhaInformacao(
          icone: Icons.swap_horiz,
          titulo: 'OFFSET AO EIXO',
          valor: '${resultado.offsetMetros.toStringAsFixed(2)} m',
          corValor: offsetAlto
              ? Colors.orange.shade800
              : Colors.green.shade700,
        ),
        _linhaInformacao(
          icone: resultado.lado == 'Direito'
              ? Icons.turn_right
              : Icons.turn_left,
          titulo: 'LADO DA RODOVIA',
          valor: resultado.lado,
        ),
        _linhaInformacao(
          icone: Icons.location_on_outlined,
          titulo: 'COORDENADAS GPS',
          valor:
              '${resultado.latitude.toStringAsFixed(6)}, '
              '${resultado.longitude.toStringAsFixed(6)}',
        ),
        _linhaInformacao(
          icone: Icons.grid_on,
          titulo: 'UTM 23S — SIRGAS 2000',
          valor:
              'E ${resultado.utmEste.toStringAsFixed(3)}  |  '
              'N ${resultado.utmNorte.toStringAsFixed(3)}',
        ),
        if (posicao != null)
          _linhaInformacao(
            icone: Icons.gps_fixed,
            titulo: 'PRECISÃO DO GPS',
            valor: '± ${posicao.accuracy.toStringAsFixed(1)} m',
          ),
        if (offsetAlto)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.orange.shade300,
              ),
            ),
            child: Text(
              'Atenção: o ponto está distante mais de 50 m '
              'do eixo. Confira se a rodovia selecionada está correta.',
              style: TextStyle(
                color: Colors.orange.shade900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _linhaInformacao({
    required IconData icone,
    required String titulo,
    required String valor,
    bool destaque = false,
    Color? corValor,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(
          icone,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          titulo,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            valor,
            style: TextStyle(
              fontSize: destaque ? 22 : 15,
              fontWeight:
                  destaque ? FontWeight.bold : FontWeight.w600,
              color: corValor,
            ),
          ),
        ),
      ),
    );
  }
}
