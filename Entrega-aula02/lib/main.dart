import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyChZBz9ps-1m6W45FkZIQkZZQl6iHVwsio",
      appId: "1:439552223184:android:93fa6e3110199df86bbbd5",
      messagingSenderId: "439552223184",
      projectId: "flutter-32cc3",
      databaseURL: "https://flutter-32cc3-default-rtdb.firebaseio.com/",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  String? _codigo;
  String? _descricao;
  double? _valor;

  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getDados();
  }

  // Função para pegar os dados do Firebase
  Future<void> _getDados() async {
    final event = await _database.child('produto').once();
    final data = event.snapshot.value as Map<dynamic, dynamic>?;

    setState(() {
      _codigo = data?['codigo']?.toString();
      _descricao = data?['descricao']?.toString();
      _valor =
          data?['valor'] != null
              ? double.tryParse(data?['valor'].toString() ?? '0')
              : null;
    });
  }

  // Função para atualizar os dados no Firebase
  Future<void> _atualizarDados() async {
    if (_codigoController.text.isNotEmpty &&
        _descricaoController.text.isNotEmpty &&
        _valorController.text.isNotEmpty) {
      await _database.child('produto').set({
        'codigo': _codigoController.text,
        'descricao': _descricaoController.text,
        'valor': double.tryParse(_valorController.text) ?? 0.0,
      });

      _getDados();
      _codigoController.clear();
      _descricaoController.clear();
      _valorController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Produto no Firebase")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _codigo == null || _descricao == null || _valor == null
                  ? const CircularProgressIndicator()
                  : Column(
                    children: [
                      Text("Código: $_codigo"),
                      Text("Descrição: $_descricao"),
                      Text("Valor: $_valor"),
                    ],
                  ),
              const SizedBox(height: 20),
              TextField(
                controller: _codigoController,
                decoration: const InputDecoration(
                  labelText: "Código",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: "Descrição",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _valorController,
                decoration: const InputDecoration(
                  labelText: "Valor",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _atualizarDados,
                child: const Text("Atualizar Dados"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
