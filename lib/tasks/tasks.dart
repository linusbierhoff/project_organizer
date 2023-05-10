import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_organizer/firebase/database.dart';
import 'package:project_organizer/firebase/model.dart';
import 'package:project_organizer/loading.dart';
import 'package:project_organizer/tasks/delete_task.dart';
import 'package:project_organizer/tasks/edit_tasks.dart';
import 'package:provider/provider.dart';

class Tasks extends StatefulWidget {
  @override
  _TasksState createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  @override
  Widget build(BuildContext context) {
    var currentUser = Provider.of<UserModel>(context);
    while (currentUser == null) {
      return Loading();
    }

    return StreamProvider<List<Project>>.value(
        value: DatabaseService(currentUser: currentUser).projects,
        initialData: null,
        child: Builder(builder: (BuildContext context) {
          return NestedScrollView(
              physics: NeverScrollableScrollPhysics(),
              headerSliverBuilder: (context, value) {
                return [
                  SliverAppBar(
                      floating: true,
                      pinned: true,
                      snap: false,
                      elevation: 0.0,
                      shadowColor: Colors.transparent,
                      backgroundColor: Colors.transparent,
                      title: Text(
                        'Tasks',
                      )),
                ];
              },
              body: AllTasksList());
        }));
  }
}

class AllTasksList extends StatefulWidget {
  @override
  _AllTasksListState createState() => _AllTasksListState();
}

class _AllTasksListState extends State<AllTasksList> {
  @override
  Widget build(BuildContext context) {
    var databaseProjects = Provider.of<List<Project>>(context);

    List<Project> getOpenList() {
      List<Project> newList = [];
      for (var i = 0; i < databaseProjects.length; i++) {
        if (databaseProjects[i].open == true) {
          newList.add(databaseProjects[i]);
        }
      }
      return newList;
    }

    while (databaseProjects == null) {
      return Loading();
    }

    if (getOpenList().length == 0) {
      return Center(
        child: Text(
          "You do not have any projects",
          style: TextStyle(
              color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 25),
        ),
      );
    } else {
      return ListView.builder(
          itemCount: getOpenList().length,
          itemBuilder: (context, i) {
            return AllTaskListTile(getOpenList()[i]);
          });
    }
  }
}

class AllTaskListTile extends StatefulWidget {
  final Project project;
  AllTaskListTile(this.project);
  @override
  _AllTaskListTileState createState() => _AllTaskListTileState();
}

class _AllTaskListTileState extends State<AllTaskListTile> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DatabaseService(projectID: widget.project.projectID).tasks,
      builder: (context, databaseTask) {
        if (databaseTask.hasData) {
          List<TaskModel> tasks = databaseTask.data;

          List<Widget> _getColumnItems() {
            List<Widget> _itemList = [];

            _itemList.add(
              Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).canvasColor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text(
                        widget.project.title,
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            .copyWith(color: Color.fromRGBO(77, 204, 240, 1)),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(widget.project.subject,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(color: Colors.grey))
                    ]),
                  )),
            );
            for (int i = 0; i < tasks.length; i++) {
              if (tasks[i].members.containsKey(_firebaseAuth.currentUser.uid)) {
                if (tasks[i].members[_firebaseAuth.currentUser.uid] == true) {
                  _itemList.add(Padding(
                    padding:
                        const EdgeInsets.only(left: 20, bottom: 10, right: 20),
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              EditTask(widget.project, tasks[i]))),
                      onLongPress: () {
                        showModalBottomSheet(
                            backgroundColor: Theme.of(context).canvasColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40.0)),
                            context: context,
                            builder: (context) {
                              return DeleteTaskSheet(
                                  task: tasks[i],
                                  projectID: widget.project.projectID);
                            });
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.grey, width: 2)),
                                child: Theme(
                                  data: ThemeData(
                                      unselectedWidgetColor:
                                          Colors.transparent),
                                  child: Checkbox(
                                    activeColor: Colors.transparent,
                                    checkColor: Theme.of(context).primaryColor,
                                    value: !tasks[i].open,
                                    tristate: false,
                                    onChanged: (bool isChecked) {
                                      setState(() {
                                        DatabaseService(
                                                projectID:
                                                    widget.project.projectID)
                                            .updateTask(
                                                tasks[i].taskID,
                                                tasks[i].title,
                                                tasks[i].notes,
                                                tasks[i].members,
                                                tasks[i].duration,
                                                !tasks[i].open,
                                                tasks[i].creationDate,
                                                tasks[i].topic,
                                                tasks[i].dependentTasks);
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tasks[i].title,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          .copyWith(fontSize: 18)),
                                  if (tasks[i].notes.isNotEmpty)
                                    Text(tasks[i].notes,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .copyWith(color: Colors.grey))
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                    ),
                  ));
                }
              }
            }

            return _itemList;
          }

          return Column(
            children: _getColumnItems(),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
