
class TipoTssProjeto {
  final String codigo;
  final String descricao;
  final List<String> dispositivosAdaptaveis;
  final double larguraLajeMetros;
  final double espessuraLajeMetros;
  final double consumoBaseFck20PorMetro;
  final double consumoLajeFck25PorMetro;
  final double consumoEscavacaoPorMetro;
  final double consumoFormaPorMetro;
  final double acoN1KgPorMetro;
  final double acoN2KgPorMetro;

  const TipoTssProjeto({
    required this.codigo,
    required this.descricao,
    required this.dispositivosAdaptaveis,
    required this.larguraLajeMetros,
    required this.espessuraLajeMetros,
    required this.consumoBaseFck20PorMetro,
    required this.consumoLajeFck25PorMetro,
    required this.consumoEscavacaoPorMetro,
    required this.consumoFormaPorMetro,
    required this.acoN1KgPorMetro,
    required this.acoN2KgPorMetro,
  });

  double get consumoTotalConcretoPorMetro =>
      consumoBaseFck20PorMetro + consumoLajeFck25PorMetro;

  double get acoTotalKgPorMetro => acoN1KgPorMetro + acoN2KgPorMetro;
}

const tiposTssProjeto = <TipoTssProjeto>[
  TipoTssProjeto(
    codigo: 'TSS 130',
    descricao: 'Transposição de segmentos de sarjeta - largura 1,30 m',
    dispositivosAdaptaveis: ['STC 80-15', 'STC 88-20'],
    larguraLajeMetros: 1.30,
    espessuraLajeMetros: 0.21,
    consumoEscavacaoPorMetro: 0.5047,
    consumoBaseFck20PorMetro: 0.7649,
    consumoLajeFck25PorMetro: 0.2730,
    consumoFormaPorMetro: 3.3496,
    acoN1KgPorMetro: 23.8278,
    acoN2KgPorMetro: 2.4255,
  ),
  TipoTssProjeto(
    codigo: 'TSS 150',
    descricao: 'Transposição de segmentos de sarjeta - largura 1,50 m',
    dispositivosAdaptaveis: ['STC 100-20', 'STC 108-25', 'SZC 90-30'],
    larguraLajeMetros: 1.50,
    espessuraLajeMetros: 0.21,
    consumoEscavacaoPorMetro: 0.5031,
    consumoBaseFck20PorMetro: 0.7637,
    consumoLajeFck25PorMetro: 0.3150,
    consumoFormaPorMetro: 3.7176,
    acoN1KgPorMetro: 26.9838,
    acoN2KgPorMetro: 2.8665,
  ),
  TipoTssProjeto(
    codigo: 'TSS 170',
    descricao: 'Transposição de segmentos de sarjeta - largura 1,70 m',
    dispositivosAdaptaveis: ['STC 125-25', 'STC 125-27'],
    larguraLajeMetros: 1.70,
    espessuraLajeMetros: 0.21,
    consumoEscavacaoPorMetro: 0.5026,
    consumoBaseFck20PorMetro: 0.7637,
    consumoLajeFck25PorMetro: 0.3570,
    consumoFormaPorMetro: 4.0856,
    acoN1KgPorMetro: 36.1678,
    acoN2KgPorMetro: 3.0870,
  ),
  TipoTssProjeto(
    codigo: 'TSS 200',
    descricao: 'Transposição de segmentos de sarjeta - largura 2,00 m',
    dispositivosAdaptaveis: ['STC 150-30', 'STC 150-32'],
    larguraLajeMetros: 2.00,
    espessuraLajeMetros: 0.21,
    consumoEscavacaoPorMetro: 0.5146,
    consumoBaseFck20PorMetro: 0.7790,
    consumoLajeFck25PorMetro: 0.4200,
    consumoFormaPorMetro: 4.6376,
    acoN1KgPorMetro: 41.8486,
    acoN2KgPorMetro: 3.7485,
  ),
];

class ResultadoVolumeTss {
  final TipoTssProjeto tipo;
  final bool calculadoPorMedicaoReal;

  final double comprimentoExecutadoMetros;

  final double volumeEscavacao;

  final double volumeBaseFck20;
  final double volumeLajeFck25;

  final double volumeBaseFck20Projeto;
  final double volumeLajeFck25Projeto;

  final double volumeBaseFck20Diferenca;
  final double volumeLajeFck25Diferenca;

  final double? areaLiquidaBaseMedida;
  final double areaLiquidaBaseProjeto;

  final double larguraLajeMedida;
  final double espessuraLajeMedida;

  final double areaForma;
  final double acoN1Kg;
  final double acoN2Kg;

  const ResultadoVolumeTss({
    required this.tipo,
    required this.calculadoPorMedicaoReal,
    required this.comprimentoExecutadoMetros,
    required this.volumeEscavacao,
    required this.volumeBaseFck20,
    required this.volumeLajeFck25,
    required this.volumeBaseFck20Projeto,
    required this.volumeLajeFck25Projeto,
    required this.volumeBaseFck20Diferenca,
    required this.volumeLajeFck25Diferenca,
    required this.areaLiquidaBaseMedida,
    required this.areaLiquidaBaseProjeto,
    required this.larguraLajeMedida,
    required this.espessuraLajeMedida,
    required this.areaForma,
    required this.acoN1Kg,
    required this.acoN2Kg,
  });

  double get volumeTotalConcreto =>
      volumeBaseFck20 + volumeLajeFck25;

  double get volumeTotalConcretoProjeto =>
      volumeBaseFck20Projeto + volumeLajeFck25Projeto;

  double get diferencaTotalConcreto =>
      volumeTotalConcreto - volumeTotalConcretoProjeto;

  double get percentualDiferencaTotal {
    if (volumeTotalConcretoProjeto <= 0) return 0;
    return diferencaTotalConcreto /
        volumeTotalConcretoProjeto * 100;
  }

  double get acoTotalKg => acoN1Kg + acoN2Kg;

  Map<String, dynamic> toMap() {
    return {
      'tipoTss': tipo.codigo,
      'descricaoTss': tipo.descricao,
      'dispositivosAdaptaveis': tipo.dispositivosAdaptaveis,
      'calculadoPorMedicaoReal': calculadoPorMedicaoReal,
      'comprimentoExecutadoMetros': comprimentoExecutadoMetros,
      'areaLiquidaBaseMedida': areaLiquidaBaseMedida,
      'areaLiquidaBaseProjeto': areaLiquidaBaseProjeto,
      'larguraLajeMedida': larguraLajeMedida,
      'espessuraLajeMedida': espessuraLajeMedida,
      'volumeEscavacao': volumeEscavacao,
      'volumeBaseFck20': volumeBaseFck20,
      'volumeLajeFck25': volumeLajeFck25,
      'volumeTotalConcreto': volumeTotalConcreto,
      'volumeBaseFck20Projeto': volumeBaseFck20Projeto,
      'volumeLajeFck25Projeto': volumeLajeFck25Projeto,
      'volumeTotalConcretoProjeto': volumeTotalConcretoProjeto,
      'volumeBaseFck20Diferenca': volumeBaseFck20Diferenca,
      'volumeLajeFck25Diferenca': volumeLajeFck25Diferenca,
      'diferencaTotalConcreto': diferencaTotalConcreto,
      'percentualDiferencaTotal': percentualDiferencaTotal,
      'areaForma': areaForma,
      'acoN1Kg': acoN1Kg,
      'acoN2Kg': acoN2Kg,
      'acoTotalKg': acoTotalKg,
    };
  }
}

class CalculoTssService {
  static const double comprimentoMaximoSegmentoMetros = 3.00;

  TipoTssProjeto buscarTipoPorCodigo(String codigo) {
    final normalizado = codigo.trim().toUpperCase();

    for (final tipo in tiposTssProjeto) {
      if (tipo.codigo.toUpperCase() == normalizado) {
        return tipo;
      }
    }

    throw ArgumentError('Tipo de TSS não encontrado: $codigo.');
  }

  ResultadoVolumeTss calcularPorProjeto({
    required TipoTssProjeto tipo,
    required double comprimentoExecutadoMetros,
  }) {
    _validarTipo(tipo);
    _validarComprimento(comprimentoExecutadoMetros);

    final base = tipo.consumoBaseFck20PorMetro *
        comprimentoExecutadoMetros;
    final laje = tipo.consumoLajeFck25PorMetro *
        comprimentoExecutadoMetros;

    return ResultadoVolumeTss(
      tipo: tipo,
      calculadoPorMedicaoReal: false,
      comprimentoExecutadoMetros: comprimentoExecutadoMetros,
      volumeEscavacao: tipo.consumoEscavacaoPorMetro *
          comprimentoExecutadoMetros,
      volumeBaseFck20: base,
      volumeLajeFck25: laje,
      volumeBaseFck20Projeto: base,
      volumeLajeFck25Projeto: laje,
      volumeBaseFck20Diferenca: 0,
      volumeLajeFck25Diferenca: 0,
      areaLiquidaBaseMedida: null,
      areaLiquidaBaseProjeto: tipo.consumoBaseFck20PorMetro,
      larguraLajeMedida: tipo.larguraLajeMetros,
      espessuraLajeMedida: tipo.espessuraLajeMetros,
      areaForma: tipo.consumoFormaPorMetro *
          comprimentoExecutadoMetros,
      acoN1Kg: tipo.acoN1KgPorMetro *
          comprimentoExecutadoMetros,
      acoN2Kg: tipo.acoN2KgPorMetro *
          comprimentoExecutadoMetros,
    );
  }

  ResultadoVolumeTss calcularPorMedicaoReal({
    required TipoTssProjeto tipo,
    required double comprimentoExecutadoMetros,
    required double areaLiquidaBaseMetrosQuadrados,
    required double larguraLajeMetros,
    required double espessuraLajeMetros,
  }) {
    _validarTipo(tipo);
    _validarComprimento(comprimentoExecutadoMetros);

    _validarMaiorQueZero(
      areaLiquidaBaseMetrosQuadrados,
      'Área líquida da base',
    );
    _validarMaiorQueZero(larguraLajeMetros, 'Largura da laje');
    _validarMaiorQueZero(espessuraLajeMetros, 'Espessura da laje');

    final volumeBase = areaLiquidaBaseMetrosQuadrados *
        comprimentoExecutadoMetros;

    final volumeLaje = larguraLajeMetros *
        espessuraLajeMetros *
        comprimentoExecutadoMetros;

    final baseProjeto = tipo.consumoBaseFck20PorMetro *
        comprimentoExecutadoMetros;

    final lajeProjeto = tipo.consumoLajeFck25PorMetro *
        comprimentoExecutadoMetros;

    return ResultadoVolumeTss(
      tipo: tipo,
      calculadoPorMedicaoReal: true,
      comprimentoExecutadoMetros: comprimentoExecutadoMetros,
      volumeEscavacao: tipo.consumoEscavacaoPorMetro *
          comprimentoExecutadoMetros,
      volumeBaseFck20: volumeBase,
      volumeLajeFck25: volumeLaje,
      volumeBaseFck20Projeto: baseProjeto,
      volumeLajeFck25Projeto: lajeProjeto,
      volumeBaseFck20Diferenca: volumeBase - baseProjeto,
      volumeLajeFck25Diferenca: volumeLaje - lajeProjeto,
      areaLiquidaBaseMedida: areaLiquidaBaseMetrosQuadrados,
      areaLiquidaBaseProjeto: tipo.consumoBaseFck20PorMetro,
      larguraLajeMedida: larguraLajeMetros,
      espessuraLajeMedida: espessuraLajeMetros,
      areaForma: tipo.consumoFormaPorMetro *
          comprimentoExecutadoMetros,
      acoN1Kg: tipo.acoN1KgPorMetro *
          comprimentoExecutadoMetros,
      acoN2Kg: tipo.acoN2KgPorMetro *
          comprimentoExecutadoMetros,
    );
  }

  void _validarTipo(TipoTssProjeto tipo) {
    if (!tiposTssProjeto.any((item) => item.codigo == tipo.codigo)) {
      throw ArgumentError('Tipo de TSS inválido.');
    }
  }

  void _validarComprimento(double valor) {
    _validarMaiorQueZero(valor, 'Comprimento executado');

    if (valor > comprimentoMaximoSegmentoMetros) {
      throw ArgumentError(
        'O comprimento informado é ${valor.toStringAsFixed(2)} m. '
        'O limite cadastrado é 3,00 m por segmento de TSS.',
      );
    }
  }

  void _validarMaiorQueZero(double valor, String nomeCampo) {
    if (!valor.isFinite || valor <= 0) {
      throw ArgumentError(
        '$nomeCampo deve ser um número válido maior que zero.',
      );
    }
  }
}
