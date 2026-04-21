import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BottomAppBar Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 2; // TAB: 3 (índice 2)
  bool _fabMenuExpanded = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showFabOptions() {
    setState(() {
      _fabMenuExpanded = !_fabMenuExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BottomAppBar with FAB'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'TAB: ${_selectedIndex + 1}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            const Text(
              'This\nIs\nA\nBottom\nBar',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 40),
            // Ícones enfileirados na vertical
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.call,
                  size: 50,
                  color: Colors.blue,
                ),
                SizedBox(height: 20),
                Icon(
                  Icons.message,
                  size: 50,
                  color: Colors.blue,
                ),
                SizedBox(height: 20),
                Icon(
                  Icons.email,
                  size: 50,
                  color: Colors.blue,
                ),
              ],
            ),
            if (_fabMenuExpanded) ...[
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  children: [
                    Text(
                      'Opções do FAB:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text('• Adicionar Item'),
                    Text('• Remover Item'),
                    Text('• Editar Item'),
                    Text('• Compartilhar'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () => _onItemTapped(1),
            ),
            const SizedBox(width: 40), // Espaço para o FAB
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.white),
              onPressed: () => _onItemTapped(3),
            ),
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: () => _onItemTapped(4),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _showFabOptions,
        child: Icon(_fabMenuExpanded ? Icons.close : Icons.add),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4.0,
      ),
    );
  }
}