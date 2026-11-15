import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ConferenciaScreen extends StatefulWidget {
  const ConferenciaScreen({super.key});

  @override
  State<ConferenciaScreen> createState() => _ConferenciaScreenState();
}

class _ConferenciaScreenState extends State<ConferenciaScreen> {
  int _abaSelecionada = 0;

  void _iniciarConferenciaAutomatica() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'A tela de localização automática será adicionada no próximo arquivo.',
        ),
      ),
    );
  }

  void _novaConferenciaManual() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'A conferência manual será integrada à nova versão em seguida.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _abaSelecionada,
          children: [
            _telaInicio(),
            _telaHistorico(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _abaSelecionada,
        onDestinationSelected: (index) {
          setState(() {
            _abaSelecionada = index;
          });
        },
        indicatorColor: AppColors.azulClaro,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Histórico',
          ),
        ],
      ),
    );
  }

  Widget _telaInicio() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _cabecalho(),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              [
                _tituloBoasVindas(),
                const SizedBox(height: 20),
                _cardGps(),
                const SizedBox(height: 16),
                _cardLocalizacao(),
                const SizedBox(height: 24),
                _botaoIniciar(),
                const SizedBox(height: 14),
                _botaoManual(),
                const SizedBox(height: 28),
                _tituloSecao(
                  titulo: 'Resumo de campo',
                  subtitulo: 'Acompanhe as conferências realizadas.',
                ),
                const SizedBox(height: 14),
                _resumoConferencias(),
                const SizedBox(height: 28),
                _tituloSecao(
                  titulo: 'Como funciona',
                  subtitulo: 'Fluxo da conferência automática.',
                ),
                const SizedBox(height: 14),
                _etapasAutomaticas(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _cabecalho() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 26),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.azulPrimario,
            AppColors.azulSecundario,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
            child: const Icon(
              Icons.engineering_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STRATA CONFERÊNCIA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Fiscalização de Drenagem',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tituloBoasVindas() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conferência de campo',
          style: TextStyle(
            color: AppColors.textoPrincipal,
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Inicie uma nova vistoria com localização, medições e fotos técnicas.',
          style: TextStyle(
            color: AppColors.textoSecundario,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _cardGps() {
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
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: AppColors.sucessoClaro,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.gps_fixed_rounded,
              color: AppColors.sucesso,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GPS pronto para leitura',
                  style: TextStyle(
                    color: AppColors.textoPrincipal,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'A localização será obtida ao iniciar a conferência.',
                  style: TextStyle(
                    color: AppColors.textoSecundario,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const _StatusPonto(
            texto: 'PRONTO',
            cor: AppColors.sucesso,
            fundo: AppColors.sucessoClaro,
          ),
        ],
      ),
    );
  }

  Widget _cardLocalizacao() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.azulPrimario,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.azulPrimario.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: Colors.white,
                size: 23,
              ),
              SizedBox(width: 8),
              Text(
                'LOCALIZAÇÃO DA OBRA',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          SizedBox(height: 18),
          Text(
            'Aguardando leitura GPS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Rodovia, trecho, estaca, offset e lado serão identificados automaticamente.',
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

  Widget _botaoIniciar() {
    return SizedBox(
      height: 60,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _iniciarConferenciaAutomatica,
        icon: const Icon(Icons.play_arrow_rounded, size: 26),
        label: const Text('INICIAR CONFERÊNCIA AUTOMÁTICA'),
      ),
    );
  }

  Widget _botaoManual() {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _novaConferenciaManual,
        icon: const Icon(Icons.edit_note_rounded),
        label: const Text('NOVA CONFERÊNCIA MANUAL'),
      ),
    );
  }

  Widget _tituloSecao({
    required String titulo,
    required String subtitulo,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            color: AppColors.textoPrincipal,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitulo,
          style: const TextStyle(
            color: AppColors.textoSecundario,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _resumoConferencias() {
    return Row(
      children: [
        Expanded(
          child: _cardResumo(
            icone: Icons.assignment_turned_in_outlined,
            titulo: '0',
            descricao: 'Conferências',
            cor: AppColors.azulSecundario,
            fundo: AppColors.azulClaro,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _cardResumo(
            icone: Icons.photo_camera_outlined,
            titulo: '0',
            descricao: 'Fotos técnicas',
            cor: AppColors.atencao,
            fundo: AppColors.atencaoClaro,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _cardResumo(
            icone: Icons.check_circle_outline_rounded,
            titulo: '0',
            descricao: 'Concluídas',
            cor: AppColors.sucesso,
            fundo: AppColors.sucessoClaro,
          ),
        ),
      ],
    );
  }

  Widget _cardResumo({
    required IconData icone,
    required String titulo,
    required String descricao,
    required Color cor,
    required Color fundo,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borda),
      ),
      child: Column(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: fundo,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icone, color: cor, size: 21),
          ),
          const SizedBox(height: 10),
          Text(
            titulo,
            style: const TextStyle(
              color: AppColors.textoPrincipal,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            descricao,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textoSecundario,
              fontSize: 11,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _etapasAutomaticas() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borda),
      ),
      child: const Column(
        children: [
          _EtapaAutomatica(
            numero: '1',
            titulo: 'Localização por GPS',
            descricao: 'Captura coordenadas e precisão do aparelho.',
          ),
          _LinhaEtapa(),
          _EtapaAutomatica(
            numero: '2',
            titulo: 'Identificação da obra',
            descricao: 'Localiza eixo, estaca, offset e lado.',
          ),
          _LinhaEtapa(),
          _EtapaAutomatica(
            numero: '3',
            titulo: 'Roteiro de drenagem',
            descricao: 'Orienta medições e fotos obrigatórias.',
          ),
          _LinhaEtapa(),
          _EtapaAutomatica(
            numero: '4',
            titulo: 'Registro técnico',
            descricao: 'Salva fotos com dados da conferência.',
          ),
        ],
      ),
    );
  }

  Widget _telaHistorico() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Histórico',
              style: TextStyle(
                color: AppColors.textoPrincipal,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Conferências realizadas em campo.',
              style: TextStyle(
                color: AppColors.textoSecundario,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: Center(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.superficie,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borda),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.folder_open_outlined,
                        size: 58,
                        color: AppColors.textoSecundario,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Nenhuma conferência cadastrada',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textoPrincipal,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Inicie uma conferência automática para criar o primeiro registro técnico.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textoSecundario,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPonto extends StatelessWidget {
  final String texto;
  final Color cor;
  final Color fundo;

  const _StatusPonto({
    required this.texto,
    required this.cor,
    required this.fundo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: cor,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _EtapaAutomatica extends StatelessWidget {
  final String numero;
  final String titulo;
  final String descricao;

  const _EtapaAutomatica({
    required this.numero,
    required this.titulo,
    required this.descricao,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 30,
          width: 30,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.azulClaro,
            shape: BoxShape.circle,
          ),
          child: Text(
            numero,
            style: const TextStyle(
              color: AppColors.azulPrimario,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: AppColors.textoPrincipal,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  descricao,
                  style: const TextStyle(
                    color: AppColors.textoSecundario,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LinhaEtapa extends StatelessWidget {
  const _LinhaEtapa();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      width: 2,
      margin: const EdgeInsets.only(left: 14),
      color: AppColors.borda,
    );
  }
}