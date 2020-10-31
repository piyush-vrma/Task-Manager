import 'dart:io';
import 'package:task_manager/models/task.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;
  DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper
          ._createInstance(); // This is executed only once, singleton object
    }
    return _databaseHelper;
  }

  String tasksTable = 'task_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDate = 'date';
  String colPriority = 'priority';
  String colStatus = 'status';

  // Task_Table
  // id  title  date  priority  status
  //  0   ''     ''     ''        0
  //  1   ''     ''     ''        0
  //  2   ''     ''     ''        0

  // creating database

  // Making a getter for the database //

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    // get the directory path for both android and ios to store database
    Directory directory = await getApplicationDocumentsDirectory();

    // open/create the database at a given path
    String path = directory.path + 'tasks.db';
    var taskDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return taskDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
      'CREATE TABLE $tasksTable ($colId INTEGER PRIMARY KEY AUTOINCREMENT,$colTitle TEXT,$colDate TEXT,$colPriority TEXT,$colStatus INTEGER)',
    );
  }

  // Fetch Operation : get all tasks objects from the database
  // we will get a list of map from the below function

  Future<List<Map<String, dynamic>>> getTaskMapList() async {
    Database db = await this.database;
    var result = await db.query(tasksTable);
    return result;
  }

  // Get the map list and convert it into Task list;
  Future<List<Task>> getTaskList() async {
    var taskMapList = await getTaskMapList();
    // get the map list from the database;
    // count the number of map entries in the db table;
    // running a foreach loop...
    final List<Task> taskList = [];
    taskMapList.forEach((taskMap) {
      taskList.add(Task.fromMap(taskMap));
    });
    taskList.sort((taskA, taskB) => taskA.date.compareTo(taskB.date));
    return taskList;
  }

  // Insert Function : insert a note object to database after converting it to map
  Future<int> insertTask(Task task) async {
    Database db = await this.database;
    var result = await db.insert(tasksTable, task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return result;
  }

  // Update operation : update a task object and save it to database
  Future<int> updateTask(Task task) async {
    Database db = await this.database;
    var result = await db.update(
      tasksTable,
      task.toMap(),
      where: '$colId=?',
      whereArgs: [task.id],
    );
    return result;
  }

  // Delete Operation : Delete a task obj from the data base
  Future<int> deleteTask(int id) async {
    var db = await this.database;
    int result = await db.delete(
      tasksTable,
      where: '$colId=?',
      whereArgs: [id],
    );
    return result;
  }
}
