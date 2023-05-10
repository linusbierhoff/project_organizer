import 'package:flutter/material.dart';
import 'package:project_organizer/firebase/database.dart';
import 'package:project_organizer/firebase/model.dart';
import 'package:project_organizer/loading.dart';
import 'package:project_organizer/pdf.dart';
import 'package:project_organizer/research/create_research.dart';
import 'package:project_organizer/research/edit_research.dart';
<<<<<<< Updated upstream

=======
>>>>>>> Stashed changes

class Research extends StatefulWidget {
  final Project project;
  Research(this.project);
  @override
  _ResearchState createState() => _ResearchState();
}

class _ResearchState extends State<Research> {
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
        ResearchList(widget.project, null),
        ResearchList(widget.project, "")
      ];
      for (int i = 0; i < widget.project.topics.length; i++) {
        childrenList
            .add(ResearchList(widget.project, widget.project.topics[i]));
      }
      return childrenList;
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AddResearch(widget.project),
          ),
        ),
        child: Icon(Icons.add, color: Theme.of(context).primaryColor),
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
                title: Text('Research'),
                actions: [
                  IconButton(
                      icon: Icon(Icons.upload_file),
                      onPressed: () async {
                        final pdfFile =
                            await PdfService(project: widget.project)
                                .createPDFFromSources();
                        PdfService().openFile(pdfFile);
                      }),
                ],
                bottom: TabBar(
                  isScrollable: true,
                  tabs: getTabs(),
                  unselectedLabelColor: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .color
                      .withOpacity(0.5),
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: Color.fromRGBO(59, 217, 209, 1),
                  indicatorColor: Color.fromRGBO(59, 217, 209, 1),
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

class ResearchList extends StatefulWidget {
  final Project project;
  final String filter;
  ResearchList(this.project, this.filter);
  @override
  _ResearchListState createState() => _ResearchListState();
}

class _ResearchListState extends State<ResearchList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream:
            DatabaseService(projectID: widget.project.projectID).information,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<ResearchModel> researches = snapshot.data;

            List<ResearchModel> getFilteredList() {
              if (widget.filter != null) {
                List<ResearchModel> _list = [];
                for (int i = 0; i < researches.length; i++) {
                  if (researches[i].topic == widget.filter) {
                    _list.add(researches[i]);
                  }
                }
                return _list;
              } else {
                return researches;
              }
            }

            return ListView.builder(
                itemCount: getFilteredList().length,
                itemBuilder: (context, i) {
                  return Padding(
                      padding: EdgeInsets.only(
                          left: 20, right: 20, top: 10, bottom: 10),
                      child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => EditResearch(
                                    getFilteredList()[i], widget.project)));
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                                left: 20, top: 10, bottom: 10, right: 20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Theme.of(context).canvasColor),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  getFilteredList()[i].title,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(getFilteredList()[i].text,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.normal)),
                              ],
                            ),
                          )));
                });
          } else {
            return LoadingContainer();
          }
        });
  }
}
