
import 'package:flutter/material.dart';

import '../models/drenagem_model.dart';
import '../services/eixo_estaca_service.dart';

class RoteiroDrenagemScreen extends StatefulWidget {
  final DrenagemModel drenagem;
  final ResultadoEstaca resultadoEstaca;
  final double? precisaoMetros;
  final double? distanciaMetros;
  final dynamic pontoDrenagem;

  const RoteiroDrenagemScreen({
    super.key,
    required this.drenagem,
    required this.resultadoEstaca,
    this.precisaoMetros,
    this.distanciaMetros,
    this.pontoDrenagem,
  });

  @override
  State<RoteiroDrenagemScreen> createState() =>
      _RoteiroDrenagemScreenState();
}

class _RoteiroDrenagemScreenState
    extends State<RoteiroDrenagemScreen> {
  final TextEditingController _observacaoController =
      TextEditingController();

  final Map<String, bool> _itens = {
    'Dispositivo localizado em campo': false,
    'Estaca conferida': false,
    'Lado da rodovia conferido': false,
    'Dimensões verificadas': false,
    'Condições de conservação verificadas': false,
    'Entrada do dispositivo verificada': false,
    'Saída do dispositivo verificada': false,
    'Limpeza e obstruções verificadas': false,
    'Registro fotográfico realizado': false,
  };

  @override
  void dispose() {
    _observacaoController.dispose();
    super.dispose();
  }

  int get _quantidadeConcluida =>
      _itens.values.where((concluido) => concluido).length;

  Future<void> _salvarConferencia() async {
    if (_quantidadeConcluida == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Marque ao menos um item do roteiro de conferência.',
          ),
          backgroundColor: Colors.orange.shade800,
        ),
      );
      return;
    }

    // Agora retorna List<bool>, compatível com o modelo.
    final List<bool> itensConcluidos =
        _itens.values.toList();

    final pontoDrenagem = widget.pontoDrenagem ??
        _PontoDrenagemTemporario(
          estaca: widget.resultadoEstaca.estacaFormatada,
          lado: widget.resultadoEstaca.lado,
        );

    Navigator.pop<Map<String, dynamic>>(
      context,
      {
        'drenagem': widget.drenagem,
        'pontoDrenagem': pontoDrenagem,
        'estaca': widget.resultadoEstaca.estacaFormatada,
        'lado': widget.resultadoEstaca.lado,
        'latitude': widget.resultadoEstaca.latitude,
        'longitude': widget.resultadoEstaca.longitude,
        'precisaoMetros': widget.precisaoMetros,
        'distanciaMetros':
            widget.distanciaMetros ??
                widget.resultadoEstaca.offsetMetros,
        'offsetMetros': widget.resultadoEstaca.offsetMetros,
        'utmEste': widget.resultadoEstaca.utmEste,
        'utmNorte': widget.resultadoEstaca.utmNorte,
        'rodovia': widget.resultadoEstaca.rodovia,
        'nomeEixo': widget.resultadoEstaca.nomeEixo,
        'itensConcluidos': itensConcluidos,
        'observacao': _observacaoController.text.trim(),
        'dataHora': DateTime.now(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalItens = _itens.length;
    final percentual = totalItens == 0
        ? 0.0
        : _quantidadeConcluida / totalItens;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Roteiro de Drenagem'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _cardDrenagem(),
            const SizedBox(height: 16),
            _cardLocalizacao(),
            const SizedBox(height: 20),
            _tituloRoteiro(percentual),
            const SizedBox(height: 10),
            _listaItens(),
            const SizedBox(height: 20),
            _campoObservacao(),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _salvarConferencia,
              icon: const Icon(Icons.save),
              label: const Text(
                'SALVAR CONFERÊNCIA',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _cardDrenagem() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.water_drop),
                SizedBox(width: 8),
                Text(
                  'DRENAGEM IDENTIFICADA',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              widget.drenagem.codigo,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              widget.drenagem.identificacao,
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardLocalizacao() {
    final resultado = widget.resultadoEstaca;

    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.gps_fixed, color: Colors.blue.shade800),
                const SizedBox(width: 8),
                Text(
                  'LOCALIZAÇÃO AUTOMÁTICA',
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _linhaLocalizacao('Rodovia', resultado.rodovia, Icons.route),
            _linhaLocalizacao(
              'Estaca',
              resultado.estacaFormatada,
              Icons.signpost,
              destaque: true,
            ),
            _linhaLocalizacao(
              'Lado',
              resultado.lado,
              resultado.lado == 'Direito'
                  ? Icons.turn_right
                  : Icons.turn_left,
            ),
            _linhaLocalizacao(
              'Offset ao eixo',
              '${resultado.offsetMetros.toStringAsFixed(2)} m',
              Icons.swap_horiz,
            ),
            if (widget.precisaoMetros != null)
              _linhaLocalizacao(
                'Precisão GPS',
                '± ${widget.precisaoMetros!.toStringAsFixed(1)} m',
                Icons.gps_fixed,
              ),
          ],
        ),
      ),
    );
  }

  Widget _linhaLocalizacao(
    String titulo,
    String valor,
    IconData icone, {
    bool destaque = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          Icon(icone, size: 20, color: Colors.blue.shade800),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text(
              '$titulo:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: destaque ? 18 : 15,
                fontWeight:
                    destaque ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tituloRoteiro(double percentual) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.checklist),
            const SizedBox(width: 8),
            const Text(
              'ROTEIRO DE CONFERÊNCIA',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.4,
              ),
            ),
            const Spacer(),
            Text(
              '$_quantidadeConcluida/${_itens.length}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentual,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _listaItens() {
    return Card(
      child: Column(
        children: _itens.entries.map((item) {
          return CheckboxListTile(
            value: item.value,
            title: Text(
              item.key,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (valor) {
              setState(() {
                _itens[item.key] = valor ?? false;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _campoObservacao() {
    return TextField(
      controller: _observacaoController,
      minLines: 4,
      maxLines: 7,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        labelText: 'Observações da conferência',
        hintText:
            'Informe não conformidades, condições do dispositivo ou observações de campo.',
        alignLabelWithHint: true,
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: 80),
          child: Icon(Icons.notes),
        ),
        border: OutlineInputBorder(),
      ),
    );
  }
}

class _PontoDrenagemTemporario {
  final String estaca;
  final String lado;

  const _PontoDrenagemTemporario({
    required this.estaca,
    required this.lado,
  });
}
