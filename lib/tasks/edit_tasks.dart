import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:project_organizer/firebase/database.dart';
import 'package:project_organizer/firebase/model.dart';
import 'package:project_organizer/loading.dart';
import 'package:flutter/services.dart';
import 'package:project_organizer/research/create_research.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:project_organizer/methods.dart';

class EditTask extends StatefulWidget {
  final Project project;
  final TaskModel task;
  EditTask(this.project, this.task);

  @override
  _EditTaskState createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {
  final RoundedLoadingButtonController _btnController =
      new RoundedLoadingButtonController();
  final _formKey = GlobalKey<FormState>();

  String _title;
  String _notes;
  int _newDuration;
  String _newTopic;
  List newNecTasks;
  bool newOpenState;

  void setOpenState(bool _open) {
    newOpenState = _open;
  }

  void setTopic(String newTopic) {
    _newTopic = newTopic;
  }

  void setDuration(int duration) {
    _newDuration = duration;
  }

  Future<List<TaskModel>> getAllTasks() async {
    Stream _taskStream =
        DatabaseService(projectID: widget.project.projectID).tasks;
    List<TaskModel> _list = await _taskStream.last;
    return _list;
  }

  final FirebaseFunctions functions = FirebaseFunctions.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    Map newMember = Map<String, bool>.from(widget.task.members);
    _newDuration = widget.task.duration;
    _newTopic = widget.task.topic;
    newNecTasks = widget.task.dependentTasks;
    return StreamBuilder<Object>(
        stream: DatabaseService().user,
        builder: (context, userData) {
          if (userData.hasData) {
            List<UserModel> user = userData.data;

            void setMember(String _newMember) {
              if (newMember.containsKey(_newMember)) {
                newMember.clear();
              } else {
                newMember.clear();
                if (_newMember == _firebaseAuth.currentUser.uid) {
                  newMember[_newMember] = true;
                } else {
                  newMember[_newMember] = false;
                }
              }
            }

            Color setNecTask(String _newNecTask) {
              if (newNecTasks.contains(_newNecTask)) {
                newNecTasks.remove(_newNecTask);
                return Theme.of(context)
                    .textTheme
                    .bodyText1
                    .color
                    .withOpacity(0.1);
              } else {
                newNecTasks.add(_newNecTask);
                return Theme.of(context).primaryColor;
              }
            }

            Color getBorderColor(String userID) {
              if (newMember.containsKey(userID)) {
                return Theme.of(context).primaryColor;
              } else {
                return Theme.of(context)
                    .textTheme
                    .bodyText1
                    .color
                    .withOpacity(0.1);
              }
            }

            Color getBorderColorOfTask(String taskID) {
              if (newNecTasks.contains(taskID)) {
                return Theme.of(context).primaryColor;
              } else {
                return Theme.of(context)
                    .textTheme
                    .bodyText1
                    .color
                    .withOpacity(0.1);
              }
            }

            Widget taskMember() {
              if (widget.task.members.length == 0 ||
                  widget.task.members == null) {
                return Text("No person",
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(color: Colors.grey));
              } else {
                if (widget.task.members.values.elementAt(0) == false) {
                  return InkWell(
                    onTap: () async {
                      if (widget.task.members.keys.elementAt(0) ==
                          _firebaseAuth.currentUser.uid) {
                        await showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: Theme.of(context).canvasColor,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20.0))),
                            title: Text("Accept task"),
                            content: Text("Do you want to accept this task?"),
                            actions: [
                              TextButton(
                                style: ButtonStyle(
                                  overlayColor: MaterialStateColor.resolveWith(
                                      (states) => Colors.transparent),
                                ),
                                child: Text(
                                  "Dismiss",
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                onPressed: () {
                                  newMember.clear();
                                  Navigator.pop(context);
                                },
                              ),
                              TextButton(
                                style: ButtonStyle(
                                  overlayColor: MaterialStateColor.resolveWith(
                                      (states) => Colors.transparent),
                                ),
                                child: Text(
                                  "Accept",
                                  style: TextStyle(color: Colors.green),
                                ),
                                onPressed: () {
                                  newMember[widget.task.members.keys
                                      .elementAt(0)] = true;
                                  print("accepted");
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      } else {}
                    },
                    child: Text(
                        "${DatabaseService().getUserFromID(user, widget.task.members.keys.elementAt(0)).name} - not accepted",
                        style: Theme.of(context).textTheme.bodyText2),
                  );
                } else {
                  return (Text(
                      DatabaseService()
                          .getUserFromID(
                              user, widget.task.members.keys.elementAt(0))
                          .name,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(fontWeight: FontWeight.bold)));
                }
              }
            }

            return Scaffold(
              appBar: AppBar(
                title: Text(
                  "Task: ${widget.task.title}",
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.notification_important_outlined,
                    ),
                    onPressed: () async {
                      HttpsCallable callable = FirebaseFunctions.instance
                          .httpsCallable('notificationWhenTaskedIsPinged');
                      final results = await callable({
                        'projectID': widget.project.projectID,
                        'taskID': widget.task.taskID,
                        'username': DatabaseService()
                            .getUserFromID(user, _firebaseAuth.currentUser.uid)
                            .name
                      });
                      showDialog(
                          context: context,
                          builder: (BuildContext builder) {
                            return SimpleDialog(
                                backgroundColor: Theme.of(context).canvasColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(20.0))),
                                title: Text("You pinged this task!"),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "The member of this tasks got an notification!",
                                    ),
                                  ),
                                ]);
                          });
                      print(results.toString());
                    },
                  )
                ],
              ),
              body: Form(
                  key: _formKey,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 700),
                      child: ListView(
                        children: [
                          SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 50, right: 50),
                              child: Text("Topic:",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6
                                      .copyWith(
                                        color: Theme.of(context).primaryColor,
                                      )),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TopicButton(
                                setTopic, _newTopic, widget.project.topics),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          //Title
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 50, right: 50),
                              child: Text("Title",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6
                                      .copyWith(
                                        color: Theme.of(context).primaryColor,
                                      )),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                              onTap: () => _btnController.reset(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                              initialValue: widget.task.title,
                              validator: (val) =>
                                  val.isEmpty ? "Can't be empty" : null,
                              decoration: InputDecoration(
                                hintText: "Title...",
                                hintStyle: TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: Colors.transparent,
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding: EdgeInsets.only(
                                    left: 50, bottom: 11, top: 11, right: 15),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _title = val;
                                });
                              }),
                          SizedBox(height: 40),

                          //Notes
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 50, right: 50),
                              child: Text("Notes:",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6
                                      .copyWith(
                                        color: Theme.of(context).primaryColor,
                                      )),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            initialValue: widget.task.notes,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            minLines: 2,
                            onChanged: (val) {
                              setState(() {
                                _notes = val;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: "Notes...",
                              hintStyle: TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: Colors.transparent,
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                  left: 50, bottom: 11, top: 11, right: 50),
                            ),
                          ),
                          SizedBox(height: 40),

                          //Member
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 50, right: 50),
                              child: Text("Person:",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6
                                      .copyWith(
                                        color: Theme.of(context).primaryColor,
                                      )),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 50, right: 50),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(child: taskMember()),
                                TextButton.icon(
                                  style: ButtonStyle(
                                    overlayColor:
                                        MaterialStateColor.resolveWith(
                                            (states) => Colors.transparent),
                                  ),
                                  icon: Icon(Icons.edit,
                                      color: Theme.of(context).iconTheme.color),
                                  onPressed: () => showModalBottomSheet(
                                      backgroundColor:
                                          Theme.of(context).canvasColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(40.0)),
                                      context: context,
                                      builder: (context) {
                                        return MemberDialog(
                                            widget.project.projectID,
                                            user,
                                            newMember,
                                            setMember,
                                            getBorderColor);
                                      }),
                                  label: Text("Change Person",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 40),

                          //NecTasks
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 50, right: 50),
                              child: Text("Neccessary tasks:",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6
                                      .copyWith(
                                        color: Theme.of(context).primaryColor,
                                      )),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),

                          TextButton.icon(
                            style: ButtonStyle(
                              overlayColor: MaterialStateColor.resolveWith(
                                  (states) => Colors.transparent),
                            ),
                            icon: Icon(Icons.note_add_outlined,
                                color: Theme.of(context).iconTheme.color),
                            onPressed: () => showModalBottomSheet(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40.0)),
                                backgroundColor: Theme.of(context).canvasColor,
                                context: context,
                                builder: (context) {
                                  return NecTaskButton(
                                      newNecTasks,
                                      setNecTask,
                                      widget.task.taskID,
                                      widget.project.projectID,
                                      getBorderColorOfTask);
                                }),
                            label: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text("Add Task",
                                  style: Theme.of(context).textTheme.bodyText2),
                            ),
                          ),
                          SizedBox(height: 40),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 50, right: 50),
                              child: Text("Duration:",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6
                                      .copyWith(
                                        color: Theme.of(context).primaryColor,
                                      )),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),

                          DurationButton(_newDuration, setDuration),

                          SizedBox(height: 20),

                          //Button
                          Center(
                              child: RoundedLoadingButton(
                            controller: _btnController,
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                await DatabaseService(
                                        projectID: widget.project.projectID)
                                    .updateTask(
                                        widget.task.taskID,
                                        _title ?? widget.task.title,
                                        _notes ?? widget.task.notes,
                                        newMember,
                                        _newDuration,
                                        newOpenState ?? widget.task.open,
                                        widget.task.creationDate,
                                        _newTopic ?? widget.task.topic,
                                        newNecTasks ??
                                            widget.task.dependentTasks);
                                await Methods()
                                    .fillProjectPlan(widget.project.projectID);

                                _btnController.success();
                                Navigator.pop(context);
                              } else {
                                _btnController.error();
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                "Save",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(
                                        color: Theme.of(context).accentColor),
                              ),
                            ),
                            color: Theme.of(context).primaryColor,
                          )),

                          SizedBox(height: 20),

                          DoneButton(
                            projectID: widget.project.projectID,
                            task: widget.task,
                            setOpenState: setOpenState,
                          ),

                          SizedBox(
                            height: 20,
                          )
                        ],
                      ),
                    ),
                  )),
            );
          } else {
            return Loading();
          }
        });
  }
}

//////////////Widgets//////////////

class MemberDialog extends StatefulWidget {
  final String projectID;
  final List<UserModel> user;
  final Map newMember;
  final Function setMember;
  final Function getBorderColor;

  MemberDialog(this.projectID, this.user, this.newMember, this.setMember,
      this.getBorderColor);

  @override
  _MemberDialogState createState() => _MemberDialogState();
}

class _MemberDialogState extends State<MemberDialog> {
  @override
  Widget build(BuildContext context) {
    print(widget.newMember.toString());
    List<UserModel> userList =
        DatabaseService().getUserFromProject(widget.projectID, widget.user);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
            padding: EdgeInsets.all(20),
            child:
                Text("Members:", style: Theme.of(context).textTheme.headline6)),
        Expanded(
          child: ListView.builder(
              itemCount: userList.length,
              itemBuilder: (context, i) {
                return Padding(
                  padding: EdgeInsets.all(10),
                  child: InkWell(
                      onTap: () {
                        setState(() {
                          widget.setMember(userList[i].userID);
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color:
                                    widget.getBorderColor(userList[i].userID))),
                        padding: EdgeInsets.all(20),
                        child: Text(userList[i].name,
                            style: Theme.of(context).textTheme.bodyText1),
                      )),
                );
              }),
        )
      ],
    );
  }
}

// ignore: must_be_immutable
class DurationButton extends StatefulWidget {
  final Function setDuration;
  int newDuration;
  DurationButton(this.newDuration, this.setDuration);
  @override
  _DurationButtonState createState() => _DurationButtonState();
}

class _DurationButtonState extends State<DurationButton> {
  int minutes;
  int hours;

  String getDurationText() {
    int minutes = widget.newDuration % 60;
    int hours = widget.newDuration ~/ 60;
    String both = "$hours hours & $minutes minutes";
    return both;
  }

  int getHours() {
    return widget.newDuration ~/ 60;
  }

  int getMinutes() {
    return widget.newDuration % 60;
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        overlayColor:
            MaterialStateColor.resolveWith((states) => Colors.transparent),
      ),
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                backgroundColor: Theme.of(context).canvasColor,
                title: Text("Set Duration"),
                contentPadding: EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Hours: ",
                                  style: Theme.of(context).textTheme.bodyText1),
                              Expanded(
                                  child: TextFormField(
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    hours = int.parse(value);
                                  }
                                },
                                initialValue: getHours().toString(),
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  fillColor: Colors.transparent,
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  filled: true,
                                  contentPadding: EdgeInsets.only(
                                      left: 15, bottom: 11, top: 11, right: 15),
                                ),
                              )),
                            ]),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Minutes: ",
                                  style: Theme.of(context).textTheme.bodyText1),
                              Expanded(
                                  child: TextFormField(
                                initialValue: getMinutes().toString(),
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    minutes = int.parse(value);
                                  }
                                },
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  fillColor: Colors.transparent,
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.only(
                                      left: 15, bottom: 11, top: 11, right: 15),
                                ),
                              )),
                            ]),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  TextButton.icon(
                    style: ButtonStyle(
                      overlayColor: MaterialStateColor.resolveWith(
                          (states) => Colors.transparent),
                    ),
                    label: Text("Save",
                        style: Theme.of(context).textTheme.bodyText2),
                    icon: Icon(Icons.save,
                        color: Theme.of(context).iconTheme.color),
                    onPressed: () {
                      setState(() {
                        if (minutes == null) {
                          minutes = getMinutes();
                        }
                        if (hours == null) {
                          hours = getHours();
                        }
                        setState(() {
                          widget.newDuration = hours * 60 + minutes;
                        });
                        widget.setDuration(widget.newDuration);

                        Navigator.pop(context);
                      });
                    },
                  )
                ],
              );
            });
      },
      child: Center(
          child: Container(
        child: Text(getDurationText(),
            style: Theme.of(context).textTheme.bodyText1),
      )),
    );
  }
}

// ignore: must_be_immutable
class NecTaskButton extends StatefulWidget {
  final Function setNecTasks;
  final Function getBorderColor;
  final String taskId;
  final String projectId;
  List necTasks;
  NecTaskButton(this.necTasks, this.setNecTasks, this.taskId, this.projectId,
      this.getBorderColor);
  @override
  _NecTaskButtonState createState() => _NecTaskButtonState();
}

class _NecTaskButtonState extends State<NecTaskButton> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
        stream: DatabaseService(projectID: widget.projectId).tasks,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return LoadingContainer();
          }
          List<TaskModel> taskList = snapshot.data;
          taskList
              .remove(DatabaseService().getTaskFromId(widget.taskId, taskList));

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Neccessary Tasks:",
                      style: Theme.of(context).textTheme.headline6)),
              Expanded(
                child: ListView.builder(
                    itemCount: taskList.length,
                    itemBuilder: (context, i) {
                      return Padding(
                        padding: EdgeInsets.all(10),
                        child: InkWell(
                            onTap: () {
                              setState(() {
                                widget.setNecTasks(taskList[i].taskID);
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: widget
                                          .getBorderColor(taskList[i].taskID))),
                              padding: EdgeInsets.all(20),
                              child: Text(taskList[i].title,
                                  style: Theme.of(context).textTheme.bodyText1),
                            )),
                      );
                    }),
              )
            ],
          );
        });
  }
}

class DoneButton extends StatefulWidget {
  final Function setOpenState;
  final TaskModel task;
  final String projectID;
  DoneButton({this.task, this.projectID, this.setOpenState});
  @override
  DoneButtonState createState() => DoneButtonState();
}

class DoneButtonState extends State<DoneButton> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: DatabaseService(
                projectID: widget.projectID, taskID: widget.task.taskID)
            .taskData,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return LoadingContainer();
          }
          TaskModel task = snapshot.data;

          if (task.open) {
            return Center(
                child: TextButton.icon(
                    onPressed: () {
                      widget.setOpenState(false);
                      setState(() {});
                      DatabaseService(projectID: widget.projectID).updateTask(
                          task.taskID,
                          task.title,
                          task.notes,
                          task.members,
                          task.duration,
                          false,
                          task.creationDate,
                          task.topic,
                          task.dependentTasks);
                    },
                    icon: Icon(Icons.done, color: Colors.green),
                    label: Text(
                      "Done",
                      style: TextStyle(color: Colors.green),
                    )));
          }
          return Center(
              child: TextButton(
                  onPressed: () {
                    widget.setOpenState(true);
                    setState(() {});
                    DatabaseService(projectID: widget.projectID).updateTask(
                        task.taskID,
                        task.title,
                        task.notes,
                        task.members,
                        task.duration,
                        true,
                        task.creationDate,
                        task.topic,
                        task.dependentTasks);
                  },
                  child: Text(
                    "Re-Open",
                    style: TextStyle(color: Colors.orange),
                  )));
        });
  }
}
