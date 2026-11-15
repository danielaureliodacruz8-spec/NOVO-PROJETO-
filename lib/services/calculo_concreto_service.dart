class CalculoConcretoService {
  /// Calcula o volume de uma laje maciça retangular.
  ///
  /// largura, comprimento e espessura devem estar em metros.
  /// O resultado é apresentado em m³.
  static double? calcularTss({
    required double largura,
    required double comprimento,
    required double espessura,
  }) {
    if (!_medidaValida(largura) ||
        !_medidaValida(comprimento) ||
        !_medidaValida(espessura)) {
      return null;
    }

    final volume = largura * comprimento * espessura;

    if (!volume.isFinite || volume <= 0) {
      return null;
    }

    return volume;
  }

  static bool _medidaValida(double medida) {
    return medida.isFinite && medida > 0;
  }

  static String formatarVolume(double? volume) {
    if (volume == null) {
      return 'Medidas insuficientes';
    }

    return '${volume.toStringAsFixed(3)} m³';
  }
}