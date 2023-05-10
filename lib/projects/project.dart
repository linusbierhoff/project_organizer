import 'package:flutter/material.dart';
import 'package:project_organizer/firebase/model.dart';
import 'package:project_organizer/loading.dart';
import 'package:provider/provider.dart';
import 'projects_list.dart';
import 'projects_chart.dart';
import 'package:project_organizer/projects/projects_list.dart';
import '../firebase/database.dart';

class Projects extends StatefulWidget {
  @override
  _ProjectsState createState() => _ProjectsState();
}

class _ProjectsState extends State<Projects> {
  @override
  Widget build(BuildContext context) {
    var _currentUser = Provider.of<UserModel>(context);
    while (_currentUser == null) {
      return Loading();
    }
    return MultiProvider(
        providers: [
          StreamProvider<List<Project>>.value(
              value: DatabaseService(currentUser: _currentUser).projects,
              initialData: null,
              catchError: (_, err) => null),
          StreamProvider<List<UserModel>>.value(
            value: DatabaseService().user,
            initialData: null,
          )
        ],
        child: Builder(builder: (BuildContext context) {
          return DefaultTabController(
            length: 2,
            child: NestedScrollView(
              physics: NeverScrollableScrollPhysics(),
              headerSliverBuilder: (context, value) {
                return [
                  SliverAppBar(
                    floating: true,
                    pinned: true,
                    snap: false,
                    elevation: 0.0,
                    shadowColor: Colors.transparent,
                    title: Text(
                      'Projects',
                    ),
                    bottom: TabBar(
                      tabs: [
                        Tab(
                          icon: Icon(Icons.auto_awesome_motion),
                        ),
                        Tab(
                          icon: Icon(Icons.bar_chart),
                        ),
                      ],
                      
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.1),
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorColor:  Theme.of(context).primaryColor,
                    ),
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  ProjectsList(),
                  ProjectChart(),
                ],
              ),
            ),
          );
        }));
  }
}
