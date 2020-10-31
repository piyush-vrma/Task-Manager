import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/utiles/database_helper.dart';

class AddTaskScreen extends StatefulWidget {
  final task;
  AddTaskScreen({this.task});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _priority;
  DateTime _date = DateTime.now();
  TextEditingController _dateController = TextEditingController();

  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');
  final List<String> _priorities = ['Low', 'Medium', 'High'];

  _handleDatePicker() async {
    final DateTime date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null && date != _date) {
      setState(() {
        _date = date;
      });
    }
    _dateController.text = _dateFormatter.format(date);
  }

  @override
  void initState() {
    if (widget.task != null) {
      _title = widget.task.title;
      _date = widget.task.date;
      _priority = widget.task.priority;
    }
    _dateController.text = _dateFormatter.format(_date);
    super.initState();
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.arrow_back_ios,
                          size: 30.0,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(
                            left: 220.0,
                          ),
                          height: 80.0,
                          child: Image.asset('images/homework.png'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Text(
                    widget.task == null ? 'Add Task' : 'Update Task',
                    style: TextStyle(
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: TextFormField(
                            initialValue: _title,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18.0),
                            decoration: InputDecoration(
                              labelText: 'Title',
                              labelStyle: TextStyle(
                                fontSize: 18.0,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                            validator: (value) => value.isEmpty
                                ? 'Please Enter a Task Title'
                                : null,
                            onSaved: (value) => _title = value,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: TextFormField(
                            readOnly: true,
                            textAlign: TextAlign.center,
                            controller: _dateController,
                            onTap: _handleDatePicker,
                            style: TextStyle(fontSize: 18.0),
                            decoration: InputDecoration(
                              labelText: 'Date',
                              labelStyle: TextStyle(
                                fontSize: 18.0,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: DropdownButtonFormField(
                            // Drop Down Button form field ....
                            icon: Icon(
                              Icons.arrow_drop_down_circle,
                            ),
                            iconEnabledColor: Theme.of(context).primaryColor,
                            items: _priorities.map((String priority) {
                              return DropdownMenuItem(
                                value: priority,
                                child: Text(
                                  priority,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.black,
                                  ),
                                ),
                              );
                            }).toList(),
                            style: TextStyle(fontSize: 18.0),
                            decoration: InputDecoration(
                              labelText: 'Priority',
                              labelStyle: TextStyle(
                                fontSize: 18.0,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                            validator: (value) => _priority == null
                                ? 'Please select a priority level'
                                : null,
                            onChanged: (value) {
                              setState(() {
                                _priority = value;
                              });
                            },
                            value: _priority,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 20.0),
                          height: 60.0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: FlatButton(
                            child: Text(
                              widget.task == null ? 'Add' : 'Update',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: _submit,
                          ),
                        ),
                        widget.task != null
                            ? Container(
                                margin: EdgeInsets.symmetric(vertical: 20.0),
                                height: 60.0,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.red[900],
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                child: FlatButton(
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: _delete,
                                ),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  _delete() async {
    moveToLastScreen();
    int result = await databaseHelper.deleteTask(widget.task.id);

    if (result != 0) {
      _showAlertDialog('Status', 'Task Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error Occurred while Deleting Task');
    }
  }

  _submit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      // print('$_title $_priority $_date');

      moveToLastScreen();

      Task task = Task(title: _title, date: _date, priority: _priority);
      int result;

      if (widget.task == null) {
        // Add Data to user Database ....
        task.status = 0;
        result = await databaseHelper.insertTask(task);
      } else {
        // Update Data...
        task.id = widget.task.id;
        task.status = widget.task.status;
        result = await databaseHelper.updateTask(task);
      }

      if (result != 0) {
        // Success
        String status = widget.task == null ? 'Added' : 'Updated';
        _showAlertDialog('Status', 'Task $status Successfully');
      } else {
        // Failure
        _showAlertDialog('Status', 'Problem Saving Task');
      }
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 25.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        message,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Color(0xff5682db),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
