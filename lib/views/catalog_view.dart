import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';
import '../cubit/catalog_cubit.dart';
import '../cubit/catalog_state.dart';

class CatalogView extends StatefulWidget {
  const CatalogView({super.key});

  @override
  State<CatalogView> createState() => _CatalogViewState();
}

class _CatalogViewState extends State<CatalogView> {
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cine en Casa - Generador de Catálogo'),
        centerTitle: true,
      ),
      body: BlocConsumer<CatalogCubit, CatalogState>(
        listener: (context, state) {
          if (state.status == CatalogStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red.shade700,
              ),
            );
          } else if (state.status == CatalogStatus.success && state.pdfBytes != null) {
            Printing.layoutPdf(
              onLayout: (_) => state.pdfBytes!,
              name: 'Catalogo_${state.title}.pdf',
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<CatalogCubit>();
          final isLoading = state.status == CatalogStatus.loading;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 750),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Campo obligatorio de título
                    const Text(
                      '1. Nombre del Catálogo *',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      enabled: !isLoading,
                      decoration: const InputDecoration(
                        hintText: 'Ej. Animes, Series Retro, Películas 4K...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      onChanged: cubit.setTitle,
                    ),
                    const SizedBox(height: 24),

                    // Encabezado de directorios y botón agregar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '2. Directorio(s) a escanear *',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        TextButton.icon(
                          onPressed: isLoading ? null : cubit.addDirectorySlot,
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar otro directorio'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Lista dinámica de selectores
                    ...List.generate(state.directories.length, (index) {
                      final path = state.directories[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(4),
                                  color: Colors.grey.shade50,
                                ),
                                child: Text(
                                  path.isEmpty ? 'Ninguna carpeta seleccionada...' : path,
                                  style: TextStyle(
                                    color: path.isEmpty ? Colors.grey.shade600 : Colors.black87,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filledTonal(
                              tooltip: 'Seleccionar carpeta',
                              onPressed: isLoading ? null : () => cubit.pickDirectory(index),
                              icon: const Icon(Icons.folder_open),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              tooltip: 'Quitar ruta',
                              onPressed: isLoading ? null : () => cubit.removeDirectorySlot(index),
                              icon: const Icon(Icons.delete_outline),
                              color: Colors.red.shade400,
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 32),

                    // Botón para procesar
                    SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: isLoading ? null : cubit.generateCatalog,
                        icon: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.picture_as_pdf),
                        label: Text(
                          isLoading ? 'Escaneando y armando PDF...' : 'Generar Catálogo PDF',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
