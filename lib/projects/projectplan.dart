import 'package:intl/intl.dart';
import 'package:project_organizer/firebase/database.dart';
import 'package:project_organizer/firebase/model.dart';
import 'package:flutter/material.dart';
import 'package:project_organizer/loading.dart';
import 'package:project_organizer/methods.dart';
import 'package:project_organizer/tasks/edit_tasks.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class ProjectPlan extends StatefulWidget {
  final String projectId;
  ProjectPlan(this.projectId);
  @override
  _ProjectPlanState createState() => _ProjectPlanState();
}

class _ProjectPlanState extends State<ProjectPlan> {
  final RoundedLoadingButtonController _btnController =
      new RoundedLoadingButtonController();
  String errorText = "";
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          StreamProvider<Project>.value(
            value: DatabaseService(projectID: widget.projectId).projectData,
            initialData: null,
          ),
          StreamProvider<List<TaskModel>>.value(
            value: DatabaseService(projectID: widget.projectId).tasks,
            initialData: null,
          ),
          StreamProvider<List<UserModel>>.value(
            value: DatabaseService().user,
            initialData: null,
          )
        ],
        child: Builder(builder: (BuildContext context) {
          var databaseProject = Provider.of<Project>(context);
          var databaseUser = Provider.of<List<UserModel>>(context);
          var databaseTasks = Provider.of<List<TaskModel>>(context);

          if (databaseTasks == null ||
              databaseUser == null ||
              databaseProject == null) {
            return Loading();
          }

          if (databaseProject.projectplan == null ||
              databaseProject.projectplan.isEmpty) {
            return Scaffold(
                appBar: AppBar(
                    title: Text(
                  'Projectplan: ${databaseProject.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )),
                body: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RoundedLoadingButton(
                        color: Color.fromRGBO(77, 204, 240, 1),
                        controller: _btnController,
                        child: Text("You have to load your projectplan",
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(
                                    color: Theme.of(context).accentColor)),
                        onPressed: () async {
                          var _result = await Methods()
                              .fillProjectPlan(databaseProject.projectID);
                          if (_result != "Done") {
                            setState(() {
                              errorText = _result;
                            });
                            _btnController.error();
                          } else {}
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          errorText,
                          style: TextStyle(color: Colors.red),
                        ),
                      )
                    ],
                  ),
                ));
          }
          List<String> _list = databaseProject.projectplan.keys.toList()
            ..sort((k1, k2) => databaseProject.projectplan[k1]
                .compareTo(databaseProject.projectplan[k2]));

          Widget diagramBuilder() {
            List<Widget> column = [];

            for (UserModel _user in DatabaseService()
                .getUserFromProject(databaseProject.projectID, databaseUser)) {
              List<DiagramObject> _objectList = [];

              for (String _taskId in _list) {
                TaskModel _task =
                    DatabaseService().getTaskFromId(_taskId, databaseTasks);

                if (_task.members.containsKey(_user.userID)) {
                  _objectList.add(DiagramObject(
                      startDate: DateTime.fromMicrosecondsSinceEpoch(
                          databaseProject.projectplan[_task.taskID]
                              .microsecondsSinceEpoch),
                      endDate: Methods().endTime(_task, databaseProject),
                      task: _task));
                }
              }

              column.add(DiagramBar(
                user: _user,
                objects: _objectList,
                project: databaseProject,
              ));
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: column,
            );
          }

          return Scaffold(
              floatingActionButton: FloatingActionButton(
                child: Icon(
                  Icons.edit,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  int _newWorkTime;
                  showDialog(
                      context: context,
                      builder: (_) => SimpleDialog(
                            backgroundColor: Theme.of(context).canvasColor,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20.0))),
                            title: Text("Change worktime per day\n(in hours)"),
                            children: [
                              TextFormField(
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return "Can't be empty";
                                    } else {
                                      return null;
                                    }
                                  },
                                  onTap: () => _btnController.reset(),
                                  initialValue:
                                      databaseProject.workTime.toString(),
                                  onChanged: (val) {
                                    try {
                                      _newWorkTime = int.parse(val);
                                    } catch (e) {
                                      _newWorkTime = databaseProject.workTime;
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Worktime...",
                                    hintStyle: TextStyle(color: Colors.grey),
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.only(
                                        left: 20,
                                        bottom: 11,
                                        top: 11,
                                        right: 15),
                                  )),
                              SizedBox(
                                height: 10,
                              ),
                              TextButton.icon(
                                style: ButtonStyle(
                                  overlayColor: MaterialStateColor.resolveWith(
                                      (states) => Colors.transparent),
                                ),
                                label: Text("Save",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(
                                            color: Theme.of(context)
                                                .primaryColor)),
                                icon: Icon(
                                  Icons.save,
                                  color: Theme.of(context).primaryColor,
                                ),
                                onPressed: () async {
                                  await DatabaseService().updateProject(
                                      databaseProject.title,
                                      databaseProject.subject,
                                      databaseProject.date,
                                      databaseProject.open,
                                      databaseProject.projectID,
                                      databaseProject.creationDate,
                                      databaseProject.topics,
                                      databaseProject.projectplan,
                                      _newWorkTime ?? databaseProject.workTime,
                                      databaseProject.startDate);
                                  await Methods().fillProjectPlan(
                                      databaseProject.projectID);
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ));
                },
              ),
              appBar: AppBar(
                  title: Text(
                'Projectplan: ${databaseProject.title}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )),
              body: Align(
                alignment: Alignment.centerLeft,
                child: SingleChildScrollView(
               
                  scrollDirection: Axis.horizontal,
                  child: diagramBuilder(),
                ),
              ));
        }));
  }
}

class DiagramObject {
  final DateTime startDate;
  final DateTime endDate;
  final TaskModel task;

  DiagramObject({this.startDate, this.endDate, this.task});
}

//DiagramBar

class DiagramBar extends StatefulWidget {
  final UserModel user;
  final List<DiagramObject> objects;
  final Project project;

  DiagramBar({this.user, this.objects, this.project});

  @override
  _DiagramBarState createState() => _DiagramBarState();
}

class _DiagramBarState extends State<DiagramBar> {
  Color getColor(DiagramObject task) {
    DateTime now = DateTime.now();
    DateTime _dateTime = DateTime(now.year, now.month, now.day);

    if (!task.task.open) {
      return Colors.green.withOpacity(0.5);
    }
    if (task.endDate.isBefore(_dateTime)) {
      return Colors.red;
    }
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _row = [
      Container(
          width: 80,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.user.name,
              style: Theme.of(context).textTheme.bodyText1,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ))
    ];

    for (int i = 0; i < widget.objects.length; i++) {
      int length = widget.objects[i].task.duration;

      int difference = getDifference(widget.objects, i) - length;

      print('$i: $difference');

      _row.add(SizedBox(
        width: difference.toDouble(),
      ));

      _row.add(InkWell(
        onTap: () => showDialog(
            context: context,
            builder: (_) => DetailedDialog(
                task: widget.objects[i],
                user: widget.user,
                project: widget.project)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.all(5),
            height: 50,
            child: Center(
              child: Text(
                widget.objects[i].task.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(color: Theme.of(context).accentColor),
              ),
            ),
            width: length.toDouble(),
            color: getColor(widget.objects[i]),
          ),
        ),
      ));
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
          height: 50,
          child: Row(
            children: _row,
          )),
    );
  }

  int getDifference(List<DiagramObject> objects, index) {
    int duration = objects[index].task.duration;

    int dayDiffrence = DateTime(objects[index].startDate.year,
            objects[index].startDate.month, objects[index].startDate.day)
        .difference(DateTime(widget.project.startDate.year,
            widget.project.startDate.month, widget.project.startDate.day))
        .inDays;

    dayDiffrence *= widget.project.workTime;

    duration += Duration(
            hours: objects[index].startDate.hour + dayDiffrence,
            minutes: objects[index].startDate.minute)
        .inMinutes;

    while (index != 0) {
      index--;
      duration -= getDifference(objects, index);
    }

    return duration;
  }
}

class DetailedDialog extends StatelessWidget {
  final DiagramObject task;
  final UserModel user;
  final Project project;

  DetailedDialog({this.task, this.user, this.project});
  @override
  Widget build(BuildContext context) {
    var formatter = new DateFormat('dd.MM.yyyy');
    return SimpleDialog(
      backgroundColor: Theme.of(context).canvasColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      title: Text(task.task.title),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Topic: ${task.task.topic}",
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyText1),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Start: ${formatter.format(task.startDate)}",
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyText2),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "End: ${formatter.format(task.endDate)}",
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: Divider(),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Person: ${user.name}",
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyText2
          ),
        ),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
                style: ButtonStyle(
                  overlayColor: MaterialStateColor.resolveWith(
                      (states) => Colors.transparent),
                ),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => EditTask(project, task.task))),
                child: Text(
                  "Go to the task",
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ))),
      ],
    );
  }
}
