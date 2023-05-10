import 'package:flutter/material.dart';
import 'package:project_organizer/firebase/database.dart';
import 'package:project_organizer/firebase/model.dart';
import 'package:project_organizer/loading.dart';
import 'package:project_organizer/methods.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

//Circle Diagram which shows if tasks are in Time
class TaskStateDiagram extends StatefulWidget {
  final Project project;
  TaskStateDiagram({this.project});
  @override
  _TaskStateDiagramState createState() => _TaskStateDiagramState();
}

class _TaskStateDiagramState extends State<TaskStateDiagram> {
  //TO-DO: include Projectplan
  bool getTaskTimeState(TaskModel task) {
    DateTime now = DateTime.now();
    DateTime _dateTime = DateTime(now.year, now.month, now.day);
    DateTime _endTime = Methods().endTime(task, widget.project);
    DateTime _date = DateTime(_endTime.year, _endTime.month, _endTime.day);



    if (!task.open) {
      return true;
    }

    if (_date.isBefore(_dateTime)) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.project.projectplan == null ||
        widget.project.projectplan.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(15.0),
        child: InkWell(
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey,
            ),
            child: Center(
              child: Text("No Data",
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Theme.of(context).accentColor
                  )),
            ),
          ),
          onTap: () {
            showDialog(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    backgroundColor: Theme.of(context).canvasColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    title: Text("Load your Projectplan"),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text("You have to load your projectplan first!\nThis diagram needs data from your projectplan!"),
                      )
                    ],
                  );
                });
          },
        ),
      );
    }

    return StreamBuilder(
        stream: DatabaseService(projectID: widget.project.projectID).tasks,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          List<TaskModel> tasks = snapshot.data;

          List<ChartData> getTaskTime() {
            int _goodCount = 0;
            int _badCount = 0;
            List<ChartData> _list = [];
            for (int i = 0; i < widget.project.projectplan.length; i++) {
              if (getTaskTimeState(DatabaseService().getTaskFromId(widget.project.projectplan.keys.toList()[i], tasks))) {
                _goodCount++;
              } else {
                _badCount++;
              }
            }
            _list.add(ChartData(false, _badCount));
            _list.add(ChartData(true, _goodCount));
            return _list;
          }

          return SfCircularChart(
            legend: Legend(isVisible: false),
            title: ChartTitle(text: ""),
            series: [
              PieSeries<ChartData, bool>(
                  pointColorMapper: (ChartData data, _) {
                    if (data.state) {
                      return Colors.green;
                    } else {
                      return Colors.red;
                    }
                  },
                  startAngle: 90,
                  endAngle: 90,
                  dataLabelSettings: DataLabelSettings(isVisible: false),
                  explode: false,
                  explodeIndex: 0,
                  dataSource: getTaskTime(),
                  xValueMapper: (ChartData data, _) {
                    return data.state;
                  },
                  yValueMapper: (ChartData data, _) {
                    return data.count;
                  })
            ],
          );
        });
  }
}

//Circle Diagram which showes done tasks

class TaskDoneDiagram extends StatefulWidget {
  final Project project;
  TaskDoneDiagram({this.project});
  @override
  _TaskDoneDiagramState createState() => _TaskDoneDiagramState();
}

class _TaskDoneDiagramState extends State<TaskDoneDiagram> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: DatabaseService(projectID: widget.project.projectID).tasks,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return LoadingContainer();
          }
          List<TaskModel> tasks = snapshot.data;

          List<ChartData> getTaskState() {
            int _openCount = 0;
            int _doneCount = 0;
            List<ChartData> _list = [];
            print("Länge: " + tasks.length.toString());
            for (int i = 0; i < tasks.length; i++) {
              if (tasks[i].open) {
                _openCount++;
              } else {
                _doneCount++;
              }
            }
            _list.add(ChartData(true, _doneCount));
            _list.add(ChartData(false, _openCount));
            return _list;
          }

          return SfCircularChart(
            legend: Legend(isVisible: false),
            title: ChartTitle(text: ""),
            series: [
              PieSeries<ChartData, bool>(
                  pointColorMapper: (ChartData data, _) {
                    if (data.state) {
                      return Colors.green;
                    } else {
                      return Colors.orange;
                    }
                  },
                  startAngle: 90,
                  endAngle: 90,
                  dataLabelSettings: DataLabelSettings(isVisible: false),
                  explode: false,
                  explodeIndex: 0,
                  dataSource: getTaskState(),
                  xValueMapper: (ChartData data, _) {
                    return data.state;
                  },
                  yValueMapper: (ChartData data, _) {
                    return data.count;
                  })
            ],
          );
        });
  }
}

class ChartData {
  ChartData(
    this.state,
    this.count,
  );
  final bool state;
  final int count;
}
