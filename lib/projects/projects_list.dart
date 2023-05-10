import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:project_organizer/firebase/database.dart';
import 'package:project_organizer/loading.dart';
import 'package:provider/provider.dart';
import 'project_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../firebase/model.dart';

class ProjectsList extends StatefulWidget {
  @override
  _ProjectsListState createState() => _ProjectsListState();
}

class _ProjectsListState extends State<ProjectsList> {
  var formatter = new DateFormat('dd.MM.yyyy');
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Widget getRowOutList(List<String> list) {
    String names = "";
    for (int i = 0; i < list.length; i++) {
      names = names + "${list[i]}";
      if (i < list.length - 1) {
        names = names + ", ";
      }
    }
    return Text(names,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context)
            .textTheme
            .bodyText2
            .copyWith(color: Theme.of(context).accentColor));
  }

  @override
  Widget build(BuildContext context) {
    var databaseProjects = Provider.of<List<Project>>(context);
    var databaseUser = Provider.of<List<UserModel>>(context);

    void _showSettings(Project project) {
      final RoundedLoadingButtonController _btnControllerDelete =
          new RoundedLoadingButtonController();
      final RoundedLoadingButtonController _btnControllerClose =
          new RoundedLoadingButtonController();

      showModalBottomSheet(
         backgroundColor: Theme.of(context).canvasColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
          context: context,
          builder: (context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      project.title,
                      style: Theme.of(context).textTheme.headline6
                    )),
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 35),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(35)),
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    child: TextButton.icon(
                        style: ButtonStyle(
                          overlayColor: MaterialStateColor.resolveWith(
                              (states) => Colors.transparent),
                        ),
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        label: Text(
                          "Delete",
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () async {
                          await showDialog(
                            context: context,
                            builder: (_) => SimpleDialog(
                              backgroundColor: Theme.of(context).canvasColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(20.0))),
                              title: Text("Delete " + project.title),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                          "Do you want to remove this project?")),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10.0,
                                      bottom: 10.0,
                                      left: 20,
                                      right: 20),
                                  child: RoundedLoadingButton(
                                    controller: _btnControllerDelete,
                                    color: Colors.red,
                                    child: Text(
                                      "Delete",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .accentColor),
                                    ),
                                    onPressed: () async {
                                      UserModel _user = DatabaseService()
                                          .getUserFromID(databaseUser,
                                              _firebaseAuth.currentUser.uid);
                                      await DatabaseService().deleteProject(
                                          project.projectID,
                                          databaseUser,
                                          _user);

                                      _btnControllerDelete.success();
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                                TextButton(
                                  style: ButtonStyle(
                                    overlayColor:
                                        MaterialStateColor.resolveWith(
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
                            ),
                          );
                        }),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 50),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(35)),
                    padding: EdgeInsets.all(10),
                    width: double.infinity,
                    child: TextButton.icon(
                        style: ButtonStyle(
                          overlayColor: MaterialStateColor.resolveWith(
                              (states) => Colors.transparent),
                        ),
                        icon: Icon(Icons.close, color: Colors.orange),
                        label: Text(
                          "Close",
                          style: TextStyle(color: Colors.orange),
                        ),
                        onPressed: () async {
                          await showDialog(
                            context: context,
                            builder: (_) => SimpleDialog(
                              backgroundColor: Theme.of(context).canvasColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(20.0))),
                              title: Text("Close " + project.title),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                          "Do you want to close this project?")),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 10.0, left: 20, right: 20),
                                  child: RoundedLoadingButton(
                                    controller: _btnControllerClose,
                                    color: Colors.orange,
                                    child: Text("Close",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .accentColor)),
                                    onPressed: () async {
                                      await DatabaseService().updateProject(
                                          project.title,
                                          project.subject,
                                          project.date,
                                          false,
                                          project.projectID,
                                          project.creationDate,
                                          project.topics,
                                          project.projectplan,
                                          project.workTime,
                                          project.startDate);

                                      _btnControllerClose.success();
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                                TextButton(
                                  style: ButtonStyle(
                                    overlayColor:
                                        MaterialStateColor.resolveWith(
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
                            ),
                          );
                        }),
                  ),
                ),
              ],
            );
          });
    }

    List<Project> getOpenList() {
      List<Project> newList = [];
      for (var i = 0; i < databaseProjects.length; i++) {
        if (databaseProjects[i].open == true) {
          newList.add(databaseProjects[i]);
        }
      }
      newList.sort((a, b) {
        return a.date.compareTo(b.date);
      });

      return newList;
    }

    if (databaseProjects == null || databaseUser == null) {
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
          itemCount: getOpenList().length + 1,
          itemBuilder: (context, i) {
            if (i == getOpenList().length) {
              return Container(
                height: 100,
              );
            } else {
              return Padding(
                  padding: EdgeInsets.all(20),
                  child: InkWell(
                      onLongPress: () => _showSettings(getOpenList()[i]),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                ProjectView(getOpenList()[i].projectID)));
                      },
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color.fromRGBO(59, 217, 209, 1),
                                Color.fromRGBO(77, 204, 240, 1)
                              ]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(getOpenList()[i].title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6
                                              .copyWith(
                                                fontWeight: FontWeight.normal,
                                                  color: Theme.of(context)
                                                      .accentColor)),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(getOpenList()[i].subject,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1.copyWith(
                                              
                                            ))
                                  ],
                                ),
                                getRowOutList(DatabaseService()
                                    .getUserNameFromProject(
                                        getOpenList()[i].projectID,
                                        databaseUser)),
                                Text(
                                    "Submission: " +
                                        formatter.format(getOpenList()[i].date),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1.copyWith(color: Theme.of(context).accentColor)
                                        )
                              ],
                            )),
                      )));
            }
          });
    }
  }
}
