import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:project_organizer/diagram.dart';
import 'package:project_organizer/firebase/database.dart';
import 'package:project_organizer/loading.dart';

import 'package:project_organizer/projects/project_detail.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../firebase/model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ProjectChart extends StatefulWidget {
  @override
  _ProjectChartState createState() => _ProjectChartState();
}

class _ProjectChartState extends State<ProjectChart> {
  final controller = PageController();
  @override
  Widget build(BuildContext context) {
    final databaseprojects = Provider.of<List<Project>>(context);

    while (databaseprojects == null) {
      return Loading();
    }

    List<Project> getOpenList() {
      List<Project> newList = [];
      for (var i = 0; i < databaseprojects.length; i++) {
        if (databaseprojects[i].open == true) {
          newList.add(databaseprojects[i]);
        }
      }

      newList.sort((a, b) {
        return b.date.compareTo(a.date);
      });
      return newList;
    }

    Color getColor(Project project) {
      var _difference = project.date.difference(DateTime.now());
      print(_difference);
      if (_difference.inDays < 0) {
        return Colors.red;
      } else if (_difference.inDays < 5) {
        return Colors.orange;
      } else {
        return Colors.green;
      }
    }

    void _showDetailedInformation(Project project) {
      showModalBottomSheet(
          backgroundColor: Theme.of(context).canvasColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
          context: context,
          builder: (context) {
            return StreamBuilder<Object>(
                stream: DatabaseService(projectID: project.projectID).tasks,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: [
                        Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(project.title,
                                style: Theme.of(context).textTheme.headline6)),
                        Expanded(
                          child: PageView(
                            controller: controller,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text("Tasks in time",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1),
                                      ),
                                      Expanded(
                                          child: TaskStateDiagram(
                                              project: project)),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Text("Tasks done",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1),
                                        ),
                                        Expanded(
                                            child: TaskDoneDiagram(
                                                project: project)),
                                      ],
                                    )),
                              ),
                            ],
                          ),
                        ),
                        SmoothPageIndicator(
                          controller: controller,
                          count: 2,
                          effect: WormEffect(
                              activeDotColor: Theme.of(context).primaryColor),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 20),
                          child: TextButton(
                            style: ButtonStyle(
                              overlayColor: MaterialStateColor.resolveWith(
                                  (states) => Colors.transparent),
                            ),
                            child: Text(
                              "Go to the Project",
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor),
                            ),
                            onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ProjectView(project.projectID))),
                          ),
                        )
                      ],
                    );
                  } else {
                    return LoadingContainer();
                  }
                });
          });
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
      return Padding(
        padding: const EdgeInsets.only(bottom: 100.0, right: 20, left: 20),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SfCartesianChart(
            isTransposed: true,
            onSelectionChanged: (value) =>
                _showDetailedInformation(getOpenList()[value.pointIndex]),
            plotAreaBorderWidth: 0,
            primaryXAxis: CategoryAxis(
              labelPosition: ChartDataLabelPosition.inside,
              labelStyle: Theme.of(context).textTheme.headline6,
              crossesAt: 0,
              majorGridLines: MajorGridLines(color: Colors.transparent),
              isVisible: true,
              labelPlacement: LabelPlacement.betweenTicks,
            ),
            primaryYAxis: NumericAxis(
                isVisible: false,
                majorGridLines: MajorGridLines(color: Colors.transparent)),
            series: [
              RangeColumnSeries(
                  enableTooltip: false,
                  selectionBehavior: SelectionBehavior(
                    selectedOpacity: 1,
                    unselectedOpacity: 1,
                    enable: true,
                  ),
                  pointColorMapper: (Project project, _) => getColor(project),
                  width: 0.7,
                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                  dataSource: getOpenList(),
                  xValueMapper: (Project project, _) => project.title,
                  lowValueMapper: (Project project, _) =>
                      project.startDate.difference(DateTime.now()).inDays,
                  highValueMapper: (Project project, _) =>
                      project.date.difference(DateTime.now()).inDays),
            ],
            tooltipBehavior:
                TooltipBehavior(enable: true, header: '', canShowMarker: false),
          ),
        ),
      );
    }
  }
}

class ChartData {
  ChartData(
    this.state,
    this.count,
  );
  final String state;
  final int count;
}
