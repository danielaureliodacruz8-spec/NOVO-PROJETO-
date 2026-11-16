
ConferenciaRegistroModel? _criarRegistro(
  Map<String, dynamic> resultado,
) {
  final drenagem = resultado['drenagem'];

  if (drenagem is! DrenagemModel) return null;

  final itens = _converterItens(resultado['itensConcluidos']);

  final estaca =
      resultado['estaca']?.toString() ??
      _obterPropriedade(resultado['pontoDrenagem'], 'estaca');

  final lado =
      resultado['lado']?.toString() ??
      _obterPropriedade(resultado['pontoDrenagem'], 'lado');

  final medidasConcreto =
      _converterMapaDouble(resultado['medidasConcreto']);

  return ConferenciaRegistroModel(
    id: _uuid.v4(),
    codigoDrenagem: drenagem.codigo,
    identificacaoDrenagem: drenagem.identificacao,
    rodovia: drenagem.rodovia,
    estaca: estaca,
    lado: lado,
    latitude: _converterDouble(resultado['latitude']),
    longitude: _converterDouble(resultado['longitude']),
    precisaoMetros:
        _converterDoubleNulo(resultado['precisaoMetros']),
    distanciaDispositivoMetros:
        _converterDoubleNulo(resultado['distanciaMetros']),
    itensConcluidos: itens,
    observacao: resultado['observacao']?.toString() ?? '',
    dataHora: resultado['dataHora'] is DateTime
        ? resultado['dataHora'] as DateTime
        : DateTime.now(),
    medidasExecutadas: medidasConcreto,
    volumeConcretoM3:
        _converterDoubleNulo(resultado['volumeConcretoM3']),

    // Novos dados detalhados da TSS.
    tipoTss: resultado['tipoTss']?.toString(),
    calculadoPorMedicaoReal:
        resultado['calculadoPorMedicaoReal'] == true,
    resultadoTss:
        _converterMapaDinamico(resultado['resultadoTss']),
  );
}
