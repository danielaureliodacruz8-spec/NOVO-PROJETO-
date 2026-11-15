
class ConferenciaRegistroModel {
  final String id;
  final String codigoDrenagem;
  final String identificacaoDrenagem;
  final String rodovia;
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

  final Map<String, double> medidasProjeto;
  final Map<String, double> medidasExecutadas;
  final Map<String, double> tolerancias;
  final double? volumeConcretoM3;

  const ConferenciaRegistroModel({
    required this.id,
    required this.codigoDrenagem,
    required this.identificacaoDrenagem,
    required this.latitude,
    required this.longitude,
    required this.itensConcluidos,
    required this.dataHora,
    this.rodovia = '',
    this.estaca,
    this.lado,
    this.precisaoMetros,
    this.distanciaDispositivoMetros,
    this.fotos = const [],
    this.observacao = '',
    this.medidasProjeto = const {},
    this.medidasExecutadas = const {},
    this.tolerancias = const {},
    this.volumeConcretoM3,
  });

  int get quantidadeItensConcluidos =>
      itensConcluidos.where((item) => item).length;

  int get quantidadeItens => itensConcluidos.length;

  bool get roteiroConcluido =>
      quantidadeItens > 0 &&
      quantidadeItensConcluidos == quantidadeItens;

  String get statusConferencia {
    if (medidasExecutadas.isEmpty) return 'Pendente';

    for (final chave in medidasExecutadas.keys) {
      final projeto = medidasProjeto[chave];
      final executado = medidasExecutadas[chave];
      final tolerancia = tolerancias[chave];

      if (projeto == null || executado == null || tolerancia == null) {
        return 'Pendente';
      }

      if ((executado - projeto).abs() > tolerancia) {
        return 'Reprovado';
      }
    }

    if (medidasProjeto.isEmpty ||
        medidasExecutadas.length != medidasProjeto.length) {
      return 'Pendente';
    }

    return 'Aprovado';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigoDrenagem': codigoDrenagem,
      'identificacaoDrenagem': identificacaoDrenagem,
      'rodovia': rodovia,
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
      'medidasProjeto': medidasProjeto,
      'medidasExecutadas': medidasExecutadas,
      'tolerancias': tolerancias,
      'volumeConcretoM3': volumeConcretoM3,
    };
  }

  factory ConferenciaRegistroModel.fromMap(Map<String, dynamic> map) {
    return ConferenciaRegistroModel(
      id: map['id']?.toString() ?? '',
      codigoDrenagem: map['codigoDrenagem']?.toString() ?? '',
      identificacaoDrenagem:
          map['identificacaoDrenagem']?.toString() ?? '',
      rodovia: map['rodovia']?.toString() ?? '',
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
      medidasProjeto: _converterMapaDouble(map['medidasProjeto']),
      medidasExecutadas: _converterMapaDouble(map['medidasExecutadas']),
      tolerancias: _converterMapaDouble(map['tolerancias']),
      volumeConcretoM3: _converterDoubleNulo(map['volumeConcretoM3']),
    );
  }

  ConferenciaRegistroModel copyWith({
    String? id,
    String? codigoDrenagem,
    String? identificacaoDrenagem,
    String? rodovia,
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
    Map<String, double>? medidasProjeto,
    Map<String, double>? medidasExecutadas,
    Map<String, double>? tolerancias,
    double? volumeConcretoM3,
  }) {
    return ConferenciaRegistroModel(
      id: id ?? this.id,
      codigoDrenagem: codigoDrenagem ?? this.codigoDrenagem,
      identificacaoDrenagem:
          identificacaoDrenagem ?? this.identificacaoDrenagem,
      rodovia: rodovia ?? this.rodovia,
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
      medidasProjeto: medidasProjeto ?? this.medidasProjeto,
      medidasExecutadas: medidasExecutadas ?? this.medidasExecutadas,
      tolerancias: tolerancias ?? this.tolerancias,
      volumeConcretoM3: volumeConcretoM3 ?? this.volumeConcretoM3,
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

  static Map<String, double> _converterMapaDouble(dynamic valor) {
    if (valor is! Map) return {};

    final resultado = <String, double>{};

    valor.forEach((chave, medida) {
      final numero = _converterDoubleNulo(medida);
      if (numero != null) {
        resultado[chave.toString()] = numero;
      }
    });

    return resultado;
  }

  static DateTime _converterData(dynamic valor) {
    return DateTime.tryParse(valor?.toString() ?? '') ?? DateTime.now();
  }
}
