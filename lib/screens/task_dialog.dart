import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';
import '../../services/firestore_service.dart';
import '../../services/notification_service.dart';

class TaskDialog extends StatefulWidget {
  final Task? task;

  TaskDialog({this.task});

  @override
  _TaskDialogState createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  DateTime _deadline = DateTime.now();
  int _duration = 0;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _title = widget.task!.title;
      _description = widget.task!.description;
      _deadline = widget.task!.deadline;
      _duration = widget.task!.duration;
      _isCompleted = widget.task!.isCompleted;
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String formattedDateTime = DateFormat('d MMM, y').format(_deadline) + " at " + DateFormat('h:mm a').format(_deadline);

    return AlertDialog(
      title: Text(widget.task == null ? 'New Task' : 'Edit Task'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                initialValue: _title,
                validator: (value) => value!.isEmpty ? 'Enter a title' : null,
                onChanged: (value) {
                  setState(() => _title = value);
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                initialValue: _description,
                validator: (value) =>
                    value!.isEmpty ? 'Enter a description' : null,
                onChanged: (value) {
                  setState(() => _description = value);
                },
              ),
              // TextFormField(
              //   decoration:
              //       InputDecoration(labelText: 'Expected Duration (min)'),
              //   initialValue: _duration.toString(),
              //   keyboardType: TextInputType.number,
              //   validator: (value) =>
              //       value!.isEmpty ? 'Enter a duration' : null,
              //   onChanged: (value) {
              //     setState(() => _duration = int.parse(value));
              //   },
              // ),

              TextFormField(
                decoration:
                InputDecoration(labelText: 'Expected Duration (hr)'),
                maxLength: 2,
                initialValue: _duration.toString(),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty || int.tryParse(value) == null
                    ? 'Enter a valid duration'
                    : null,
                onChanged: (value) {
                  setState(() {
                    try {
                      _duration = int.parse(value);
                    } catch (e) {
                      _duration = 0;
                    }
                  });
                },
              ),
              SizedBox(height: 4,),
              Column(

                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _deadline,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null && picked != _deadline)
                            setState(() {
                              _deadline = DateTime(
                                picked.year,
                                picked.month,
                                picked.day,
                                _deadline.hour,
                                _deadline.minute,
                              );
                            });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.access_time),
                        onPressed: () async {
                          TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(_deadline),
                          );
                          if (picked != null)
                            setState(() {
                              _deadline = DateTime(
                                _deadline.year,
                                _deadline.month,
                                _deadline.day,
                                picked.hour,
                                picked.minute,
                              );
                            });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 4,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Deadline: ',style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight:
                          FontWeight.w400)),
                      Text('${formattedDateTime}',style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight:
                          FontWeight.w500)),
                    ],
                  ),

                  // Text(DateFormat('yyyy-MM-dd – kk:mm').format(_deadline)),

                ],
              ),
              SwitchListTile(
                title: Text('Mark as Completed',style: TextStyle(
                  fontSize: 14,
                    color: Colors.black,
                    fontWeight:
                    FontWeight.w600)),
                value: _isCompleted,
                onChanged: (value) {
                  setState(() => _isCompleted = value);
                },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel',style: TextStyle(
              color: Colors.red,
              fontWeight:
              FontWeight.w600)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Save',style: TextStyle(
              color: Colors.black,
              fontWeight:
              FontWeight.w600)),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              Task task = Task(
                id: widget.task?.id,
                userId: user!.uid,
                title: _title,
                description: _description,
                deadline: _deadline,
                duration: _duration,
                isCompleted: _isCompleted,
              );
              if (widget.task == null) {
                await Provider.of<FirestoreService>(context, listen: false)
                    .addTask(task);
              } else {
                await Provider.of<FirestoreService>(context, listen: false)
                    .updateTask(task);
              }

              // NotificationService().scheduleNotification(
              //   0,
              //   'Immediate Notification',
              //   'This notification was triggered by tapping the app bar',
              //   DateTime.now().add(Duration(seconds: 1)),
              // );
              print('task id : ${task.id.hashCode}');
              print('task title : ${task.title}');
              print(
                  'duration time : ${task.deadline.subtract(Duration(minutes: 10))}');
              await NotificationService().scheduleNotification(
                task.id.hashCode,
                'Task Reminder',
                'Task "${task.title}" is due in 10 minutes!',
                task.deadline.subtract(Duration(minutes: 1)),
              );
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
