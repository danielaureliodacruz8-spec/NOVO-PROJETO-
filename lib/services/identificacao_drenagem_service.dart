import 'dart:math' as math;

import '../models/drenagem_model.dart';

enum StatusIdentificacaoDrenagem {
  localizada,
  foraDoRaio,
  semBaseDeLocacao,
}

class PontoDrenagemObra {
  final String id;
  final String dispositivoId;
  final double latitude;
  final double longitude;
  final String estaca;
  final String lado;
  final double? estacaMetros;
  final String? observacao;

  const PontoDrenagemObra({
    required this.id,
    required this.dispositivoId,
    required this.latitude,
    required this.longitude,
    required this.estaca,
    required this.lado,
    this.estacaMetros,
    this.observacao,
  });
}

class ResultadoIdentificacaoDrenagem {
  final StatusIdentificacaoDrenagem status;
  final DrenagemModel? drenagem;
  final PontoDrenagemObra? ponto;
  final double? distanciaMetros;
  final String mensagem;

  const ResultadoIdentificacaoDrenagem({
    required this.status,
    required this.mensagem,
    this.drenagem,
    this.ponto,
    this.distanciaMetros,
  });

  bool get localizada =>
      status == StatusIdentificacaoDrenagem.localizada &&
      drenagem != null &&
      ponto != null;
}

class IdentificacaoDrenagemService {
  static const double raioPadraoMetros = 40;

  const IdentificacaoDrenagemService();

  ResultadoIdentificacaoDrenagem localizarDrenagemMaisProxima({
    required double latitudeAtual,
    required double longitudeAtual,
    double raioBuscaMetros = raioPadraoMetros,
  }) {
    if (BaseLocacaoDrenagemGo236.pontosDrenagem.isEmpty) {
      return const ResultadoIdentificacaoDrenagem(
        status: StatusIdentificacaoDrenagem.semBaseDeLocacao,
        mensagem:
            'A base de locação das drenagens ainda não foi cadastrada. '
            'Importe as coordenadas, estacas ou o KML/DWG da obra.',
      );
    }

    PontoDrenagemObra? pontoMaisProximo;
    double? menorDistancia;

    for (final ponto in BaseLocacaoDrenagemGo236.pontosDrenagem) {
      final distancia = calcularDistanciaMetros(
        latitude1: latitudeAtual,
        longitude1: longitudeAtual,
        latitude2: ponto.latitude,
        longitude2: ponto.longitude,
      );

      if (menorDistancia == null || distancia < menorDistancia) {
        menorDistancia = distancia;
        pontoMaisProximo = ponto;
      }
    }

    if (pontoMaisProximo == null || menorDistancia == null) {
      return const ResultadoIdentificacaoDrenagem(
        status: StatusIdentificacaoDrenagem.semBaseDeLocacao,
        mensagem: 'Nenhuma drenagem foi cadastrada na base de locação.',
      );
    }

    if (menorDistancia > raioBuscaMetros) {
      return ResultadoIdentificacaoDrenagem(
        status: StatusIdentificacaoDrenagem.foraDoRaio,
        distanciaMetros: menorDistancia,
        mensagem:
            'Nenhuma drenagem localizada no raio de '
            '${raioBuscaMetros.toStringAsFixed(0)} m. '
            'A drenagem cadastrada mais próxima está a '
            '${menorDistancia.toStringAsFixed(1)} m.',
      );
    }

    DrenagemModel? drenagem;

    for (final item in CatalogoDrenagemSuperficial.dispositivos) {
      if (item.id == pontoMaisProximo.dispositivoId) {
        drenagem = item;
        break;
      }
    }

    if (drenagem == null) {
      return ResultadoIdentificacaoDrenagem(
        status: StatusIdentificacaoDrenagem.semBaseDeLocacao,
        ponto: pontoMaisProximo,
        distanciaMetros: menorDistancia,
        mensagem:
            'O ponto ${pontoMaisProximo.id} foi encontrado, mas o dispositivo '
            '${pontoMaisProximo.dispositivoId} não existe no catálogo.',
      );
    }

    return ResultadoIdentificacaoDrenagem(
      status: StatusIdentificacaoDrenagem.localizada,
      drenagem: drenagem,
      ponto: pontoMaisProximo,
      distanciaMetros: menorDistancia,
      mensagem:
          '${drenagem.codigo} localizado automaticamente a '
          '${menorDistancia.toStringAsFixed(1)} m.',
    );
  }

  DrenagemModel? buscarDispositivoPorCodigo(String codigo) {
    final codigoNormalizado = codigo.trim().toUpperCase();

    for (final drenagem in CatalogoDrenagemSuperficial.dispositivos) {
      if (drenagem.codigo.toUpperCase() == codigoNormalizado) {
        return drenagem;
      }
    }

    return null;
  }

  static double calcularDistanciaMetros({
    required double latitude1,
    required double longitude1,
    required double latitude2,
    required double longitude2,
  }) {
    const raioTerraMetros = 6371000.0;

    final dLatitude = _grausParaRadianos(latitude2 - latitude1);
    final dLongitude = _grausParaRadianos(longitude2 - longitude1);

    final a =
        math.sin(dLatitude / 2) * math.sin(dLatitude / 2) +
        math.cos(_grausParaRadianos(latitude1)) *
            math.cos(_grausParaRadianos(latitude2)) *
            math.sin(dLongitude / 2) *
            math.sin(dLongitude / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return raioTerraMetros * c;
  }

  static double _grausParaRadianos(double graus) {
    return graus * math.pi / 180;
  }
}

class BaseLocacaoDrenagemGo236 {
  static const List<PontoDrenagemObra> pontosDrenagem = [
    /*
    PontoDrenagemObra(
      id: 'go236-stc-001',
      dispositivoId: 'stc-100-20',
      latitude: -14.123456,
      longitude: -46.123456,
      estaca: '320+15',
      lado: 'LD',
      estacaMetros: 32015,
      observacao: 'Sarjeta localizada no bordo direito da rodovia.',
    ),
    */
  ];
}