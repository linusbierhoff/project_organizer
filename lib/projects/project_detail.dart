import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:project_organizer/diagram.dart';
import 'package:project_organizer/firebase/database.dart';
import 'package:project_organizer/loading.dart';
import 'package:project_organizer/projects/projectplan.dart';
import 'package:project_organizer/projects/add_members.dart';
import 'package:project_organizer/projects/research.dart';
import 'package:project_organizer/tasks/edit_tasks.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../firebase/model.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'all_project_tasks.dart';
import 'edit_project.dart';
import 'package:share/share.dart';

class ProjectView extends StatelessWidget {
  final String uid;
  ProjectView(this.uid);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          StreamProvider<Project>.value(
            value: DatabaseService(projectID: uid).projectData,
            initialData: null,
          ),
          StreamProvider<List<UserModel>>.value(
            value: DatabaseService().user,
            initialData: null,
          )
        ],
        child: Builder(builder: (BuildContext context) {
          return ProjectDetail();
        }));
  }
}

class ProjectDetail extends StatefulWidget {
  @override
  _ProjectDetailState createState() => _ProjectDetailState();
}

class _ProjectDetailState extends State<ProjectDetail> {
  bool allTasks = true;
  var formatter = new DateFormat('dd.MM.yyyy');
  @override
  Widget build(BuildContext context) {
    final databaseproject = Provider.of<Project>(context);
    final databaseuser = Provider.of<List<UserModel>>(context);

    void _showInformationPanel() {
      showModalBottomSheet(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
               backgroundColor: Theme.of(context).canvasColor,
          context: context,
          builder: (context) {
            return Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(databaseproject.title,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: Theme.of(context).textTheme.headline6)),
                      ),
                      IconButton(
                        icon: Icon(Icons.share),
                        onPressed: () {
                          Share.share(
                              "Here is the Porject-ID for ${databaseproject.title}: ${databaseproject.projectID}",
                              subject: "${databaseproject.title}");
                        },
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 25, top: 25, bottom: 20),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Start-Date:",
                            style: Theme.of(context).textTheme.bodyText1)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25, bottom: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(formatter.format(databaseproject.startDate),
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(color: Colors.grey)),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 25, top: 25, bottom: 20),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("End-Date:",
                            style: Theme.of(context).textTheme.bodyText1)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25, bottom: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(formatter.format(databaseproject.date),
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(color: Colors.grey)),
                    ),
                  ),
                  MemberList(databaseproject, databaseuser),
                ],
              ),
            );
          });
    }

    while (databaseproject == null || databaseuser == null) {
      return Loading();
    }
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: Size(double.infinity, 275),
            child: CustomAppBar(databaseproject, _showInformationPanel)),
        floatingActionButton: SpeedDial(
          backgroundColor:
              Theme.of(context).floatingActionButtonTheme.backgroundColor,
          foregroundColor:
              Theme.of(context).floatingActionButtonTheme.foregroundColor,
          marginBottom: 15,
          marginEnd: 15,
          animatedIcon: AnimatedIcons.menu_close,
          closeManually: false,
          curve: Curves.bounceIn,
          overlayOpacity: 0,
          tooltip: 'Add',
          shape: CircleBorder(),
          children: [
            SpeedDialChild(
                child: Icon(Icons.topic, color: Theme.of(context).accentColor),
                backgroundColor: Theme.of(context).primaryColor,
                onTap: () {
                  TextEditingController _controller = TextEditingController();
                  FocusNode myFocusNode = FocusNode();
                  final _formKey = GlobalKey<FormState>();

                  showDialog(
                      context: context,
                      builder: (_) {
                        return SimpleDialog(
                          backgroundColor: Theme.of(context).canvasColor,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0))),
                          title: Text("Add topic"),
                          children: [
                            Form(
                              key: _formKey,
                              child: TextFormField(
                                focusNode: myFocusNode,
                                controller: _controller,
                                decoration: InputDecoration(
                                  hintText: "Topic...",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.only(
                                      left: 20, bottom: 11, top: 11, right: 20),
                                ),
                                validator: (val) {
                                  if (val.isEmpty) {
                                    return "Can't be empty";
                                  } else {
                                    return null;
                                  }
                                },
                                onFieldSubmitted: (value) async {
                                  if (_formKey.currentState.validate()) {
                                    List _newTopics = databaseproject.topics;
                                    _newTopics.add(value);
                                    await DatabaseService().updateProject(
                                        databaseproject.title,
                                        databaseproject.subject,
                                        databaseproject.date,
                                        databaseproject.open,
                                        databaseproject.projectID,
                                        databaseproject.creationDate,
                                        _newTopics,
                                        databaseproject.projectplan,
                                        databaseproject.workTime,
                                        databaseproject.startDate);
                                    Navigator.pop(context);
                                  } else {
                                    myFocusNode.requestFocus();
                                  }
                                },
                              ),
                            ),
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
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      });
                }),
            SpeedDialChild(
                child: Icon(Icons.person_add,
                    color: Theme.of(context).accentColor),
                backgroundColor: Theme.of(context).primaryColor,
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          AddMembers(databaseuser, databaseproject.projectID)));
                }),
            SpeedDialChild(
              child: Icon(
                Icons.edit,
                color: Theme.of(context).accentColor,
              ),
              backgroundColor: Theme.of(context).primaryColor,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => EditProject(databaseproject)));
              },
            ),
          ],
        ),
        body: ListView(
          children: [
            SizedBox(
              height: 25,
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 25, right: 25, top: 20, bottom: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Your Tasks",
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  Column(
                    children: [
                      Text("Completed Tasks",
                          style: TextStyle(color: Colors.grey)),
                      Switch(
                        activeColor: Theme.of(context).primaryColor,
                        value: allTasks,
                        onChanged: (value) {
                          setState(() {
                            allTasks = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            YourTasksList(databaseproject, allTasks),
            Padding(
              padding: const EdgeInsets.all(25),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          ProjectPlan(databaseproject.projectID)));
                },
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).canvasColor,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor,
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "Projectplaner",
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            .copyWith(fontWeight: FontWeight.bold),
                      )),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 25, right: 12.5),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => AllTasks(databaseproject)));
                        },
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Theme.of(context).canvasColor,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).shadowColor,
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              "Tasks",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.5, right: 25),
                      child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    Research(databaseproject)));
                          },
                          child: Container(
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Theme.of(context).canvasColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).shadowColor,
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text(
                                  "Research",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6
                                      .copyWith(fontWeight: FontWeight.bold),
                                )),
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}

class CustomAppBar extends StatelessWidget {
  final Function _showInformationPanel;
  final Project databseproject;
  CustomAppBar(this.databseproject, this._showInformationPanel);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Container(
          color: Colors.transparent,
          height: 275,
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.zero,
                height: 200,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromRGBO(59, 217, 209, 1),
                          Color.fromRGBO(77, 204, 240, 1)
                        ]),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(100),
                        bottomRight: Radius.circular(100))),
              ),
              Positioned(
                  top: 125.0,
                  left: 0.0,
                  right: 0.0,
                  child: Container(
                      height: 150,
                      child: TaskStateDiagram(project: databseproject))),
              Positioned(
                  top: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: AppBar(
                    actions: [
                      IconButton(
                        icon: Icon(Icons.info_outline),
                        onPressed: () => _showInformationPanel(),
                      )
                    ],
                    title: Text(databseproject.title,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headline5
                            .copyWith(color: Theme.of(context).accentColor)),
                    iconTheme:
                        IconThemeData(color: Theme.of(context).accentColor),
                  )),
            ],
          )),
    );
  }
}

class MemberList extends StatefulWidget {
  final List databaseuser;
  final Project databaseproject;

  MemberList(this.databaseproject, this.databaseuser);

  @override
  _MemberListState createState() => _MemberListState();
}

class _MemberListState extends State<MemberList> {
  List member;

  @override
  void initState() {
    super.initState();
    member = DatabaseService().getUserNameFromProject(
        widget.databaseproject.projectID, widget.databaseuser);
  }

  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            Align(
                alignment: Alignment.centerLeft,
                child: Text("Members:",
                    style: Theme.of(context).textTheme.bodyText1)),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: ListView.builder(
                
                  itemCount: member.length,
                  itemBuilder: (context, i) {
                    return Text(member[i],
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .copyWith(color: Colors.grey));
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

class YourTasksList extends StatefulWidget {
  final Project project;
  final bool allTasks;
  YourTasksList(this.project, this.allTasks);
  @override
  _YourTasksListState createState() => _YourTasksListState();
}

class _YourTasksListState extends State<YourTasksList> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DatabaseService(projectID: widget.project.projectID).tasks,
      builder: (context, taskData) {
        List<Widget> itemList = [];
        if (taskData.hasData) {
          List<TaskModel> task = taskData.data;
          for (int i = 0; i < task.length; i++) {
            if (task[i].members.containsKey(_firebaseAuth.currentUser.uid) &&
                task[i].members[_firebaseAuth.currentUser.uid] == true) {
              if (task[i].open == true || widget.allTasks == true) {
                itemList.add(InkWell(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => EditTask(widget.project, task[i]))),
                  child: Padding(
                      padding: const EdgeInsets.only(
                          left: 50, bottom: 10, right: 50),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.grey, width: 2)),
                              child: Theme(
                                data: ThemeData(
                                    unselectedWidgetColor: Colors.transparent),
                                child: Checkbox(
                                  activeColor: Colors.transparent,
                                  checkColor: Theme.of(context).primaryColor,
                                  value: !task[i].open,
                                  tristate: false,
                                  onChanged: (bool isChecked) {
                                    setState(() {
                                      DatabaseService(
                                              projectID:
                                                  widget.project.projectID)
                                          .updateTask(
                                              task[i].taskID,
                                              task[i].title,
                                              task[i].notes,
                                              task[i].members,
                                              task[i].duration,
                                              !task[i].open,
                                              task[i].creationDate,
                                              task[i].topic,
                                              task[i].dependentTasks);
                                    });
                                  },
                                ),
                              )),
                          SizedBox(
                            width: 20,
                          ),
                          Flexible(
                              child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(task[i].title,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1
                                              .copyWith(fontSize: 18)),
                                      if (task[i].notes.isNotEmpty)
                                        Text(task[i].notes,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1
                                                .copyWith(color: Colors.grey))
                                    ],
                                  ))),
                        ],
                      )),
                ));
              }
            }
          }
          return Column(mainAxisSize: MainAxisSize.min, children: itemList);
        } else {
          return Padding(
            padding: const EdgeInsets.all(30),
            child: LoadingContainer(),
          );
        }
      },
    );
  }
}
