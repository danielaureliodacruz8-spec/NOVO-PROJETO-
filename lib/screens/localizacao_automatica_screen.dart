import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/localizacao_service.dart';
import '../theme/app_theme.dart';

class LocalizacaoAutomaticaScreen extends StatefulWidget {
  const LocalizacaoAutomaticaScreen({super.key});

  @override
  State<LocalizacaoAutomaticaScreen> createState() =>
      _LocalizacaoAutomaticaScreenState();
}

class _LocalizacaoAutomaticaScreenState
    extends State<LocalizacaoAutomaticaScreen> {
  final LocalizacaoService _localizacaoService = LocalizacaoService();

  DadosLocalizacao? _localizacao;
  bool _carregando = false;
  String? _erro;

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
      final localizacao =
          await _localizacaoService.obterLocalizacaoAtual();

      if (!mounted) return;

      setState(() {
        _localizacao = localizacao;
      });
    } catch (erro) {
      if (!mounted) return;

      setState(() {
        _erro = erro.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  void _continuar() {
    if (_localizacao == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'A identificação de eixo, estaca e drenagem será adicionada na próxima etapa.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Localização automática'),
      ),
      body: RefreshIndicator(
        onRefresh: _obterLocalizacao,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _cabecalho(),
            const SizedBox(height: 20),
            if (_carregando) _cardCarregando(),
            if (_erro != null) _cardErro(),
            if (!_carregando && _erro == null && _localizacao != null)
              ..._conteudoLocalizacao(),
            const SizedBox(height: 24),
            _botaoAtualizar(),
            const SizedBox(height: 12),
            _botaoContinuar(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _cabecalho() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.azulPrimario,
            AppColors.azulSecundario,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.gps_fixed_rounded,
            color: Colors.white,
            size: 34,
          ),
          SizedBox(height: 18),
          Text(
            'Leitura de campo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'O aplicativo está obtendo sua posição atual para iniciar a conferência técnica.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardCarregando() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borda),
      ),
      child: const Column(
        children: [
          SizedBox(
            height: 44,
            width: 44,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              color: AppColors.azulPrimario,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Obtendo localização GPS...',
            style: TextStyle(
              color: AppColors.textoPrincipal,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Aguarde alguns segundos. Em área aberta, a precisão será melhor.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textoSecundario,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardErro() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.erroClaro,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.erro.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.location_off_rounded,
            color: AppColors.erro,
            size: 42,
          ),
          const SizedBox(height: 12),
          const Text(
            'Não foi possível obter o GPS',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.erro,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _erro ?? 'Erro desconhecido ao obter localização.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textoPrincipal,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _obterLocalizacao,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('TENTAR NOVAMENTE'),
          ),
        ],
      ),
    );
  }

  List<Widget> _conteudoLocalizacao() {
    final localizacao = _localizacao!;

    return [
      _statusGps(localizacao),
      const SizedBox(height: 16),
      _cardCoordenadas(localizacao),
      const SizedBox(height: 16),
      _cardInformacoesTecnicas(localizacao),
      const SizedBox(height: 20),
      const Text(
        'Próxima etapa',
        style: TextStyle(
          color: AppColors.textoPrincipal,
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        'O app usará esta posição para localizar o eixo da obra, calcular estaca, offset e lado da rodovia.',
        style: TextStyle(
          color: AppColors.textoSecundario,
          fontSize: 14,
          height: 1.4,
        ),
      ),
    ];
  }

  Widget _statusGps(DadosLocalizacao localizacao) {
    final boaPrecisao = localizacao.precisao <= 10;
    final precisaoMedia =
        localizacao.precisao > 10 && localizacao.precisao <= 20;

    final cor = boaPrecisao
        ? AppColors.sucesso
        : precisaoMedia
            ? AppColors.atencao
            : AppColors.erro;

    final fundo = boaPrecisao
        ? AppColors.sucessoClaro
        : precisaoMedia
            ? AppColors.atencaoClaro
            : AppColors.erroClaro;

    final situacao = boaPrecisao
        ? 'PRECISÃO BOA'
        : precisaoMedia
            ? 'PRECISÃO MÉDIA'
            : 'PRECISÃO BAIXA';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borda),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: fundo,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.gps_fixed_rounded,
              color: cor,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GPS conectado',
                  style: TextStyle(
                    color: AppColors.textoPrincipal,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Localização obtida com sucesso.',
                  style: TextStyle(
                    color: AppColors.textoSecundario,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: fundo,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              situacao,
              style: TextStyle(
                color: cor,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardCoordenadas(DadosLocalizacao localizacao) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.azulPrimario,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: Colors.white,
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'COORDENADAS ATUAIS',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            localizacao.coordenadasFormatadas,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Precisão estimada: ${localizacao.precisaoFormatada}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardInformacoesTecnicas(DadosLocalizacao localizacao) {
    final dataFormatada =
        DateFormat('dd/MM/yyyy HH:mm:ss', 'pt_BR').format(localizacao.dataHora);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borda),
      ),
      child: Column(
        children: [
          _linhaInformacao(
            icone: Icons.my_location_rounded,
            titulo: 'Precisão GPS',
            valor: localizacao.precisaoFormatada,
          ),
          const Divider(height: 24),
          _linhaInformacao(
            icone: Icons.terrain_outlined,
            titulo: 'Altitude',
            valor: '${localizacao.altitude.toStringAsFixed(1)} m',
          ),
          const Divider(height: 24),
          _linhaInformacao(
            icone: Icons.speed_rounded,
            titulo: 'Velocidade',
            valor: '${(localizacao.velocidade * 3.6).toStringAsFixed(1)} km/h',
          ),
          const Divider(height: 24),
          _linhaInformacao(
            icone: Icons.access_time_rounded,
            titulo: 'Data e hora',
            valor: dataFormatada,
          ),
        ],
      ),
    );
  }

  Widget _linhaInformacao({
    required IconData icone,
    required String titulo,
    required String valor,
  }) {
    return Row(
      children: [
        Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: AppColors.azulClaro,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icone,
            color: AppColors.azulPrimario,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            titulo,
            style: const TextStyle(
              color: AppColors.textoSecundario,
              fontSize: 14,
            ),
          ),
        ),
        Flexible(
          child: Text(
            valor,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: AppColors.textoPrincipal,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _botaoAtualizar() {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _carregando ? null : _obterLocalizacao,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('ATUALIZAR LOCALIZAÇÃO'),
      ),
    );
  }

  Widget _botaoContinuar() {
    return SizedBox(
      height: 58,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _localizacao == null || _carregando ? null : _continuar,
        icon: const Icon(Icons.arrow_forward_rounded),
        label: const Text('CONTINUAR CONFERÊNCIA'),
      ),
    );
  }
}