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

  double? _celsiu;
  double? _farenheight;

  final TextEditingController _celsiuController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getDados();
  }

  Future<void> _getDados() async {
    final event = await _database.child('produto').once();
    final data = event.snapshot.value as Map<dynamic, dynamic>?;

    setState(() {
      _celsiu =
          data?['celsiu'] != null
              ? double.tryParse(data?['celsiu'].toString() ?? '0')
              : null;
      _farenheight =
          data?['farenheight'] != null
              ? double.tryParse(data?['farenheight'].toString() ?? '0')
              : null;
    });
  }

  // Função para calcular e atualizar os dados no Firebase
  Future<void> _calcular() async {
    if (_celsiuController.text.isNotEmpty) {
      double celsius = double.tryParse(_celsiuController.text) ?? 0.0;
      double fahrenheit = (celsius * 9 / 5) + 32;

      await _database.child('produto').set({
        'celsiu': celsius,
        'farenheight': fahrenheit,
      });

      _getDados();
      _celsiuController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Conversor Celsius para Fahrenheit")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _celsiu == null || _farenheight == null
                  ? const CircularProgressIndicator()
                  : Column(
                    children: [
                      const Text(
                        "ultima conversão:",
                        style: TextStyle(fontSize: 16),
                      ),
                      Text("Celsius: $_celsiu"),
                      Text("Fahrenheit: $_farenheight"),
                    ],
                  ),
              const SizedBox(height: 20),
              TextField(
                controller: _celsiuController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Celsius",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _calcular,
                child: const Text("Calcular"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
