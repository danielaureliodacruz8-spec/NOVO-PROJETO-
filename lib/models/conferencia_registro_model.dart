class ConferenciaRegistroModel {
  final String id;
  final String codigoDrenagem;
  final String identificacaoDrenagem;
  final String? estaca;
  final String? lado;
  final double latitude;
  final double longitude;
  final double? precisaoMetros;
  final double? distanciaDispositivoMetros;
  final List<bool> itensConcluidos;
  final List<String> fotos;
  final String observacao;
  final DateTime dataHora;

  const ConferenciaRegistroModel({
    required this.id,
    required this.codigoDrenagem,
    required this.identificacaoDrenagem,
    required this.latitude,
    required this.longitude,
    required this.itensConcluidos,
    required this.dataHora,
    this.estaca,
    this.lado,
    this.precisaoMetros,
    this.distanciaDispositivoMetros,
    this.fotos = const [],
    this.observacao = '',
  });

  int get quantidadeItensConcluidos {
    return itensConcluidos.where((item) => item).length;
  }

  int get quantidadeItens {
    return itensConcluidos.length;
  }

  bool get roteiroConcluido {
    return quantidadeItens > 0 && quantidadeItensConcluidos == quantidadeItens;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigoDrenagem': codigoDrenagem,
      'identificacaoDrenagem': identificacaoDrenagem,
      'estaca': estaca,
      'lado': lado,
      'latitude': latitude,
      'longitude': longitude,
      'precisaoMetros': precisaoMetros,
      'distanciaDispositivoMetros': distanciaDispositivoMetros,
      'itensConcluidos': itensConcluidos,
      'fotos': fotos,
      'observacao': observacao,
      'dataHora': dataHora.toIso8601String(),
    };
  }

  factory ConferenciaRegistroModel.fromMap(Map<String, dynamic> map) {
    return ConferenciaRegistroModel(
      id: map['id']?.toString() ?? '',
      codigoDrenagem: map['codigoDrenagem']?.toString() ?? '',
      identificacaoDrenagem: map['identificacaoDrenagem']?.toString() ?? '',
      estaca: map['estaca']?.toString(),
      lado: map['lado']?.toString(),
      latitude: _converterDouble(map['latitude']),
      longitude: _converterDouble(map['longitude']),
      precisaoMetros: _converterDoubleNulo(map['precisaoMetros']),
      distanciaDispositivoMetros:
          _converterDoubleNulo(map['distanciaDispositivoMetros']),
      itensConcluidos: _converterListaBool(map['itensConcluidos']),
      fotos: _converterListaString(map['fotos']),
      observacao: map['observacao']?.toString() ?? '',
      dataHora: _converterData(map['dataHora']),
    );
  }

  ConferenciaRegistroModel copyWith({
    String? id,
    String? codigoDrenagem,
    String? identificacaoDrenagem,
    String? estaca,
    String? lado,
    double? latitude,
    double? longitude,
    double? precisaoMetros,
    double? distanciaDispositivoMetros,
    List<bool>? itensConcluidos,
    List<String>? fotos,
    String? observacao,
    DateTime? dataHora,
  }) {
    return ConferenciaRegistroModel(
      id: id ?? this.id,
      codigoDrenagem: codigoDrenagem ?? this.codigoDrenagem,
      identificacaoDrenagem:
          identificacaoDrenagem ?? this.identificacaoDrenagem,
      estaca: estaca ?? this.estaca,
      lado: lado ?? this.lado,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      precisaoMetros: precisaoMetros ?? this.precisaoMetros,
      distanciaDispositivoMetros:
          distanciaDispositivoMetros ?? this.distanciaDispositivoMetros,
      itensConcluidos: itensConcluidos ?? this.itensConcluidos,
      fotos: fotos ?? this.fotos,
      observacao: observacao ?? this.observacao,
      dataHora: dataHora ?? this.dataHora,
    );
  }

  static double _converterDouble(dynamic valor) {
    if (valor is num) return valor.toDouble();
    return double.tryParse(valor?.toString() ?? '') ?? 0;
  }

  static double? _converterDoubleNulo(dynamic valor) {
    if (valor == null) return null;
    if (valor is num) return valor.toDouble();
    return double.tryParse(valor.toString());
  }

  static List<bool> _converterListaBool(dynamic valor) {
    if (valor is! List) return [];

    return valor.map((item) {
      if (item is bool) return item;
      return item.toString().toLowerCase() == 'true';
    }).toList();
  }

  static List<String> _converterListaString(dynamic valor) {
    if (valor is! List) return [];

    return valor.map((item) => item.toString()).toList();
  }

  static DateTime _converterData(dynamic valor) {
    return DateTime.tryParse(valor?.toString() ?? '') ?? DateTime.now();
  }
}