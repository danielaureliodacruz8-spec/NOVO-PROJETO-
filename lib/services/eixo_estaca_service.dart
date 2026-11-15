import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart';

class ResultadoEstaca {
  final String rodovia;
  final String nomeEixo;
  final double estacaNumerica;
  final String estacaFormatada;
  final double offsetMetros;
  final String lado;
  final double latitude;
  final double longitude;
  final double utmEste;
  final double utmNorte;

  const ResultadoEstaca({
    required this.rodovia,
    required this.nomeEixo,
    required this.estacaNumerica,
    required this.estacaFormatada,
    required this.offsetMetros,
    required this.lado,
    required this.latitude,
    required this.longitude,
    required this.utmEste,
    required this.utmNorte,
  });
}

class EixoEstacaService {
  static const String eixoGo236 =
      'assets/eixo/20261027_EIXO_GO236_R.xml';

  static const String eixoGo110 =
      'assets/eixo/Alinhamento_Horizontal_GO110_Est1500_a_2249.xml';

  final Map<String, _EixoCarregado> _cache = {};

  Future<ResultadoEstaca> calcularGo236({
    required double latitude,
    required double longitude,
  }) {
    return calcular(
      rodovia: 'GO-236',
      caminhoAsset: eixoGo236,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<ResultadoEstaca> calcularGo110({
    required double latitude,
    required double longitude,
  }) {
    return calcular(
      rodovia: 'GO-110',
      caminhoAsset: eixoGo110,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<ResultadoEstaca> calcular({
    required String rodovia,
    required String caminhoAsset,
    required double latitude,
    required double longitude,
  }) async {
    final eixo = await _carregarEixo(caminhoAsset);

    final pontoGps = _converterLatitudeLongitudeParaUtm23S(
      latitude: latitude,
      longitude: longitude,
    );

    _ProjecaoMaisProxima? melhorProjecao;

    for (final segmento in eixo.segmentos) {
      final projecao = _projetarNoSegmento(
        ponto: pontoGps,
        segmento: segmento,
      );

      if (melhorProjecao == null ||
          projecao.distancia < melhorProjecao.distancia) {
        melhorProjecao = projecao;
      }
    }

    if (melhorProjecao == null) {
      throw Exception('Não foi possível encontrar o eixo mais próximo.');
    }

    final segmento = melhorProjecao.segmento;

    final cadeiaNoEixo =
        segmento.cadeiaInicial +
        (segmento.comprimentoCadeia * melhorProjecao.t);

    final estacaNumerica =
        eixo.estacaInicial + (cadeiaNoEixo / 20.0);

    final vetorEixoX = segmento.fim.x - segmento.inicio.x;
    final vetorEixoY = segmento.fim.y - segmento.inicio.y;

    final vetorPontoX = pontoGps.x - melhorProjecao.pontoProjetado.x;
    final vetorPontoY = pontoGps.y - melhorProjecao.pontoProjetado.y;

    final produtoVetorial =
        (vetorEixoX * vetorPontoY) - (vetorEixoY * vetorPontoX);

    final lado = produtoVetorial >= 0 ? 'Esquerdo' : 'Direito';

    return ResultadoEstaca(
      rodovia: rodovia,
      nomeEixo: eixo.nome,
      estacaNumerica: estacaNumerica,
      estacaFormatada: _formatarEstaca(estacaNumerica),
      offsetMetros: melhorProjecao.distancia,
      lado: lado,
      latitude: latitude,
      longitude: longitude,
      utmEste: pontoGps.x,
      utmNorte: pontoGps.y,
    );
  }

  Future<_EixoCarregado> _carregarEixo(String caminhoAsset) async {
    final eixoSalvo = _cache[caminhoAsset];

    if (eixoSalvo != null) {
      return eixoSalvo;
    }

    final conteudoXml = await rootBundle.loadString(caminhoAsset);
    final documento = XmlDocument.parse(conteudoXml);

    final alinhamentos = documento.findAllElements('Alignment');

    if (alinhamentos.isEmpty) {
      throw Exception('Nenhum Alignment foi encontrado no LandXML.');
    }

    final alinhamento = alinhamentos.first;

    final nomeEixo =
        alinhamento.getAttribute('name') ?? 'Eixo sem identificação';

    final estacaInicial = _lerNumero(
      alinhamento.getAttribute('staStart'),
    );

    final coordGeom = alinhamento.findAllElements('CoordGeom').firstOrNull;

    if (coordGeom == null) {
      throw Exception('A geometria CoordGeom não foi encontrada no XML.');
    }

    final elementos = coordGeom.children
        .whereType<XmlElement>()
        .where(
          (elemento) =>
              elemento.name.local == 'Line' ||
              elemento.name.local == 'Curve' ||
              elemento.name.local == 'Spiral',
        )
        .toList();

    final segmentos = <_SegmentoEixo>[];
    double cadeiaAcumulada = 0;

    for (final elemento in elementos) {
      final pontoInicial = _lerPonto(elemento, 'Start');
      final pontoFinal = _lerPonto(elemento, 'End');

      if (pontoInicial == null || pontoFinal == null) {
        continue;
      }

      final comprimentoInformado = _lerNumero(
        elemento.getAttribute('length'),
      );

      final pontosGeometria = _criarPontosDaGeometria(
        elemento: elemento,
        inicio: pontoInicial,
        fim: pontoFinal,
      );

      final comprimentoGeometrico =
          _comprimentoDaPolilinha(pontosGeometria);

      if (comprimentoGeometrico <= 0) {
        continue;
      }

      final comprimentoParaEstaca = comprimentoInformado > 0
          ? comprimentoInformado
          : comprimentoGeometrico;

      double comprimentoGeometricoAcumulado = 0;

      for (var i = 0; i < pontosGeometria.length - 1; i++) {
        final inicioSegmento = pontosGeometria[i];
        final fimSegmento = pontosGeometria[i + 1];

        final comprimentoSegmento = _distancia(
          inicioSegmento,
          fimSegmento,
        );

        if (comprimentoSegmento <= 0) {
          continue;
        }

        final proporcao = comprimentoSegmento / comprimentoGeometrico;

        segmentos.add(
          _SegmentoEixo(
            inicio: inicioSegmento,
            fim: fimSegmento,
            cadeiaInicial:
                cadeiaAcumulada +
                (comprimentoParaEstaca *
                    (comprimentoGeometricoAcumulado /
                        comprimentoGeometrico)),
            comprimentoCadeia: comprimentoParaEstaca * proporcao,
          ),
        );

        comprimentoGeometricoAcumulado += comprimentoSegmento;
      }

      cadeiaAcumulada += comprimentoParaEstaca;
    }

    if (segmentos.isEmpty) {
      throw Exception('Não foi possível gerar os segmentos do eixo.');
    }

    final eixo = _EixoCarregado(
      nome: nomeEixo,
      estacaInicial: estacaInicial,
      segmentos: segmentos,
    );

    _cache[caminhoAsset] = eixo;

    return eixo;
  }

  List<_PontoUtm> _criarPontosDaGeometria({
    required XmlElement elemento,
    required _PontoUtm inicio,
    required _PontoUtm fim,
  }) {
    if (elemento.name.local != 'Curve') {
      return [inicio, fim];
    }

    final centro = _lerPonto(elemento, 'Center');
    final raio = _lerNumero(elemento.getAttribute('radius'));
    final rotacao = elemento.getAttribute('rot')?.toLowerCase();

    if (centro == null || raio <= 0 || rotacao == null) {
      return [inicio, fim];
    }

    final anguloInicial = atan2(
      inicio.y - centro.y,
      inicio.x - centro.x,
    );

    final anguloFinal = atan2(
      fim.y - centro.y,
      fim.x - centro.x,
    );

    double variacaoAngular = anguloFinal - anguloInicial;

    if (rotacao == 'cw') {
      while (variacaoAngular > 0) {
        variacaoAngular -= 2 * pi;
      }
    } else {
      while (variacaoAngular < 0) {
        variacaoAngular += 2 * pi;
      }
    }

    final comprimentoArco = raio * variacaoAngular.abs();

    final quantidadeDivisoes = max(
      4,
      (comprimentoArco / 5).ceil(),
    );

    final pontos = <_PontoUtm>[];

    for (var i = 0; i <= quantidadeDivisoes; i++) {
      final percentual = i / quantidadeDivisoes;

      final angulo =
          anguloInicial + (variacaoAngular * percentual);

      pontos.add(
        _PontoUtm(
          centro.x + (raio * cos(angulo)),
          centro.y + (raio * sin(angulo)),
        ),
      );
    }

    pontos[0] = inicio;
    pontos[pontos.length - 1] = fim;

    return pontos;
  }

  _PontoUtm? _lerPonto(XmlElement elemento, String nomePonto) {
    final elementos = elemento.findElements(nomePonto);

    if (elementos.isEmpty) {
      return null;
    }

    final valores = elementos.first.innerText
        .trim()
        .split(RegExp(r'\s+'));

    if (valores.length < 2) {
      return null;
    }

    final x = double.tryParse(
      valores[0].replaceAll(',', '.'),
    );

    final y = double.tryParse(
      valores[1].replaceAll(',', '.'),
    );

    if (x == null || y == null) {
      return null;
    }

    return _PontoUtm(x, y);
  }

  _ProjecaoMaisProxima _projetarNoSegmento({
    required _PontoUtm ponto,
    required _SegmentoEixo segmento,
  }) {
    final dx = segmento.fim.x - segmento.inicio.x;
    final dy = segmento.fim.y - segmento.inicio.y;

    final comprimentoQuadrado = (dx * dx) + (dy * dy);

    double t = 0;

    if (comprimentoQuadrado > 0) {
      t =
          (((ponto.x - segmento.inicio.x) * dx) +
              ((ponto.y - segmento.inicio.y) * dy)) /
          comprimentoQuadrado;

      t = t.clamp(0.0, 1.0).toDouble();
    }

    final pontoProjetado = _PontoUtm(
      segmento.inicio.x + (dx * t),
      segmento.inicio.y + (dy * t),
    );

    return _ProjecaoMaisProxima(
      segmento: segmento,
      pontoProjetado: pontoProjetado,
      distancia: _distancia(ponto, pontoProjetado),
      t: t,
    );
  }

  double _distancia(_PontoUtm pontoA, _PontoUtm pontoB) {
    final dx = pontoB.x - pontoA.x;
    final dy = pontoB.y - pontoA.y;

    return sqrt((dx * dx) + (dy * dy));
  }

  double _comprimentoDaPolilinha(List<_PontoUtm> pontos) {
    double comprimento = 0;

    for (var i = 0; i < pontos.length - 1; i++) {
      comprimento += _distancia(pontos[i], pontos[i + 1]);
    }

    return comprimento;
  }

  double _lerNumero(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 0;
    }

    return double.tryParse(
          valor.replaceAll(',', '.'),
        ) ??
        0;
  }

  String _formatarEstaca(double estacaNumerica) {
    final numeroEstaca = estacaNumerica.floor();

    double metros = (estacaNumerica - numeroEstaca) * 20;

    if (metros >= 19.9995) {
      return '${numeroEstaca + 1}+000.000';
    }

    if (metros < 0) {
      metros = 0;
    }

    return '$numeroEstaca+${metros.toStringAsFixed(3).padLeft(7, '0')}';
  }

  _PontoUtm _converterLatitudeLongitudeParaUtm23S({
    required double latitude,
    required double longitude,
  }) {
    const semiEixoMaior = 6378137.0;
    const achatamento = 1 / 298.257222101;
    const fatorEscala = 0.9996;
    const zonaUtm = 23;
    const falsoEste = 500000.0;
    const falsoNorteHemisferioSul = 10000000.0;

    final excentricidadeQuadrada =
        achatamento * (2 - achatamento);

    final excentricidadeSegunda =
        excentricidadeQuadrada / (1 - excentricidadeQuadrada);

    final latitudeRadianos = latitude * pi / 180;
    final longitudeRadianos = longitude * pi / 180;

    final longitudeMeridianoCentral =
        ((zonaUtm * 6) - 183) * pi / 180;

    final senoLatitude = sin(latitudeRadianos);
    final cossenoLatitude = cos(latitudeRadianos);
    final tangenteLatitude = tan(latitudeRadianos);

    final n = semiEixoMaior /
        sqrt(
          1 - (excentricidadeQuadrada * senoLatitude * senoLatitude),
        );

    final t = tangenteLatitude * tangenteLatitude;

    final c = excentricidadeSegunda *
        cossenoLatitude *
        cossenoLatitude;

    final a = cossenoLatitude *
        (longitudeRadianos - longitudeMeridianoCentral);

    final m = semiEixoMaior *
        ((1 -
                    excentricidadeQuadrada / 4 -
                    3 * pow(excentricidadeQuadrada, 2) / 64 -
                    5 * pow(excentricidadeQuadrada, 3) / 256) *
                latitudeRadianos -
            (3 * excentricidadeQuadrada / 8 +
                    3 * pow(excentricidadeQuadrada, 2) / 32 +
                    45 * pow(excentricidadeQuadrada, 3) / 1024) *
                sin(2 * latitudeRadianos) +
            (15 * pow(excentricidadeQuadrada, 2) / 256 +
                    45 * pow(excentricidadeQuadrada, 3) / 1024) *
                sin(4 * latitudeRadianos) -
            (35 * pow(excentricidadeQuadrada, 3) / 3072) *
                sin(6 * latitudeRadianos));

    final este = falsoEste +
        fatorEscala *
            n *
            (a +
                (1 - t + c) * pow(a, 3) / 6 +
                (5 -
                            18 * t +
                            (t * t) +
                            72 * c -
                            58 * excentricidadeSegunda) *
                        pow(a, 5) /
                        120);

    double norte = fatorEscala *
        (m +
            n *
                tangenteLatitude *
                (pow(a, 2) / 2 +
                    (5 - t + 9 * c + 4 * c * c) *
                        pow(a, 4) /
                        24 +
                    (61 -
                            58 * t +
                            (t * t) +
                            600 * c -
                            330 * excentricidadeSegunda) *
                        pow(a, 6) /
                        720));

    if (latitude < 0) {
      norte += falsoNorteHemisferioSul;
    }

    return _PontoUtm(este, norte);
  }
}

class _EixoCarregado {
  final String nome;
  final double estacaInicial;
  final List<_SegmentoEixo> segmentos;

  const _EixoCarregado({
    required this.nome,
    required this.estacaInicial,
    required this.segmentos,
  });
}

class _SegmentoEixo {
  final _PontoUtm inicio;
  final _PontoUtm fim;
  final double cadeiaInicial;
  final double comprimentoCadeia;

  const _SegmentoEixo({
    required this.inicio,
    required this.fim,
    required this.cadeiaInicial,
    required this.comprimentoCadeia,
  });
}

class _PontoUtm {
  final double x;
  final double y;

  const _PontoUtm(this.x, this.y);
}

class _ProjecaoMaisProxima {
  final _SegmentoEixo segmento;
  final _PontoUtm pontoProjetado;
  final double distancia;
  final double t;

  const _ProjecaoMaisProxima({
    required this.segmento,
    required this.pontoProjetado,
    required this.distancia,
    required this.t,
  });
}

extension PrimeiroOuNulo<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;

    if (!iterator.moveNext()) {
      return null;
    }

    return iterator.current;
  }
}