import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'drenagem_selecao_screen.dart';

class LocalizacaoAutomaticaScreen extends StatefulWidget {
  const LocalizacaoAutomaticaScreen({super.key});

  @override
  State<LocalizacaoAutomaticaScreen> createState() =>
      _LocalizacaoAutomaticaScreenState();
}

class _LocalizacaoAutomaticaScreenState
    extends State<LocalizacaoAutomaticaScreen> {
  Position? _posicao;
  String? _erro;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _obterLocalizacao();
  }

  Future<void> _obterLocalizacao() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final servicoAtivado = await Geolocator.isLocationServiceEnabled();

      if (!servicoAtivado) {
        throw Exception(
          'O GPS do celular está desligado. Ative a localização para continuar.',
        );
      }

      LocationPermission permissao = await Geolocator.checkPermission();

      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
      }

      if (permissao == LocationPermission.denied) {
        throw Exception(
          'A permissão de localização foi negada. Autorize o GPS nas configurações do celular.',
        );
      }

      if (permissao == LocationPermission.deniedForever) {
        throw Exception(
          'A permissão de localização foi bloqueada permanentemente. '
          'Abra as configurações do aplicativo e permita o acesso à localização.',
        );
      }

      final posicao = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 25),
      );

      if (!mounted) return;

      setState(() {
        _posicao = posicao;
        _carregando = false;
      });
    } catch (erro) {
      if (!mounted) return;

      setState(() {
        _erro = erro.toString().replaceFirst('Exception: ', '');
        _carregando = false;
      });
    }
  }

  Future<void> _continuar() async {
    final posicao = _posicao;

    if (posicao == null) return;

    final drenagemSelecionada = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DrenagemSelecaoScreen(
          latitude: posicao.latitude,
          longitude: posicao.longitude,
          precisaoMetros: posicao.accuracy,
        ),
      ),
    );

    if (!mounted || drenagemSelecionada == null) return;

    Navigator.of(context).pop(drenagemSelecionada);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Localização automática'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _carregando
              ? _telaCarregando()
              : _erro != null
                  ? _telaErro()
                  : _telaLocalizacao(),
        ),
      ),
    );
  }

  Widget _telaCarregando() {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
          ),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                strokeWidth: 5,
                color: Color(0xFF0B5CAD),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Obtendo localização GPS',
              style: TextStyle(
                color: Color(0xFF172033),
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Aguarde enquanto o aplicativo identifica sua posição na rodovia.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _telaErro() {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7E6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFF5C26B),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_off_rounded,
              color: Color(0xFFB45309),
              size: 54,
            ),
            const SizedBox(height: 16),
            const Text(
              'Não foi possível obter o GPS',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF92400E),
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _erro ?? 'Erro desconhecido ao acessar a localização.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF78350F),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _obterLocalizacao,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('TENTAR NOVAMENTE'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB45309),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _telaLocalizacao() {
    final posicao = _posicao!;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF073B72),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFF16803C),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.gps_fixed_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'GPS LOCALIZADO',
                style: TextStyle(
                  color: Color(0xFF9EEBB5),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Posição pronta para identificar a drenagem',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _cardInformacao(
          icone: Icons.my_location_rounded,
          titulo: 'COORDENADAS ATUAIS',
          valor:
              '${posicao.latitude.toStringAsFixed(6)}, ${posicao.longitude.toStringAsFixed(6)}',
        ),
        const SizedBox(height: 10),
        _cardInformacao(
          icone: Icons.gps_fixed_rounded,
          titulo: 'PRECISÃO DO GPS',
          valor: '± ${posicao.accuracy.toStringAsFixed(1)} m',
        ),
        const SizedBox(height: 10),
        _cardInformacao(
          icone: Icons.speed_rounded,
          titulo: 'ALTITUDE',
          valor: '${posicao.altitude.toStringAsFixed(1)} m',
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: _continuar,
            icon: const Icon(Icons.water_drop_rounded),
            label: const Text('IDENTIFICAR DRENAGEM'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B5CAD),
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: _obterLocalizacao,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('ATUALIZAR LOCALIZAÇÃO'),
        ),
      ],
    );
  }

  Widget _cardInformacao({
    required IconData icone,
    required String titulo,
    required String valor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icone,
              color: const Color(0xFF0B5CAD),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  style: const TextStyle(
                    color: Color(0xFF172033),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}