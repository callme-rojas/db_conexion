import 'package:flutter/material.dart';
import 'task.dart';
import 'database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TaskListScreen(),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> tasks = [];
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _editTaskController = TextEditingController();
  int? _selectedTaskId;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  _loadTasks() async {
    List<Task> loadedTasks = await DatabaseHelper.instance.getTasks();
    setState(() {
      tasks = loadedTasks;
    });

    _printDatabaseInfo();
  }

  _addTask() async {
    String taskTitle = _taskController.text;
    if (taskTitle.isNotEmpty) {
      Task newTask = Task(title: taskTitle, isDone: false, id: null);
      await DatabaseHelper.instance.insertTask(newTask);
      _taskController.clear();
      _loadTasks();
      _printDatabaseInfo();
    }
  }

  _toggleTaskState(int index) async {
    Task updatedTask = tasks[index];
    updatedTask.isDone = !updatedTask.isDone;

    await DatabaseHelper.instance.updateTask(updatedTask);
    _loadTasks();
    _printDatabaseInfo();
  }

  _deleteTask(int index) async {
    if (tasks[index].id != null) {
      await DatabaseHelper.instance.deleteTask(tasks[index].id!);
      _loadTasks();
      _printDatabaseInfo();
    }
  }

  _editTask(int index) {
    _selectedTaskId = tasks[index].id;
    _editTaskController.text = tasks[index].title;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Task'),
          content: TextField(
            controller: _editTaskController,
            decoration: InputDecoration(
              hintText: 'Edit task',
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: _buildGradientButton('Cancel', () {
                Navigator.of(context).pop();
              }),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateTask();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: _buildGradientButton('Update', () {
                _updateTask();
              }),
            ),
          ],
        );
      },
    );
  }

  _updateTask() async {
    String updatedTaskTitle = _editTaskController.text;
    if (updatedTaskTitle.isNotEmpty && _selectedTaskId != null) {
      Task updatedTask = Task(id: _selectedTaskId!, title: updatedTaskTitle, isDone: false);
      await DatabaseHelper.instance.updateTask(updatedTask);
      _loadTasks();
      _selectedTaskId = null;
      _printDatabaseInfo();
    }
  }

  Widget _buildGradientButton(String text, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red,
            Colors.orange,
            Colors.yellow,
            Colors.green,
            Colors.blue,
            Colors.indigo,
            Colors.purple,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }

  _printDatabaseInfo() async {
    List<Task> allTasks = await DatabaseHelper.instance.getTasks();
    print("Database Info:");
    allTasks.forEach((task) {
      print('Task: ${task.id}, ${task.title}, ${task.isDone}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task List'),

      ),
      body: Column(
        children: [
          TextField(
            controller: _taskController,
            decoration: InputDecoration(
              hintText: 'Enter a task',
              contentPadding: EdgeInsets.all(16.0),
            ),
          ),
          ElevatedButton(
            onPressed: _addTask,
            style: ElevatedButton.styleFrom(
              primary: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            child: _buildGradientButton('Add Task', () {
              _addTask();
            }),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(tasks[index].title),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _editTask(index);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteTask(index);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    _toggleTaskState(index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
