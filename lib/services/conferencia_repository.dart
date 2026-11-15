import '../models/conferencia_registro_model.dart';
import 'conferencia_storage_service.dart';

class ConferenciaRepository {
  final ConferenciaStorageService _storageService =
      ConferenciaStorageService();

  Future<List<ConferenciaRegistroModel>> carregar() async {
    final mapas = await _storageService.carregarConferencias();

    return mapas
        .map(ConferenciaRegistroModel.fromMap)
        .toList()
      ..sort(
        (a, b) => b.dataHora.compareTo(a.dataHora),
      );
  }

  Future<void> adicionar(ConferenciaRegistroModel conferencia) async {
    await _storageService.adicionarConferencia(conferencia.toMap());
  }

  Future<void> atualizar(ConferenciaRegistroModel conferencia) async {
    await _storageService.atualizarConferencia(conferencia.toMap());
  }

  Future<void> remover(String id) async {
    await _storageService.removerConferencia(id);
  }

  Future<void> limpar() async {
    await _storageService.limparConferencias();
  }
}