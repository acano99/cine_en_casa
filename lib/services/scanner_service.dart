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
            final name = entity.uri.pathSegments
                .where((segment) => segment.isNotEmpty)
                .last;

            // Filtramos carpetas ocultas y archivos especiales con r'$'
            if (!name.startsWith('.') && !name.startsWith(r'$')) {
              uniqueFolders.add(name);
            }
          }
        }
      }
    }

    final sortedList = uniqueFolders.toList();
    sortedList.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return sortedList;
  }
}
