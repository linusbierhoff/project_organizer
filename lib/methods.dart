import 'package:project_organizer/firebase/database.dart';
import 'package:project_organizer/firebase/model.dart';

class Methods {

  DateTime endTime(TaskModel _task, Project project) {
    DateTime _dateTime = DateTime.fromMicrosecondsSinceEpoch(
            project.projectplan[_task.taskID].microsecondsSinceEpoch)
        .add(Duration(minutes: _task.duration));

    int _hours = _dateTime.hour;

    int _subHours = 0;
    int _addDays = 0;

    while (_hours - _subHours > project.workTime) {
      _subHours += project.workTime;
      _addDays += 1;
    }
    if (_dateTime.hour == project.workTime) {
      if (_dateTime.minute > 0) {
        _subHours += project.workTime;
        _addDays += 1;
      }
    }

    _dateTime = _dateTime.add(Duration(days: _addDays));
    _dateTime = _dateTime.subtract(Duration(hours: _subHours));

    return _dateTime;
  }

  Future fillProjectPlan(String projectID) async {
    print("fillProjectPlan started");
    Project databaseProject =
        await DatabaseService(projectID: projectID).projectData.first;

    List<TaskModel> databaseTasks =
        await DatabaseService(projectID: projectID).tasks.first;

    List openTasks = List.from(databaseTasks);
    Map<String, DateTime> registeredTasks = {};

    //check if all tasks have a duration and all tasks have a member
    bool validatePorject() {
      if (databaseTasks.isEmpty) {
        return false;
      }
      for (TaskModel _task in databaseTasks) {
        if (_task.members.isEmpty) {
          print("no member");
          return false;
        }
        if (_task.members[0] == false) {
          print("member does not accepted tasks");
          return false;
        }

        if (_task.duration <= 0) {
          print("no duration");
          return false;
        }
      }
      print("valid project");
      return true;
    }

    //check if alle tasks which are neccessary are registered
    bool allTasksRegistered(List taskIDs) {
      List<String> _registereTasksIDs = registeredTasks.keys.toList();
      for (int i = 0; i < taskIDs.length; i++) {
        if (!_registereTasksIDs.contains(taskIDs[i])) {
          return false;
        }
      }
      return true;
    }

    // get duration of all tasks, which depend on the task
    int durationOfFollowingTasks(TaskModel task) {
      int _length = task.duration;
      List<TaskModel> _tasks = [];

      for (TaskModel currentTask in databaseTasks) {
        if (currentTask.dependentTasks.contains(task.taskID)) {
          _tasks.add(currentTask);
        }
      }
      if (_tasks.isNotEmpty) {
        _tasks.sort((t1, t2) => t1.duration.compareTo(t2.duration));
        _length = _length + durationOfFollowingTasks(_tasks[0]);
      }

      return _length;
    }

    //get Map with possible tasks and duration of all tasks, which depend on the task
    Map<TaskModel, int> possibleTasks() {
      Map<TaskModel, int> possibleTasks = {};
      for (int i = 0; i < openTasks.length; i++) {
        if (openTasks[i].dependentTasks.isNotEmpty) {
          if (allTasksRegistered(openTasks[i].dependentTasks)) {
            possibleTasks[openTasks[i]] =
                durationOfFollowingTasks(openTasks[i]);
          }
        } else {
          possibleTasks[openTasks[i]] = durationOfFollowingTasks(openTasks[i]);
        }
      }
      return possibleTasks;
    }

    //get enddate of alle tasks which are neccessary
    DateTime getFirstPossibleDateofTasks(TaskModel task) {
      DateTime _date = databaseProject.startDate;

      if (task.dependentTasks.isEmpty) {
        return _date;
      }

      for (String _taskID in task.dependentTasks) {
        TaskModel _task =
            DatabaseService().getTaskFromId(_taskID, databaseTasks);

        DateTime _dateTime =
            registeredTasks[_taskID].add(Duration(minutes: _task.duration));

        int _hours = _dateTime.hour;

        int _subHours = 0;
        int _addDays = 0;

        while (_hours - _subHours > databaseProject.workTime) {
          _subHours += databaseProject.workTime;
          _addDays += 1;
        }
        if (_dateTime.hour == databaseProject.workTime) {
          if (_dateTime.minute > 0) {
            _subHours += databaseProject.workTime;
            _addDays += 1;
          }
        }

        _dateTime = _dateTime.add(Duration(days: _addDays));
        _dateTime = _dateTime.subtract(Duration(hours: _subHours));

        if (_dateTime.isAfter(_date)) {
          _date = _dateTime;
        }
      }

      return _date;
    }

    DateTime getFirstPossibleDateOfPerson(String userID) {
      DateTime _date = databaseProject.startDate;
      if (registeredTasks.isEmpty) {
        return _date;
      }

      for (String _taskID in registeredTasks.keys.toList()) {
        TaskModel _task =
            DatabaseService().getTaskFromId(_taskID, databaseTasks);

        if (_task.members.containsKey(userID)) {
          DateTime _dateTime =
              registeredTasks[_taskID].add(Duration(minutes: _task.duration));
          int _hours = _dateTime.hour;

          int _subHours = 0;
          int _addDays = 0;

          while (_hours - _subHours > databaseProject.workTime) {
            _subHours += databaseProject.workTime;
            _addDays += 1;
          }
          if (_dateTime.hour == databaseProject.workTime) {
            if (_dateTime.minute > 0) {
              _subHours += databaseProject.workTime;
              _addDays += 1;
            }
          }

          _dateTime = _dateTime.add(Duration(days: _addDays));
          _dateTime = _dateTime.subtract(Duration(hours: _subHours));

          if (_dateTime.isAfter(_date)) {
            _date = _dateTime;
          }
        }
      }

      return _date;
    }

    DateTime getDate(TaskModel _task) {
      DateTime _date = getFirstPossibleDateofTasks(_task);
      if (_date.hour == databaseProject.workTime) {
        _date = _date.add(Duration(days: 1));
        _date = _date.subtract(Duration(hours: _date.hour));
      }

      List _member = _task.members.keys.toList();
      DateTime _date2 = getFirstPossibleDateOfPerson(_member[0]);

      if (_date2.hour == databaseProject.workTime) {
        _date2 = _date2.add(Duration(days: 1));
        _date2 = _date2.subtract(Duration(hours: _date2.hour));
      }

      if (_date2.isAfter(_date)) {
        return _date2;
      }

      return _date;
    }

    //register task that the program knows it is already registered and task depended on this task are able to register
    void registerTask(TaskModel task, DateTime date) {
      registeredTasks[task.taskID] = date;
      try {
        openTasks.remove(task);
      } catch (e) {
        print(e.toString());
      }
    }

    if (validatePorject()) {
      while (registeredTasks.length < databaseTasks.length) {
        var _mapOfTasks = possibleTasks();
        if (possibleTasks().isEmpty) {
          await DatabaseService().updateProject(
              databaseProject.title,
              databaseProject.subject,
              databaseProject.date,
              databaseProject.open,
              databaseProject.projectID,
              databaseProject.creationDate,
              databaseProject.topics,
              {},
              databaseProject.workTime,
              databaseProject.startDate);
          return "It is not possible to load your projectplan. Please check if there are issuses in the dependencies.";
        }

        //sinnvollste Aufgabe herausfinden
        List<TaskModel> _sortedListOfTasks = _mapOfTasks.keys.toList()
          ..sort((k1, k2) => _mapOfTasks[k2].compareTo(_mapOfTasks[k1]));

        for (TaskModel task in _sortedListOfTasks) {
          registerTask(task, getDate(task));
        }
      }

      await DatabaseService().updateProject(
          databaseProject.title,
          databaseProject.subject,
          databaseProject.date,
          databaseProject.open,
          databaseProject.projectID,
          databaseProject.creationDate,
          databaseProject.topics,
          registeredTasks,
          databaseProject.workTime,
          databaseProject.startDate);

      return "Done";
    } else {
      await DatabaseService().updateProject(
          databaseProject.title,
          databaseProject.subject,
          databaseProject.date,
          databaseProject.open,
          databaseProject.projectID,
          databaseProject.creationDate,
          databaseProject.topics,
          {},
          databaseProject.workTime,
          databaseProject.startDate);
      return "Your project is not valid. Please check if every tasks has a duration and a member which accepts the task.";
    }
  }

  
}
