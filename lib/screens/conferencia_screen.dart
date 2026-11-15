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
              color: AppColors