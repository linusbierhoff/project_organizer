import 'package:flutter/material.dart';
import 'package:project_organizer/firebase/database.dart';
import 'package:project_organizer/methods.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class DeleteTaskSheet extends StatelessWidget {
  final task;
  final projectID;
  final RoundedLoadingButtonController _btnControllerDelete =
      new RoundedLoadingButtonController();

  DeleteTaskSheet({@required this.task, @required this.projectID});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
            padding: EdgeInsets.all(20),
            child:
                Text(task.title, style: Theme.of(context).textTheme.headline6)),
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
                          borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                      title: Text("Delete " + task.title),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Align(
                              alignment: Alignment.center,
                              child: Text("Do you want to delete this task?")),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10.0, bottom: 10.0, left: 20, right: 20),
                          child: RoundedLoadingButton(
                            controller: _btnControllerDelete,
                            color: Colors.red,
                            child: Text("Delete",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(
                                        color: Theme.of(context).accentColor)),
                            onPressed: () async {
                              await DatabaseService(projectID: projectID)
                                  .deleteTask(task.taskID);
                              await Methods().fillProjectPlan(projectID);
                              _btnControllerDelete.success();
                              Navigator.pop(context);
                              Navigator.pop(context);
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
                    ),
                  );
                }),
          ),
        ),
      ],
    );
  }
}
