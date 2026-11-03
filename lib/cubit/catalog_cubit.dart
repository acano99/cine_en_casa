import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../services/scanner_service.dart';
import '../services/pdf_service.dart';
import 'catalog_state.dart';

class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit() : super(const CatalogState());

  void setTitle(String value) {
    emit(state.copyWith(title: value));
  }

  void addDirectorySlot() {
    final updated = List<String>.from(state.directories)..add('');
    emit(state.copyWith(directories: updated));
  }

  void removeDirectorySlot(int index) {
    if (state.directories.length <= 1) {
      emit(state.copyWith(directories: ['']));
      return;
    }
    final updated = List<String>.from(state.directories)..removeAt(index);
    emit(state.copyWith(directories: updated));
  }

  void updateDirectoryPath(int index, String path) {
    final updated = List<String>.from(state.directories);
    if (index >= 0 && index < updated.length) {
      updated[index] = path;
      emit(state.copyWith(directories: updated));
    }
  }

  Future<void> pickDirectory(int index) async {
    // Uso directo de la API moderna de file_picker
    final selectedPath = await FilePicker.getDirectoryPath(
      dialogTitle: 'Selecciona una carpeta para el catálogo',
    );

    if (selectedPath != null) {
      updateDirectoryPath(index, selectedPath);
    }
  }

  Future<void> generateCatalog() async {
    final trimmedTitle = state.title.trim();
    if (trimmedTitle.isEmpty) {
      emit(state.copyWith(
        status: CatalogStatus.error,
        errorMessage: 'El nombre del catálogo es obligatorio.',
      ));
      return;
    }

    final validPaths = state.directories
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    if (validPaths.isEmpty) {
      emit(state.copyWith(
        status: CatalogStatus.error,
        errorMessage: 'Debes seleccionar al menos un directorio.',
      ));
      return;
    }

    emit(state.copyWith(status: CatalogStatus.loading));

    try {
      final items = await ScannerService.scanDirectories(validPaths);

      if (items.isEmpty) {
        emit(state.copyWith(
          status: CatalogStatus.error,
          errorMessage: 'No se encontraron subcarpetas en las rutas seleccionadas.',
        ));
        return;
      }

      final pdfBytes = await PdfService.generateCatalog(
        title: trimmedTitle,
        items: items,
      );

      emit(state.copyWith(
        status: CatalogStatus.success,
        pdfBytes: pdfBytes,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CatalogStatus.error,
        errorMessage: 'Ocurrió un error inesperado: $e',
      ));
    }
  }
}
