import 'package:flutter/material.dart';

import '../models/drenagem_model.dart';
import '../services/identificacao_drenagem_service.dart';

class DrenagemSelecaoScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final double? precisaoMetros;

  const DrenagemSelecaoScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    this.precisaoMetros,
  });

  @override
  State<DrenagemSelecaoScreen> createState() => _DrenagemSelecaoScreenState();
}

class _DrenagemSelecaoScreenState extends State<DrenagemSelecaoScreen> {
  final IdentificacaoDrenagemService _service =
      const IdentificacaoDrenagemService();

  final TextEditingController _pesquisaController = TextEditingController();

  ResultadoIdentificacaoDrenagem? _resultadoAutomatico;
  List<DrenagemModel> _dispositivosFiltrados =
      CatalogoDrenagemSuperficial.dispositivos;

  @override
  void initState() {
    super.initState();
    _identificarAutomaticamente();
    _pesquisaController.addListener(_filtrarDispositivos);
  }

  @override
  void dispose() {
    _pesquisaController
      ..removeListener(_filtrarDispositivos)
      ..dispose();
    super.dispose();
  }

  void _identificarAutomaticamente() {
    final resultado = _service.localizarDrenagemMaisProxima(
      latitudeAtual: widget.latitude,
      longitudeAtual: widget.longitude,
    );

    setState(() {
      _resultadoAutomatico = resultado;
    });
  }

  void _filtrarDispositivos() {
    final texto = _pesquisaController.text.trim().toLowerCase();

    setState(() {
      if (texto.isEmpty) {
        _dispositivosFiltrados = CatalogoDrenagemSuperficial.dispositivos;
        return;
      }

      _dispositivosFiltrados = CatalogoDrenagemSuperficial.dispositivos
          .where((dispositivo) {
        return dispositivo.codigo.toLowerCase().contains(texto) ||
            dispositivo.identificacao.toLowerCase().contains(texto) ||
            dispositivo.nomeTipo.toLowerCase().contains(texto);
      }).toList();
    });
  }

  void _selecionarDrenagem(DrenagemModel drenagem) {
    Navigator.of(context).pop(drenagem);
  }

  @override
  Widget build(BuildContext context) {
    final resultado = _resultadoAutomatico;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Identificar drenagem'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _cardGps(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                children: [
                  if (resultado != null && resultado.localizada)
                    _cardDrenagemAutomatica(resultado)
                  else
                    _cardSemDrenagemAutomatica(resultado),
                  const SizedBox(height: 22),
                  const Text(
                    'Selecionar dispositivo da obra',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF172033),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Use a seleção manual enquanto a locação individual das drenagens não estiver cadastrada.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _pesquisaController,
                    decoration: InputDecoration(
                      hintText: 'Pesquisar: STC, DAR, VPAC, DED...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _pesquisaController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: _pesquisaController.clear,
                              icon: const Icon(Icons.close_rounded),
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
                  ),
                  const SizedBox(height: 16),
                  if (_dispositivosFiltrados.isEmpty)
                    _semResultados()
                  else
                    ..._dispositivosFiltrados.map(_cardDispositivo),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardGps() {
    final precisao = widget.precisaoMetros;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF073B72),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.gps_fixed_rounded,
                color: Colors.white,
                size: 21,
              ),
              SizedBox(width: 8),
              Text(
                'POSIÇÃO GPS ATUAL',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '${widget.latitude.toStringAsFixed(6)}, '
            '${widget.longitude.toStringAsFixed(6)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (precisao != null) ...[
            const SizedBox(height: 5),
            Text(
              'Precisão do GPS: ± ${precisao.toStringAsFixed(1)} m',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _cardDrenagemAutomatica(
    ResultadoIdentificacaoDrenagem resultado,
  ) {
    final drenagem = resultado.drenagem!;
    final ponto = resultado.ponto!;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8F0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF86D5A5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF16803C),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'DRENAGEM LOCALIZADA AUTOMATICAMENTE',
                  style: TextStyle(
                    color: Color(0xFF16803C),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.45,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            drenagem.codigo,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: Color(0xFF172033),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            drenagem.identificacao,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 13),
          _linhaInformacao(
            Icons.signpost_outlined,
            'Estaca ${ponto.estaca} • ${ponto.lado}',
          ),
          const SizedBox(height: 7),
          _linhaInformacao(
            Icons.straighten_rounded,
            drenagem.dimensoesResumidas,
          ),
          const SizedBox(height: 7),
          _linhaInformacao(
            Icons.near_me_outlined,
            'Distância: ${resultado.distanciaMetros!.toStringAsFixed(1)} m',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _selecionarDrenagem(drenagem),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('CONFIRMAR E INICIAR ROTEIRO'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16803C),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardSemDrenagemAutomatica(
    ResultadoIdentificacaoDrenagem? resultado,
  ) {
    String titulo = 'Aguardando base de locação';
    String mensagem =
        'Cadastre os pontos de drenagem com coordenadas ou estaca para o app identificar automaticamente o dispositivo próximo ao GPS.';
    IconData icone = Icons.location_searching_rounded;
    Color cor = const Color(0xFFB45309);
    Color fundo = const Color(0xFFFFF7E6);

    if (resultado?.status == StatusIdentificacaoDrenagem.foraDoRaio) {
      titulo = 'Nenhuma drenagem próxima ao GPS';
      mensagem = resultado!.mensagem;
      icone = Icons.location_off_outlined;
      cor = const Color(0xFFB45309);
      fundo = const Color(0xFFFFF7E6);
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cor.withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: cor, size: 28),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    color: cor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  mensagem,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardDispositivo(DrenagemModel drenagem) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: () => _selecionarDrenagem(drenagem),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F1FB),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  _iconeDispositivo(drenagem.tipo),
                  color: const Color(0xFF0B5CAD),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      drenagem.codigo,
                      style: const TextStyle(
                        color: Color(0xFF172033),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      drenagem.identificacao,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      drenagem.dimensoesResumidas,
                      style: const TextStyle(
                        color: Color(0xFF0B5CAD),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF64748B),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _linhaInformacao(IconData icone, String texto) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icone, size: 17, color: const Color(0xFF16803C)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 13,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _semResultados() {
    return Container(
      padding: const EdgeInsets.all(28),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 42,
            color: Color(0xFF64748B),
          ),
          SizedBox(height: 10),
          Text(
            'Nenhum dispositivo encontrado.',
            style: TextStyle(
              color: Color(0xFF334155),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconeDis