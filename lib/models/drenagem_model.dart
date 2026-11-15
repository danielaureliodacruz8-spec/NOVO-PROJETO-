enum TipoDrenagem {
  bstc,
  bdtc,
  btcc,
  sarjeta,
  valeta,
  descidaDagua,
  caixaColetora,
  bocaDeLobo,
  dissipador,
  outro,
}

class DrenagemModel {
  final String id;
  final TipoDrenagem tipo;
  final String identificacao;
  final String? rodovia;
  final String? trecho;
  final String? estaca;
  final String? lado;
  final double? latitude;
  final double? longitude;
  final double? diametroProjeto;
  final double? larguraProjeto;
  final double? alturaProjeto;
  final double? comprimentoProjeto;
  final String? observacao;

  const DrenagemModel({
    required this.id,
    required this.tipo,
    required this.identificacao,
    this.rodovia,
    this.trecho,
    this.estaca,
    this.lado,
    this.latitude,
    this.longitude,
    this.diametroProjeto,
    this.larguraProjeto,
    this.alturaProjeto,
    this.comprimentoProjeto,
    this.observacao,
  });

  String get nomeTipo {
    switch (tipo) {
      case TipoDrenagem.bstc:
        return 'BSTC';
      case TipoDrenagem.bdtc:
        return 'BDTC';
      case TipoDrenagem.btcc:
        return 'BTCC';
      case TipoDrenagem.sarjeta:
        return 'Sarjeta';
      case TipoDrenagem.valeta:
        return 'Valeta';
      case TipoDrenagem.descidaDagua:
        return 'Descida d’água';
      case TipoDrenagem.caixaColetora:
        return 'Caixa coletora';
      case TipoDrenagem.bocaDeLobo:
        return 'Boca de lobo';
      case TipoDrenagem.dissipador:
        return 'Dissipador de energia';
      case TipoDrenagem.outro:
        return 'Outro dispositivo';
    }
  }

  String get descricaoCompleta {
    final medidas = <String>[];

    if (diametroProjeto != null) {
      medidas.add('Ø ${diametroProjeto!.toStringAsFixed(2)} m');
    }

    if (larguraProjeto != null && alturaProjeto != null) {
      medidas.add(
        '${larguraProjeto!.toStringAsFixed(2)} x '
        '${alturaProjeto!.toStringAsFixed(2)} m',
      );
    } else if (larguraProjeto != null) {
      medidas.add('Largura ${larguraProjeto!.toStringAsFixed(2)} m');
    }

    if (comprimentoProjeto != null) {
      medidas.add('Comp. ${comprimentoProjeto!.toStringAsFixed(2)} m');
    }

    if (medidas.isEmpty) {
      return nomeTipo;
    }

    return '$nomeTipo • ${medidas.join(' • ')}';
  }

  String get localizacaoResumida {
    final partes = <String>[];

    if (rodovia != null && rodovia!.trim().isNotEmpty) {
      partes.add(rodovia!);
    }

    if (trecho != null && trecho!.trim().isNotEmpty) {
      partes.add(trecho!);
    }

    if (estaca != null && estaca!.trim().isNotEmpty) {
      partes.add('Estaca $estaca');
    }

    if (lado != null && lado!.trim().isNotEmpty) {
      partes.add(lado!);
    }

    return partes.isEmpty
        ? 'Localização ainda não vinculada ao eixo'
        : partes.join(' • ');
  }

  List<String> get roteiroPadrao {
    switch (tipo) {
      case TipoDrenagem.bstc:
      case TipoDrenagem.bdtc:
      case TipoDrenagem.btcc:
        return [
          'Foto geral do dispositivo',
          'Foto da boca de entrada',
          'Medir diâmetro ou largura interna',
          'Medir altura interna',
          'Medir comprimento aparente',
          'Foto da boca de saída',
          'Registrar condição de conservação',
        ];

      case TipoDrenagem.sarjeta:
      case TipoDrenagem.valeta:
        return [
          'Foto geral do trecho',
          'Medir largura superior',
          'Medir largura de fundo',
          'Medir profundidade',
          'Verificar revestimento e escoamento',
          'Foto final da medição',
          'Registrar condição de conservação',
        ];

      case TipoDrenagem.descidaDagua:
        return [
          'Foto geral da descida d’água',
          'Foto do início da descida',
          'Medir largura ou diâmetro',
          'Verificar declividade e revestimento',
          'Foto do ponto de saída',
          'Registrar condição de conservação',
        ];

      case TipoDrenagem.caixaColetora:
      case TipoDrenagem.bocaDeLobo:
        return [
          'Foto geral do dispositivo',
          'Foto da entrada de água',
          'Medir largura interna',
          'Medir comprimento interno',
          'Medir profundidade',
          'Verificar limpeza e obstruções',
          'Registrar condição de conservação',
        ];

      case TipoDrenagem.dissipador:
        return [
          'Foto geral do dissipador',
          'Medir largura',
          'Medir comprimento',
          'Verificar erosões e assoreamento',
          'Foto da saída da água',
          'Registrar condição de conservação',
        ];

      case TipoDrenagem.outro:
        return [
          'Foto geral do dispositivo',
          'Registrar medidas principais',
          'Foto do detalhe relevante',
          'Registrar condição de conservação',
        ];
    }
  }

  DrenagemModel copyWith({
    String? id,
    TipoDrenagem? tipo,
    String? identificacao,
    String? rodovia,
    String? trecho,
    String? estaca,
    String? lado,
    double? latitude,
    double? longitude,
    double? diametroProjeto,
    double? larguraProjeto,
    double? alturaProjeto,
    double? comprimentoProjeto,
    String? observacao,
  }) {
    return DrenagemModel(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      identificacao: identificacao ?? this.identificacao,
      rodovia: rodovia ?? this.rodovia,
      trecho: trecho ?? this.trecho,
      estaca: estaca ?? this.estaca,
      lado: lado ?? this.lado,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      diametroProjeto: diametroProjeto ?? this.diametroProjeto,
      larguraProjeto: larguraProjeto ?? this.larguraProjeto,
      alturaProjeto: alturaProjeto ?? this.alturaProjeto,
      comprimentoProjeto: comprimentoProjeto ?? this.comprimentoProjeto,
      observacao: observacao ?? this.observacao,
    );
  }
}