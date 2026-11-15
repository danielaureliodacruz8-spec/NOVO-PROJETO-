import 'package:geolocator/geolocator.dart';

class DadosLocalizacao {
  final double latitude;
  final double longitude;
  final double precisao;
  final double altitude;
  final double velocidade;
  final DateTime dataHora;

  const DadosLocalizacao({
    required this.latitude,
    required this.longitude,
    required this.precisao,
    required this.altitude,
    required this.velocidade,
    required this.dataHora,
  });

  String get coordenadasFormatadas {
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  String get precisaoFormatada {
    return '${precisao.toStringAsFixed(1)} m';
  }
}

class LocalizacaoService {
  Future<DadosLocalizacao> obterLocalizacaoAtual() async {
    final servicoAtivo = await Geolocator.isLocationServiceEnabled();

    if (!servicoAtivo) {
      throw Exception(
        'O GPS está desativado. Ative a localização do celular e tente novamente.',
      );
    }

    var permissao = await Geolocator.checkPermission();

    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }

    if (permissao == LocationPermission.denied) {
      throw Exception('A permissão de localização foi negada.');
    }

    if (permissao == LocationPermission.deniedForever) {
      throw Exception(
        'A permissão de localização foi bloqueada. Libere a permissão nas configurações do celular.',
      );
    }

    final posicao = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
      ),
    );

    return DadosLocalizacao(
      latitude: posicao.latitude,
      longitude: posicao.longitude,
      precisao: posicao.accuracy,
      altitude: posicao.altitude,
      velocidade: posicao.speed,
      dataHora: posicao.timestamp ?? DateTime.now(),
    );
  }

  Future<bool> servicoGpsAtivo() async {
    return Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> verificarPermissao() async {
    return Geolocator.checkPermission();
  }

  Future<void> abrirConfiguracoesLocalizacao() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> abrirConfiguracoesDoApp() async {
    await Geolocator.openAppSettings();
  }
}