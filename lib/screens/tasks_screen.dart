import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/utiles/database_helper.dart';

import 'add_task_screen.dart';

class TasksScreen extends StatefulWidget {
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');
  List<Task> taskList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (taskList == null) {
      taskList = List<Task>();
      updateTaskList();
    }
    return Scaffold(
      backgroundColor: Colors.indigo,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToAddTaskScreen(null);
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          Icons.add,
          size: 30.0,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
                top: 60.0, left: 30.0, right: 30.0, bottom: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Image.asset(
                    'images/todo.png',
                  ),
                  height: 80.0,
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  "What's NEXT ?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 50.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '$count Tasks',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: ListView.builder(
                itemCount: count,
                itemBuilder: (context, index) {
                  final task = taskList[index];
                  return Column(
                    children: [
                      ListTile(
                        onLongPress: () {
                          _delete(task);
                        },
                        title: Text(
                          task.title,
                          style: TextStyle(
                              decoration: task.status == 1
                                  ? TextDecoration.lineThrough
                                  : null),
                        ),
                        subtitle: Text(
                          '${_dateFormatter.format(task.date)} . ${task.priority}',
                          style: TextStyle(
                            fontSize: 15.0,
                            decoration: task.status == 1
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        trailing: Checkbox(
                          activeColor: Theme.of(context).primaryColor,
                          value: task.status == 1 ? true : false,
                          onChanged: (value) async {
                            task.status = value ? 1 : 0;
                            await databaseHelper.updateTask(task);
                            updateTaskList();
                          },
                        ),
                        onTap: () {
                          navigateToAddTaskScreen(task);
                        },
                      ),
                      Divider(),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _delete(Task task) async {
    int result = await databaseHelper.deleteTask(task.id);
    if (result != 0) {
      updateTaskList();
    }
  }

  void navigateToAddTaskScreen(Task task) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddTaskScreen(
        task: task,
      );
    }));

    if (result == true) {
      updateTaskList();
    }
  }

  void updateTaskList() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Task>> noteListFuture = databaseHelper.getTaskList();
      noteListFuture.then((taskList) {
        setState(() {
          this.taskList = taskList;
          this.count = taskList.length;
        });
      });
    });
  }
}
