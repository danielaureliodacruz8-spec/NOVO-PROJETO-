
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/conferencia_model.dart';

class ConferenciaDetailScreen extends StatefulWidget {
  final Conferencia conferencia;
  final Future<void> Function() aoSalvar;

  const ConferenciaDetailScreen({
    super.key,
    required this.conferencia,
    required this.aoSalvar,
  });

  @override
  State<ConferenciaDetailScreen> createState() =>
      _ConferenciaDetailScreenState();
}

class _ConferenciaDetailScreenState extends State<ConferenciaDetailScreen> {
  late TextEditingController _observacaoController;
  bool _salvando = false;

  dynamic get _conferencia => widget.conferencia;

  @override
  void initState() {
    super.initState();

    _observacaoController = TextEditingController(
      text: _texto(_valor(_conferencia, 'observacao')),
    );
  }

  @override
  void dispose() {
    _observacaoController.dispose();
    super.dispose();
  }

  dynamic _valor(dynamic objeto, String chave) {
    if (objeto == null) return null;

    if (objeto is Map) {
      return objeto[chave];
    }

    try {
      switch (chave) {
        case 'id':
          return objeto.id;
        case 'obra':
          return objeto.obra;
        case 'rodovia':
          return objeto.rodovia;
        case 'trecho':
          return objeto.trecho;
        case 'estaca':
          return objeto.estaca;
        case 'offset':
          return objeto.offset;
        case 'lado':
          return objeto.lado;
        case 'observacao':
          return objeto.observacao;
        case 'dataCriacao':
          return objeto.dataCriacao;
        case 'medicoes':
          return objeto.medicoes;
        case 'fotos':
          return objeto.fotos;
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  String _texto(dynamic valor) {
    if (valor == null) return '';
    return valor.toString();
  }

  String _caminhoFoto(dynamic foto) {
    const chavesPossiveis = [
      'caminhoImagem',
      'caminho',
      'path',
      'arquivo',
      'imagem',
      'foto',
      'url',
    ];

    for (final chave in chavesPossiveis) {
      final valor = _valorFoto(foto, chave);

      if (valor != null && valor.toString().trim().isNotEmpty) {
        return valor.toString().trim();
      }
    }

    return '';
  }

  dynamic _valorFoto(dynamic foto, String chave) {
    if (foto == null) return null;

    if (foto is Map) {
      return foto[chave];
    }

    try {
      switch (chave) {
        case 'caminhoImagem':
          return foto.caminhoImagem;
        case 'caminho':
          return foto.caminho;
        case 'path':
          return foto.path;
        case 'arquivo':
          return foto.arquivo;
        case 'imagem':
          return foto.imagem;
        case 'foto':
          return foto.foto;
        case 'url':
          return foto.url;
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  String _descricaoMedicao(dynamic medicao, int numero) {
    if (medicao == null) {
      return 'Medição $numero';
    }

    if (medicao is Map) {
      final tipo = medicao['tipo'] ??
          medicao['nome'] ??
          medicao['descricao'] ??
          'Medição $numero';

      final valor = medicao['valor'] ??
          medicao['medida'] ??
          medicao['resultado'] ??
          '';

      final unidade = medicao['unidade'] ?? '';

      return '$tipo${valor.toString().isNotEmpty ? ': $valor $unidade' : ''}';
    }

    try {
      final dynamic tipo =
          medicao.tipo ?? medicao.nome ?? medicao.descricao ?? 'Medição $numero';

      final dynamic valor =
          medicao.valor ?? medicao.medida ?? medicao.resultado ?? '';

      final dynamic unidade = medicao.unidade ?? '';

      return '$tipo${valor.toString().isNotEmpty ? ': $valor $unidade' : ''}';
    } catch (_) {
      return medicao.toString();
    }
  }

  Future<void> _salvar() async {
    setState(() {
      _salvando = true;
    });

    try {
      await widget.aoSalvar();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conferência salva com sucesso.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível salvar a conferência.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }

  void _abrirFoto(String caminho) {
    if (caminho.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _VisualizarFotoScreen(caminho: caminho),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final medicoes =
        List<dynamic>.from(_valor(_conferencia, 'medicoes') ?? const []);

    final fotos = List<dynamic>.from(_valor(_conferencia, 'fotos') ?? const []);

    final obra = _texto(_valor(_conferencia, 'obra'));
    final rodovia = _texto(_valor(_conferencia, 'rodovia'));
    final trecho = _texto(_valor(_conferencia, 'trecho'));
    final estaca = _texto(_valor(_conferencia, 'estaca'));
    final offset = _texto(_valor(_conferencia, 'offset'));
    final lado = _texto(_valor(_conferencia, 'lado'));
    final dataCriacao = _texto(_valor(_conferencia, 'dataCriacao'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Conferência'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Salvar',
            onPressed: _salvando ? null : _salvar,
            icon: _salvando
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _titulo('Localização'),
          const SizedBox(height: 10),
          _card(
            children: [
              _linha('Obra', obra),
              _linha('Rodovia', rodovia),
              _linha('Trecho', trecho),
              _linha('Estaca', estaca),
              _linha('Offset', offset),
              _linha('Lado', lado),
              _linha('Data', dataCriacao),
            ],
          ),
          const SizedBox(height: 20),
          _titulo('Observação'),
          const SizedBox(height: 10),
          TextField(
            controller: _observacaoController,
            minLines: 4,
            maxLines: 8,
            decoration: InputDecoration(
              hintText: 'Digite uma observação...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 20),
          _titulo('Medições (${medicoes.length})'),
          const SizedBox(height: 10),
          if (medicoes.isEmpty)
            _vazio(
              icone: Icons.straighten,
              texto: 'Nenhuma medição cadastrada.',
            )
          else
            ...List.generate(medicoes.length, (index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(_descricaoMedicao(medicoes[index], index + 1)),
                ),
              );
            }),
          const SizedBox(height: 20),
          _titulo('Fotos (${fotos.length})'),
          const SizedBox(height: 10),
          if (fotos.isEmpty)
            _vazio(
              icone: Icons.photo_camera_outlined,
              texto: 'Nenhuma foto cadastrada.',
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: fotos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final caminho = _caminhoFoto(fotos[index]);

                return InkWell(
                  onTap: caminho.isEmpty ? null : () => _abrirFoto(caminho),
                  borderRadius: BorderRadius.circular(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      color: Colors.grey.shade200,
                      child: _imagemFoto(caminho),
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 28),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _salvando ? null : _salvar,
              icon: const Icon(Icons.save),
              label: Text(_salvando ? 'Salvando...' : 'Salvar Conferência'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _imagemFoto(String caminho) {
    if (caminho.isEmpty) {
      return const Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 45,
          color: Colors.grey,
        ),
      );
    }

    if (caminho.startsWith('http://') || caminho.startsWith('https://')) {
      return Image.network(
        caminho,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return const Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 45,
              color: Colors.grey,
            ),
          );
        },
      );
    }

    final arquivo = File(caminho);

    if (!arquivo.existsSync()) {
      return const Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 45,
          color: Colors.grey,
        ),
      );
    }

    return Image.file(
      arquivo,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return const Center(
          child: Icon(
            Icons.broken_image_outlined,
            size: 45,
            color: Colors.grey,
          ),
        );
      },
    );
  }

  Widget _titulo(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(children: children),
      ),
    );
  }

  Widget _linha(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$titulo:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              valor.isEmpty ? '-' : valor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _vazio({
    required IconData icone,
    required String texto,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icone,
            size: 45,
            color: Colors.grey,
          ),
          const SizedBox(height: 10),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _VisualizarFotoScreen extends StatelessWidget {
  final String caminho;

  const _VisualizarFotoScreen({
    required this.caminho,
  });

  @override
  Widget build(BuildContext context) {
    final bool ehUrl =
        caminho.startsWith('http://') || caminho.startsWith('https://');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Foto da Conferência'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4,
          child: ehUrl
              ? Image.network(
                  caminho,
                  errorBuilder: (_, __, ___) {
                    return const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white,
                      size: 70,
                    );
                  },
                )
              : Image.file(
                  File(caminho),
                  errorBuilder: (_, __, ___) {
                    return const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white,
                      size: 70,
                    );
                  },
                ),
        ),
      ),
    );
  }
}
