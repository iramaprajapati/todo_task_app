import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_task_app/screens/task_dialog.dart';
import 'package:todo_task_app/services/auth_service.dart';

import '../models/task.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await Provider.of<AuthService>(context, listen: false).signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Task>>(
        stream: Provider.of<FirestoreService>(context).getTasks(user!.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          List<Task> tasks = snapshot.data!;
          if (tasks.isEmpty) {
            return Center(child: Text('No tasks added'));
          }
          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8),
            physics: BouncingScrollPhysics(),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              Task task = tasks[index];
              DateTime dateTime = DateTime.parse(task.deadline.toString());
              String formattedDate = DateFormat('d MMM, y').format(dateTime);
              String formattedTime = DateFormat('h:mm a').format(dateTime);
              // print('$formattedDate at $formattedTime');
              return InkWell(
                onLongPress: () {
                  NotificationService().scheduleNotification(
                    0,
                    'Immediate Notification',
                    'This notification was triggered by tapping the app bar',
                    DateTime.now().add(Duration(seconds: 60)),
                  );
                  print('object flutter_local_notifications ');
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: Colors.black.withOpacity(0.4),
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: Padding(
                            padding: const EdgeInsets.only(left: 12.0,top: 12),
                            child: Text(task.title, style: TextStyle(color: Colors.black,fontSize: 16, fontWeight: FontWeight.w500)),
                          )),
                          Row(

                            children: [
                              IconButton(
                                splashRadius: 20,
                                padding: EdgeInsets.zero,
                                icon: Icon(Icons.edit, color: Colors.black),
                                onPressed: () async {
                                  await showDialog(
                                    context: context,
                                    builder: (context) =>
                                        TaskDialog(task: task),
                                  );
                                },
                              ),
                              IconButton(
                                splashRadius: 20,
                                padding: EdgeInsets.zero,
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text('Delete Task',
                                              style: TextStyle(fontSize: 16)),
                                          content: Text(
                                              'Are you sure want to delete this task?',
                                              style: TextStyle(fontSize: 14)),
                                          actions: [
                                            TextButton(
                                                onPressed: () async {
                                                  await Provider.of<
                                                              FirestoreService>(
                                                          context,
                                                          listen: false)
                                                      .deleteTask(task.id!);
                                                  Navigator.pop(context);
                                                },
                                                child: Text('Yes',
                                                    style: TextStyle(
                                                        color: Colors.red,
                                                        fontWeight:
                                                            FontWeight.w600))),
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text('No',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w600))),
                                          ],
                                        );
                                      });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.only(right: 12.0,left: 12.0,bottom: 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Description : ',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  TextSpan(
                                    text: task.description,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 4,),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Expected Duration : ',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '${task.duration.toString()} hr',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 4,),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Deadline : ',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '$formattedDate at $formattedTime',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 4,),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Status : ',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  TextSpan(
                                    text: task.isCompleted == false ?'Pending':'Completed',
                                    style: TextStyle(
                                      color: task.isCompleted == false ? Colors.blue: Colors.green,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),


                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (context) => TaskDialog(),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
