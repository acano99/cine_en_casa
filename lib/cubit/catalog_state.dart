import 'dart:typed_data';

enum CatalogStatus { initial, loading, success, error }

class CatalogState {
  final String title;
  final List<String> directories;
  final CatalogStatus status;
  final Uint8List? pdfBytes;
  final String? errorMessage;

  const CatalogState({
    this.title = '',
    this.directories = const [''],
    this.status = CatalogStatus.initial,
    this.pdfBytes,
    this.errorMessage,
  });

  CatalogState copyWith({
    String? title,
    List<String>? directories,
    CatalogStatus? status,
    Uint8List? pdfBytes,
    String? errorMessage,
  }) {
    return CatalogState(
      title: title ?? this.title,
      directories: directories ?? this.directories,
      status: status ?? this.status,
      pdfBytes: pdfBytes ?? this.pdfBytes,
      errorMessage: errorMessage,
    );
  }
}
