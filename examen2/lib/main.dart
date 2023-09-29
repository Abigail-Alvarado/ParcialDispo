// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

var checked_ = false;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ttgxcxwzmjhihsbtbrnh.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR0Z3hjeHd6bWpoaWhzYnRicm5oIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTYwMDYxMzgsImV4cCI6MjAxMTU4MjEzOH0.HAAoKZ5tODz_anlg_xtbWCYZFhZF0o1Gq4gAz1pZIhk', //SUPABASE_ANON_KEY,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
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
  final _tareasStream =
      Supabase.instance.client.from('tareas').stream(primaryKey: ['id']);
  var newTask, newDescription;
  TextEditingController _taskController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tareas'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _tareasStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final tareas = snapshot.data!;

          return ListView.builder(
            itemCount: tareas.length,
            itemBuilder: (context, index) {
              return Container(
                height: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 50,
                      child: CheckboxExample(),
                    ),
                    Container(
                      width: 100,
                      child: Text(tareas[index]['titulo']),
                    ),
                    Container(
                      width: 100,
                      child: Text(tareas[index]['descripcion']),
                    ),
                    IconButton(
                        onPressed: () {
                          _taskController.text = tareas[index]['titulo'];
                          _descriptionController.text =
                              tareas[index]['descripcion'];
                          newTask = tareas[index]['titulo'];
                          newDescription = tareas[index]['descripcion'];
                          showDialog(
                            context: context,
                            builder: ((context) {
                              return SimpleDialog(
                                title: const Text('Add task'),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                children: [
                                  TextFormField(
                                    controller: _taskController,
                                    decoration: InputDecoration(
                                      labelText: 'titulo',
                                    ),
                                    onChanged: (value) async {
                                      newTask = value;
                                    },
                                  ),
                                  TextFormField(
                                    controller: _descriptionController,
                                    decoration: InputDecoration(
                                      labelText: 'descripcion',
                                    ),
                                    onChanged: (value) async {
                                      newDescription = value;
                                    },
                                  ),
                                  FloatingActionButton(
                                    onPressed: () {
                                      var response = Supabase.instance.client
                                          .from('tareas')
                                          .update({
                                            'titulo': newTask,
                                            'descripcion': newDescription,
                                            'estado': checked_
                                          })
                                          .eq('id', tareas[index]['id'])
                                          .execute();
                                      setState(() {});
                                    },
                                    child: Icon(Icons.done),
                                  ),
                                ],
                              );
                            }),
                          );
                          setState(() {});
                        },
                        icon: Icon(Icons.update)),
                    IconButton(
                        onPressed: () {
                          var response = Supabase.instance.client
                              .from('tareas')
                              .delete()
                              .eq('id', tareas[index]['id'])
                              .execute();
                          print(response);
                          setState(() {});
                        },
                        icon: Icon(Icons.delete)),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: ((context) {
              return SimpleDialog(
                title: const Text('Add a client'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Tarea',
                    ),
                    onChanged: (value) async {
                      newTask = value;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Descripcion',
                    ),
                    onChanged: (value) async {
                      newDescription = value;
                    },
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      addData(newTask, newDescription);
                      setState(() {});
                    },
                    child: Icon(Icons.add),
                  ),
                ],
              );
            }),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  addData(String titulo, String descripcion) {
    print(titulo);
    var response = Supabase.instance.client.from('tareas').insert({
      'titulo': titulo,
      'descripcion': descripcion,
    }).execute();
    print(response);
  }

  readData() async {
    var response = await Supabase.instance.client
        .from('tareas')
        .select()
        .order('id', ascending: true)
        .execute();
    print(response);
    final dataList = response.data as List;
    return dataList;
  }
}

class CheckboxExample extends StatefulWidget {
  const CheckboxExample({super.key});

  @override
  State<CheckboxExample> createState() => _CheckboxExampleState();
}

class _CheckboxExampleState extends State<CheckboxExample> {
  bool isChecked = checked_;
  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }

    return Checkbox(
      checkColor: Colors.white,
      value: isChecked,
      onChanged: (value) {
        setState(() {
          isChecked = value!;
          checked_ = isChecked!;
          print({'checked: ', checked_});
        });
      },
    );
  }
}
