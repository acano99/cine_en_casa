import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/catalog_cubit.dart';
import 'views/catalog_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CineEnCasaApp());
}

class CineEnCasaApp extends StatelessWidget {
  const CineEnCasaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cine en Casa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      home: BlocProvider(
        create: (context) => CatalogCubit(),
        child: const CatalogView(),
      ),
    );
  }
}
