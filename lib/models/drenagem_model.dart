enum TipoDrenagem {
  vpac,
  stc,
  meioFio,
  entradaDescidaAgua,
  transposicaoSarjeta,
  dar,
  dad,
  dissipadorSarjetaValeta,
  dissipadorDescidaAgua,
  valetao,
  outro,
}

class DrenagemModel {
  final String id;
  final TipoDrenagem tipo;
  final String codigo;
  final String identificacao;

  final String? rodovia;
  final String? trecho;
  final String? segmento;
  final String? estaca;
  final String? lado;

  final double? latitude;
  final double? longitude;

  final double? largura;
  final double? altura;
  final double? comprimento;
  final double? espessura;
  final double? vazao;

  final String? dispositivoAdaptavel;
  final String? norma;
  final String? observacao;

  const DrenagemModel({
    required this.id,
    required this.tipo,
    required this.codigo,
    required this.identificacao,
    this.rodovia,
    this.trecho,
    this.segmento,
    this.estaca,
    this.lado,
    this.latitude,
    this.longitude,
    this.largura,
    this.altura,
    this.comprimento,
    this.espessura,
    this.vazao,
    this.dispositivoAdaptavel,
    this.norma,
    this.observacao,
  });

  String get nomeTipo {
    switch (tipo) {
      case TipoDrenagem.vpac:
        return 'Valeta de Proteção de Aterro';
      case TipoDrenagem.stc:
        return 'Sarjeta Triangular de Concreto';
      case TipoDrenagem.meioFio:
        return 'Meio-fio de Concreto';
      case TipoDrenagem.entradaDescidaAgua:
        return 'Entrada para Descida d\'Água';
      case TipoDrenagem.transposicaoSarjeta:
        return 'Transposição de Segmento de Sarjeta';
      case TipoDrenagem.dar:
        return 'Descida d\'Água Tipo Rápido';
      case TipoDrenagem.dad:
        return 'Descida d\'Água em Degraus';
      case TipoDrenagem.dissipadorSarjetaValeta:
        return 'Dissipador para Sarjeta ou Valeta';
      case TipoDrenagem.dissipadorDescidaAgua:
        return 'Dissipador para Descida d\'Água';
      case TipoDrenagem.valetao:
        return 'Valetão';
      case TipoDrenagem.outro:
        return 'Outro Dispositivo';
    }
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
        ? 'Localização ainda não informada'
        : partes.join(' • ');
  }

  String get dimensoesResumidas {
    final medidas = <String>[];

    if (largura != null) {
      medidas.add('Largura: ${largura!.toStringAsFixed(2)} m');
    }

    if (altura != null) {
      medidas.add('Altura: ${altura!.toStringAsFixed(2)} m');
    }

    if (comprimento != null) {
      medidas.add('Comp.: ${comprimento!.toStringAsFixed(2)} m');
    }

    if (espessura != null) {
      medidas.add('Esp.: ${espessura!.toStringAsFixed(2)} m');
    }

    if (vazao != null) {
      medidas.add('Vazão: ${vazao!.toStringAsFixed(4)} m³/s');
    }

    return medidas.isEmpty
        ? 'Dimensões devem ser verificadas em campo.'
        : medidas.join(' • ');
  }

  List<String> get roteiroPadrao {
    switch (tipo) {
      case TipoDrenagem.vpac:
        return [
          'Foto geral do trecho da valeta',
          'Medir largura total da valeta',
          'Medir altura das laterais',
          'Medir espessura do concreto',
          'Verificar juntas de dilatação a cada 12 m',
          'Verificar acabamento, fissuras e erosões',
          'Foto final com escala ou trena',
        ];

      case TipoDrenagem.stc:
        return [
          'Foto geral do trecho da sarjeta',
          'Medir largura da sarjeta',
          'Medir altura ou profundidade',
          'Medir espessura do concreto',
          'Verificar juntas de dilatação a cada 12 m',
          'Verificar escoamento, fissuras e acabamento',
          'Foto final com escala ou trena',
        ];

      case TipoDrenagem.meioFio:
        return [
          'Foto geral do meio-fio',
          'Medir altura aparente da peça',
          'Medir largura da base',
          'Verificar alinhamento e nivelamento',
          'Verificar juntas e rejuntamento',
          'Registrar método executivo utilizado',
          'Foto final com escala ou trena',
        ];

      case TipoDrenagem.entradaDescidaAgua:
        return [
          'Foto geral da entrada da descida d\'água',
          'Verificar ligação com o meio-fio',
          'Medir largura da entrada',
          'Medir comprimento do dispositivo',
          'Verificar acabamento e direcionamento da água',
          'Verificar fissuras, obstruções ou falhas',
          'Foto final com escala ou trena',
        ];

      case TipoDrenagem.transposicaoSarjeta:
        return [
          'Foto geral da transposição',
          'Verificar sarjetas conectadas ao dispositivo',
          'Medir comprimento da transposição',
          'Medir largura e espessura da laje',
          'Verificar armadura aparente, fissuras e acabamento',
          'Verificar escoamento da água',
          'Foto final com escala ou trena',
        ];

      case TipoDrenagem.dar:
        return [
          'Foto geral da descida d\'água tipo rápido',
          'Medir largura interna do canal',
          'Medir altura das laterais',
          'Verificar armaduras e acabamento do concreto',
          'Verificar erosão nas laterais e no pé do aterro',
          'Verificar ligação com entrada e dissipador',
          'Foto final com escala ou trena',
        ];

      case TipoDrenagem.dad:
        return [
          'Foto geral da descida d\'água em degraus',
          'Medir largura do canal',
          'Medir altura dos degraus',
          'Verificar blocos de ancoragem a cada 2,40 m',
          'Verificar juntas para extensão superior a 10 m',
          'Verificar erosões, fissuras e escoamento',
          'Foto final com escala ou trena',
        ];

      case TipoDrenagem.dissipadorSarjetaValeta:
      case TipoDrenagem.dissipadorDescidaAgua:
        return [
          'Foto geral do dissipador',
          'Medir largura de entrada e saída',
          'Medir comprimento do dissipador',
          'Verificar pedras de mão de 15 a 25 cm',
          'Verificar concreto de fixação das pedras',
          'Verificar erosão, assoreamento e funcionamento',
          'Foto final com escala ou trena',
        ];

      case TipoDrenagem.valetao:
        return [
          'Foto geral do valetão',
          'Medir largura superior',
          'Medir largura da base',
          'Medir profundidade',
          'Verificar inclinação dos taludes',
          'Verificar erosão, assoreamento e escoamento',
          'Foto final com escala ou trena',
        ];

      case TipoDrenagem.outro:
        return [
          'Foto geral do dispositivo',
          'Registrar dimensões principais',
          'Fotografar detalhes importantes',
          'Registrar condição de conservação',
          'Descrever não conformidades encontradas',
        ];
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipo': tipo.name,
      'codigo': codigo,
      'identificacao': identificacao,
      'rodovia': rodovia,
      'trecho': trecho,
      'segmento': segmento,
      'estaca': estaca,
      'lado': lado,
      'latitude': latitude,
      'longitude': longitude,
      'largura': largura,
      'altura': altura,
      'comprimento': comprimento,
      'espessura': espessura,
      'vazao': vazao,
      'dispositivoAdaptavel': dispositivoAdaptavel,
      'norma': norma,
      'observacao': observacao,
    };
  }

  factory DrenagemModel.fromMap(Map<String, dynamic> map) {
    return DrenagemModel(
      id: map['id'] as String? ?? '',
      tipo: TipoDrenagem.values.firstWhere(
        (item) => item.name == map['tipo'],
        orElse: () => TipoDrenagem.outro,
      ),
      codigo: map['codigo'] as String? ?? '',
      identificacao: map['identificacao'] as String? ?? '',
      rodovia: map['rodovia'] as String?,
      trecho: map['trecho'] as String?,
      segmento: map['segmento'] as String?,
      estaca: map['estaca'] as String?,
      lado: map['lado'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      largura: (map['largura'] as num?)?.toDouble(),
      altura: (map['altura'] as num?)?.toDouble(),
      comprimento: (map['comprimento'] as num?)?.toDouble(),
      espessura: (map['espessura'] as num?)?.toDouble(),
      vazao: (map['vazao'] as num?)?.toDouble(),
      dispositivoAdaptavel: map['dispositivoAdaptavel'] as String?,
      norma: map['norma'] as String?,
      observacao: map['observacao'] as String?,
    );
  }
}

class CatalogoDrenagemSuperficial {
  static const String obra = 'Rodovia GO-236';
  static const String trecho = 'Flores de Goiás – Entr. BR-020';
  static const String segmento = '236EGO0040 — km 70,454 ao km 134,831';
  static const String projeto = 'Drenagem';
  static const String codigoEtel = '583-GO-2026-4-01-DRE-DE-0003';
  static const String revisao = 'A00 — Emissão inicial em 18/09/2026';
  static const String normaDnit = 'DNIT 018-ES';

  static const List<DrenagemModel> dispositivos = [
    DrenagemModel(
      id: 'vpac-160-30',
      tipo: TipoDrenagem.vpac,
      codigo: 'VPAC 160-30',
      identificacao: 'Valeta de Proteção de Aterro em Concreto',
      rodovia: obra,
      trecho: trecho,
      segmento: segmento,
      largura: 1.60,
      altura: 0.30,
      espessura: 0.08,
      norma: normaDnit,
      observacao:
          'Juntas de dilatação a cada 12 m. Argamassa 1:3 nas juntas.',
    ),
    DrenagemModel(
      id: 'vpac-120-30',
      tipo: TipoDrenagem.vpac,
      codigo: 'VPAC 120-30',
      identificacao: 'Valeta de Proteção de Aterro em Concreto',
      rodovia: obra,
      trecho: trecho,
      segmento: segmento,
      largura: 1.20,
      altura: 0.30,
      espessura: 0.08,
      norma: normaDnit,
      observacao:
          'Juntas de dilatação a cada 12 m. Argamassa 1:3 nas juntas.',
    ),
    DrenagemModel(
      id: 'stc-150-30',
      tipo: TipoDrenagem.stc,
      codigo: 'STC 150-30',
      identificacao: 'Sarjeta Triangular de Concreto',
      rodovia: obra,
      trecho: trecho,
      segmento: segmento,
      largura: 1.50,
      altura: 0.30,
      espessura: 0.08,
      norma: normaDnit,
      observacao: 'Juntas de dilatação a cada 12 m.',
    ),
    DrenagemModel(
      id: 'stc-125-25',
      tipo: TipoDrenagem.stc,
      codigo: 'STC 125-25',
      identificacao: 'Sarjeta Triangular de Concreto',
      rodovia: obra,
      trecho: trecho,
      segmento: segmento,
      largura: 1.25,
      altura: 0.25,
      espessura: 0.08,
      norma: normaDnit,
      observacao: 'Juntas de dilatação a cada 12 m.',
    ),
    DrenagemModel(
      id: 'stc-100-20',
      tipo: TipoDrenagem.stc,
      codigo: 'STC 100-20',
      identificacao: 'Sarjeta Triangular de Concreto',
      rodovia: obra,
      trecho: trecho,
      segmento: segmento,
      largura: 1.00,
      altura: 0.20,
      espessura: 0.08,
      norma: normaDnit,
      observacao: 'Juntas de dilatação a cada 12 m.',
    ),
    DrenagemModel(
      id: 'stc-80-15',
      tipo: TipoDrenagem.stc,
      codigo: 'STC 80-15',
      identificacao: 'Sarjeta Triangular de Concreto',
      rodovia: obra,
      trecho: trecho,
      segmento: segmento,
      largura: 0.80,
      altura: 0.15,
      espessura: 0.08,
      norma: normaDnit,
      observacao: 'Juntas de dilatação a cada 12 m.',
    ),
    DrenagemModel(
      id: 'mfc-03',
      tipo: TipoDrenagem.meioFio,
      codigo: 'MFC 03',
      identificacao: 'Meio-fio de Concreto',
      rodovia: obra,
      trecho: trecho,
      segmento: segmento,
      norma: normaDnit,
      observacao: 'Métodos: convencional, extrusão ou pré-moldado.',
    ),
    DrenagemModel(
      id: 'eda-03-a',
      tipo: TipoDrenagem.entradaDescidaAgua,
      codigo: 'EDA 03 A',
      identificacao: 'Entrada para Descida d\'Água',
      rodovia: obra,
      trecho: trecho,
      segmento: segmento,
      largura: 0.60,
      comprimento: 1.92,
      dispositivoAdaptavel: 'MFC 03 + DAR 60-30',
      observacao: 'Entrada adaptável para descida d\'água tipo rápido.',
    ),
    DrenagemModel(
      id: 'eda-05-a',
      tipo: TipoDrenagem.entradaDescidaAgua,
      codigo: 'EDA 05 A',
      identificacao: 'Entrada para Descida d\'Água',
      rodovia: obra,
      trecho: trecho,
      segmento: segmento,
      largura: 0.60,
      comprimento: 1.92,
      dispositivoAdaptavel: 'MFC 03 + DAD 60-36',
      observacao: 'Entrada adaptável para descida d\'água em degraus.',
    ),
    DrenagemModel(
      id: 'eda-03-b',
      tipo: TipoDrenagem.entradaDescidaAgua,
      codigo: 'EDA 03 B',
      identificacao: 'Entrada para Descida d\'Água',
      rodovia: obra,
      trecho: trecho,
      segmento: segmento,
      largura: 0.60,
      comprimento: 3.24,
      dispositivoAdaptavel: 'MFC 03 + DAR 60-30',
      observacao: 'Entrada com extensão maior para descida d\'água tipo rápido.',
    ),
    DrenagemModel(
      id: 'tss-130',
      tipo: TipoDrenagem.transposicaoSarjeta,
      codigo: 'TSS 130',
      identificacao: 'Transposição de Segmento de Sarjeta',
      rodovia: obra,
      trecho: trecho,
      segmento: segmento,
      largura: 0.50,
      comprimento: 1.30,
      espessura: 0.21,
      dispositivoAdaptavel: 'STC 80-15 / STC 88-20',
      observacao: 'Laje de concreto armado. Aço CA-50: 26,2533 kg/m.',
    ),
    DrenagemModel(
      id: 'tss-150',
      tipo: TipoDrenagem.transposicaoSarjeta,
      codigo: 'TSS 150',
      identificacao: 'Transposição de Segmento de Sarjeta',
      rodovia: obra,
      trecho: trecho,
      segmento: segmento,
      largura: 0.50,
      comprimento: 1.50,
      espessura: 0.21,
      dispositivoAdaptavel: 'STC 100-20 / STC 108-25 / SZC 90-30',
      observacao: 'Laje de concreto armado. Aço CA-50: 29,8503 kg/m.',
    ),
    DrenagemModel(
      id: 'tss-170',
      tipo: TipoDrenagem.transposicaoSarjeta,
      codigo: 'TSS 170',
      identificacao: 'Transposição de Segmento de Sarjeta',
      rodovia: obra,
      trecho: trecho,
      segmento: segmento,
      largura: 0.50,
      comprimento: 1.70,
      espessura: 0.21,
      dispositivoAdaptavel: 'STC 125-25 / STC 125-27',
      observacao: 'Laje de concreto armado. Aço CA-50: 39,2548 kg/m.',
    ),
    DrenagemModel(
      id: 'tss-200',
      tipo: TipoDrenagem.transposicaoSarjeta,
      codigo: 'TSS 200',
      identificacao: 'Transposição de Segmento de Sarjeta',
      rodovia: obra,
      trecho: trecho,
      segmento: segmento,
      largura: 0.50,
      comprimento: 2.00,
      espessura: 0.21,
      dispositivoAdaptavel: 'STC 150-30 / STC 150-32',
      observacao: 'Laje de concreto armado. Aço CA-50: 45,5971 kg/m.',
    ),
    DrenagemModel(
      id: 'dar-60-30',
      tipo: TipoDrenagem.dar,
      codigo: 'DAR 60-30',
      identificacao: 'Descida d\'Água Tipo Rápido',
      rodovia: obra,
      trecho: trecho,
      segmento: segmento,
      largura: 0.60,
      altura: 0.12,
      vazao: 0.2784,
      observacao:
          'Laterais de 12 cm. Altura máxima de aterro prevista: 5 m.',
    ),
    DrenagemModel(
      id: 'dad-60-36',
      tipo: TipoDrenagem.dad,
      codigo: 'DAD 60-36',
      identificacao: 'Descida d\'Água de Aterro em Degraus',
      rodovia: obra,
      trecho: trecho,
      segmento: segmento,
      largura: 0.60,
      altura: 0.36,
      vazao: 0.5361,
      observacao:
          'Blocos de ancoragem a cada 2,40 m. Juntas de dilatação para extensões superiores a 10 m.',
    ),
    DrenagemModel(
      id: 'des-160-480',
      tipo: TipoDrenagem.dissipadorSarjetaValeta,
      codigo: 'DES 160-480',
      identificacao: 'Dissipador de Energia para Sarjeta e Valeta',
      rodovia: obra,
      trecho: trecho,
      segmento: segmento,
      largura: 1.60,
      comprimento: 3.20,
      dispositivoAdaptavel: 'VPAC 160-30',
      observacao:
          'L2: 4,80 m. Pedras de mão de 15 a 25 cm. Velocidade máxima: 4,50 m/s.',
    ),
    DrenagemModel(
      id: 'des-150-450',
      tipo: TipoDrenagem.dissipadorSarjetaValeta,
      codigo: 'DES 150-450',
      identificacao: 'Dissipador de Energia para Sarjeta e Valeta',
      rodovia: obra,
      trecho: trecho,
      segmento: segmento,
      largura: 1.50,
      comprimento: 3.00,
      dispositivoAdaptavel: 'STC 150-30 / STC 150-32',
      observacao:
          'L2: 4,50 m. Pedras de mão de 15 a 25 cm. Velocidade máxima: 4,50 m/s.',
    ),
    DrenagemModel(
      id: 'des-125-375',
      tipo: TipoDrenagem.dissipadorSarjetaValeta,
      codigo: 'DES 125-375',
      identificacao: 'Dissipador de Energia para Sarjeta e Valeta',
      rodovia: obra,
      trecho: trecho,
      segmento: segmento,
      largura: 1.25,
      comprimento: 2.50,
      dispositivoAdaptavel: 'STC 125-25 / STC 125-27',
      observacao:
          'L2: 3,75 m. Pedras de mão de 15 a 25 cm. Velocidade máxima: 4,50 m/s.',
    ),
    DrenagemModel(
      id: 'des-120-360',
      tipo: TipoDrenagem.dissipadorSarjetaValeta,
      codigo: 'DES 120-360',
      identificacao: 'Dissipador de Energia para Sarjeta e Valeta',
      rodovia: obra,
      trecho: trecho,
      segmento: segmento,
      largura: 1.20,
      comprimento: 2.40,
      dispositivoAdaptavel: 'VPAC 120-30',
      observacao:
          'L2: 3,60 m. Pedras de mão de 15 a 25 cm. Velocidade máxima: 4,50 m/s.',
    ),
    DrenagemModel(
      id: 'des-100-300',
      tipo: TipoDrenagem.dissipadorSarjetaValeta,
      codigo: 'DES 100-300',
      identificacao: 'Dissipador de Energia para Sarjeta e Valeta',
      rodovia: obra,
      trecho: trecho,
      segmento: segmento,
      largura: 1.00,
      comprimento: 2.00,
      dispositivoAdaptavel: 'STC 100-20 / STC 100-21',
      observacao:
          'L2: 3,00 m. Pedras de mão de 15 a 25 cm. Velocidade máxima: 4,50 m/s.',
    ),
    DrenagemModel(
      id: 'des-80-240',
      tipo: TipoDrenagem.dissipadorSarjetaValeta,
      codigo: 'DES 80-240',
      identificacao: 'Dissipador de Energia para Sarjeta e Valeta',
      rodovia: obra,
      trecho: trecho,
      segmento: segmento,
      largura: 0.80,
      comprimento: 1.60,
      dispositivoAdaptavel: 'STC 80-15 / STC 80-17',
      observacao:
          'L2: 2,40 m. Pedras de mão de 15 a 25 cm. Velocidade máxima: 4,50 m/s.',
    ),
    DrenagemModel(
      id: 'ded-01-a',
      tipo: TipoDrenagem.dissipadorDescidaAgua,
      codigo: 'DED 01 A',
      identificacao: 'Dissipador de Energia para Descida d\'Água',
      rodovia: obra,
      trecho: trecho,
      segmento: segmento,
      largura: 0.60,
      comprimento: 2.00,
      dispositivoAdaptavel: 'DAR 60-30',
      observacao:
          'L2: 1,80 m. Pedras de mão de 15 a 25 cm. Velocidade máxima: 5,50 m/s.',
    ),
    DrenagemModel(
      id: 'ded-03-a',
      tipo: TipoDrenagem.dissipadorDescidaAgua,
      codigo: 'DED 03 A',
      identificacao: 'Dissipador de Energia para Descida d\'Água',
      rodovia: obra,
      trecho: trecho,
      segmento: segmento,
      largura: 0.60,
      comprimento: 2.00,
      dispositivoAdaptavel: 'DAD 60-36',
      observacao:
          'L2: 1,80 m. Pedras de mão de 15 a 25 cm. Velocidade máxima: 5,50 m/s.',
    ),
    DrenagemModel(
      id: 'valetao',
      tipo: TipoDrenagem.valetao,
      codigo: 'VALETÃO',
      identificacao: 'Valetão',
      rodovia: obra,
      trecho: trecho,
      segmento: segmento,
      largura: 3.00,
      altura: 0.75,
      observacao:
          'Dimensões variáveis: profundidade de 0,75 m a 1,50 m; largura de 3,00 m a 6,00 m; base de 2,00 m a 3,50 m; taludes 1:1.',
    ),
  ];
}