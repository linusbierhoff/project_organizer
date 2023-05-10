import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_organizer/firebase/database.dart';
import 'package:project_organizer/firebase/model.dart';
import 'package:project_organizer/loading.dart';
import 'package:project_organizer/tasks/delete_task.dart';
import 'package:project_organizer/tasks/edit_tasks.dart';

class AllTasks extends StatefulWidget {
  final Project project;
  AllTasks(this.project);
  @override
  _AllTasksState createState() => _AllTasksState();
}

class _AllTasksState extends State<AllTasks> {
  int currentTab = 0;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    List<Tab> getTabs() {
      List<Tab> tabList = [
        Tab(
          text: 'All topics',
        ),
        Tab(
          text: "No topic",
        )
      ];
      for (int i = 0; i < widget.project.topics.length; i++) {
        tabList.add(
          Tab(
            text: widget.project.topics[i],
          ),
        );
      }
      return tabList;
    }

    List<Widget> getChildren() {
      List<Widget> childrenList = [
        TasksList(
          widget.project,
          null,
        ),
        TasksList(
          widget.project,
          "",
        )
      ];
      for (int i = 0; i < widget.project.topics.length; i++) {
        childrenList.add(TasksList(
          widget.project,
          widget.project.topics[i],
        ));
      }
      return childrenList;
    }

    void createTask() {
      TextEditingController _controller = TextEditingController();
      FocusNode myFocusNode = FocusNode();

      showDialog(
          context: context,
          builder: (_) {
            return SimpleDialog(
              backgroundColor: Theme.of(context).canvasColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              title: Text("Add task"),
              children: [
                Form(
                  key: _formKey,
                  child: TextFormField(
                    focusNode: myFocusNode,
                    controller: _controller,
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
                      myFocusNode.requestFocus();
                      if (_formKey.currentState.validate()) {
                        await DatabaseService(
                                projectID: widget.project.projectID)
                            .createTask(value, "");
                        _controller.clear();
                        //myFocusNode.requestFocus();

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
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Theme.of(context).primaryColor,
        ),
        onPressed: () {
          createTask();
        },
      ),
      body: DefaultTabController(
        length: widget.project.topics.length + 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, value) {
            return [
              SliverAppBar(
                floating: true,
                pinned: true,
                snap: false,
                elevation: 0.0,
                title: Text(
                  'Tasks ${widget.project.title}',
                ),
                bottom: TabBar(
                  isScrollable: true,
                  tabs: getTabs(),
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .color
                      .withOpacity(0.5),
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorColor: Theme.of(context).primaryColor,
                ),
              ),
            ];
          },
          body: TabBarView(
            children: getChildren(),
          ),
        ),
      ),
    );
  }
}

class TasksList extends StatefulWidget {
  final Project project;
  final String filter;

  TasksList(this.project, this.filter);
  @override
  _TasksListState createState() => _TasksListState();
}

class _TasksListState extends State<TasksList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DatabaseService(projectID: widget.project.projectID).tasks,
      builder: (context, taskData) {
        if (taskData.hasData) {
          List<TaskModel> tasks = taskData.data;
          List<TaskModel> _filteredList;

          if (widget.filter != null) {
            List<TaskModel> _list = [];
            for (int i = 0; i < tasks.length; i++) {
              if (tasks[i].topic == widget.filter) {
                _list.add(tasks[i]);
              }
            }

            _filteredList = _list;
          } else {
            _filteredList = tasks;
          }

          return ListView.builder(
              itemCount: _filteredList.length + 1,
              itemBuilder: (context, i) {
                if (i == _filteredList.length) {
                  return SizedBox(height: 100);
                }
                return Padding(
                  padding: const EdgeInsets.only(
                      left: 20, bottom: 10, top: 10, right: 20),
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            EditTask(widget.project, _filteredList[i]))),
                    onLongPress: () {
                      showModalBottomSheet(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40.0),
                          ),
                          context: context,
                          builder: (context) {
                            return DeleteTaskSheet(
                                task: _filteredList[i],
                                projectID: widget.project.projectID);
                          });
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Theme.of(context).canvasColor),
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
                                  value: !_filteredList[i].open,
                                  tristate: false,
                                  onChanged: (bool isChecked) {
                                    setState(() {
                                      DatabaseService(
                                              projectID:
                                                  widget.project.projectID)
                                          .updateTask(
                                              _filteredList[i].taskID,
                                              _filteredList[i].title,
                                              _filteredList[i].notes,
                                              _filteredList[i].members,
                                              _filteredList[i].duration,
                                              !_filteredList[i].open,
                                              _filteredList[i].creationDate,
                                              _filteredList[i].topic,
                                              _filteredList[i].dependentTasks);
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
                                  Text(_filteredList[i].title,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          .copyWith(fontSize: 18)),
                                  if (_filteredList[i].notes.isNotEmpty)
                                    Text(_filteredList[i].notes,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .copyWith(color: Colors.grey))
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              });
        } else {
          return Loading();
        }
      },
    );
  }
}
