import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ConferenciaStorageService {
  static const String _chaveConferencias = 'conferencias_salvas';

  Future<List<Map<String, dynamic>>> carregarConferencias() async {
    final preferencias = await SharedPreferences.getInstance();
    final dadosSalvos = preferencias.getString(_chaveConferencias);

    if (dadosSalvos == null || dadosSalvos.isEmpty) {
      return [];
    }

    try {
      final lista = jsonDecode(dadosSalvos) as List<dynamic>;

      return lista
          .whereType<Map>()
          .map(
            (item) => Map<String, dynamic>.from(item),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> salvarConferencias(
    List<Map<String, dynamic>> conferencias,
  ) async {
    final preferencias = await SharedPreferences.getInstance();

    await preferencias.setString(
      _chaveConferencias,
      jsonEncode(conferencias),
    );
  }

  Future<void> adicionarConferencia(
    Map<String, dynamic> conferencia,
  ) async {
    final conferencias = await carregarConferencias();

    conferencias.insert(0, conferencia);

    await salvarConferencias(conferencias);
  }

  Future<void> atualizarConferencia(
    Map<String, dynamic> conferencia,
  ) async {
    final id = conferencia['id']?.toString();

    if (id == null || id.isEmpty) {
      return;
    }

    final conferencias = await carregarConferencias();

    final indice = conferencias.indexWhere(
      (item) => item['id']?.toString() == id,
    );

    if (indice == -1) {
      conferencias.insert(0, conferencia);
    } else {
      conferencias[indice] = conferencia;
    }

    await salvarConferencias(conferencias);
  }

  Future<void> removerConferencia(String id) async {
    final conferencias = await carregarConferencias();

    conferencias.removeWhere(
      (item) => item['id']?.toString() == id,
    );

    await salvarConferencias(conferencias);
  }

  Future<void> limparConferencias() async {
    final preferencias = await SharedPreferences.getInstance();

    await preferencias.remove(_chaveConferencias);
  }
}