import 'dart:io';

class ScannerService {
  /// Escanea una lista de directorios, extrae las subcarpetas inmediatas,
  /// elimina duplicados y las devuelve ordenadas de A a Z.
  static Future<List<String>> scanDirectories(List<String> directoryPaths) async {
    final Set<String> uniqueFolders = {};

    for (final path in directoryPaths) {
      if (path.trim().isEmpty) continue;

      final dir = Directory(path);
      if (await dir.exists()) {
        await for (final entity in dir.list(recursive: false, followLinks: false)) {
          if (entity is Directory) {
            // Obtenemos solo el nombre de la carpeta (sin toda la ruta)
            final name = entity.uri.pathSegments
                .where((segment) => segment.isNotEmpty)
                .last;

            // Filtramos carpetas ocultas y archivos especiales de Windows/Linux
            if (!name.startsWith('.') && !name.startsWith('$')) {
              uniqueFolders.add(name);
            }
          }
        }
      }
    }

    final sortedList = uniqueFolders.toList();
    // Orden alfabético insensible a mayúsculas
    sortedList.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return sortedList;
  }
}
