import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task App',
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
  // Lista de tarefas
  List<Task> _tasks = [];
  
  // Controle de checkboxes
  List<bool> _completed = [];

  @override
  void initState() {
    super.initState();
    // Adicionando tarefas de exemplo
    _tasks = [
      Task('Task 2022-07-09 18:08:31.734244', false),
      Task('Task 2022-07-09 18:08:32.210300', false),
      Task('Task 2022-07-09 18:08:32.629026', false),
      Task('Task 2022-07-09 18:08:33.073472', false),
      Task('Task 2022-07-09 18:08:33.524172', false),
    ];
    _completed = List<bool>.filled(_tasks.length, false);
  }

  int get _uncompletedTasksCount {
    return _completed.where((isCompleted) => !isCompleted).length;
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      _completed[index] = !_completed[index];
      _tasks[index].isCompleted = _completed[index];
    });
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sobre o App'),
          content: const Text('Você está no App de Notas de Tarefas'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _viewCompletedTasks() {
    setState(() {});
    // Mostrar snackbar com quantidade de tarefas concluídas
    int completedCount = _completed.where((c) => c).length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Você completou $completedCount tarefa(s)'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kindacode.com'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Botão "View Completed Tasks"
            ElevatedButton(
              onPressed: _viewCompletedTasks,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'View Completed Tasks',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            
            // Texto com quantidade de tarefas não concluídas
            Text(
              'You have $_uncompletedTasksCount uncompleted tasks',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            
            // ListView com as tarefas
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 2,
                    child: ListTile(
                      leading: Checkbox(
                        value: _completed[index],
                        onChanged: (bool? value) {
                          _toggleTaskCompletion(index);
                        },
                        activeColor: Colors.blue,
                      ),
                      title: Text(
                        _tasks[index].title,
                        style: TextStyle(
                          fontSize: 14,
                          decoration: _completed[index] 
                              ? TextDecoration.lineThrough 
                              : null,
                          color: _completed[index] 
                              ? Colors.grey 
                              : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAboutDialog,
        child: const Icon(Icons.info),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }
}

// Classe Task para representar cada tarefa
class Task {
  String title;
  bool isCompleted;

  Task(this.title, this.isCompleted);
}