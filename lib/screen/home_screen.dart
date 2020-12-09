import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_assignment/common/constant.dart';
import 'package:flutter_assignment/model/home_list_model.dart';
import 'package:flutter_assignment/network/live_data_manager.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:refreshable_reorderable_list/refreshable_reorderable_list.dart';

import 'edit_task_widget.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LiveDataManager liveDataManager = LiveDataManager();
  List<HomeListModel> homeList = [];

  @override
  void initState() {
    super.initState();
    Fluttertoast.showToast(
        msg: 'Fetching List...',
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_LONG);
    readData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            //openInputScreen(context);
            showGeneralDialog(
              context: context,
              barrierDismissible: false,
              barrierLabel: "Dialog",
              transitionDuration: Duration(milliseconds: 200),
              pageBuilder: (_, __, ___) {
                // widget implementation
                return NewTaskWidget(onTaskSubmitted: (String submittedText) {
                  Navigator.pop(context);
                  openInputScreen(context, submittedText);
                });
              },
            );
          },
          child: RefreshableReorderableListView(
            onReorder: _onReorder,
            physics: AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 0.0),
            scrollDirection: Axis.vertical,
            children: List.generate(
              homeList.length,
              (index) {
                var item = homeList[index];
                final completed = item.completed;
                return Slidable(
                  enabled: completed ? false : true,
                  key: Key(UniqueKey().toString()),
                  actionPane: SlidableDrawerActionPane(),
                  actionExtentRatio: 0.25,
                  child: Container(
                    color: completed
                        ? (Colors.green[100 + (-item.position % 9) * 100])
                        : Colors.deepOrange[100 + index % 9 * 100],
                    child: ListTile(
                      onLongPress: completed ? () {} : null,
                      title: Text(
                        '${item.task}',
                        style: TextStyle(
                          decoration:
                              completed ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    IconSlideAction(
                      caption: 'Complete',
                      color: Colors.blue,
                      icon: Icons.assignment_turned_in_outlined,
                      onTap: () => completeData(item.id, index),
                    ),
                  ],
                  secondaryActions: <Widget>[
                    IconSlideAction(
                      caption: 'Remove',
                      color: Colors.amber,
                      icon: Icons.delete,
                      onTap: () => deleteData(item.id, index),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    print('oldIndex: $oldIndex, newIndex: $newIndex');
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    if (homeList[oldIndex].completed || homeList[newIndex].completed) {
      return;
    }

    int newPosition = 0;
    List<HomeListModel> newList = [];
    if (oldIndex - newIndex == 1 || newIndex - oldIndex == 1) {
      newPosition = homeList[newIndex].position;
      homeList[newIndex].position = homeList[oldIndex].position;
      swapLocationItems(oldIndex, newIndex, newPosition);
      newList.add(homeList[oldIndex]);
      newList.add(homeList[newIndex]);
    } else if (newIndex == 0) {
      newPosition = homeList[newIndex].position + DISTANCE;
      swapLocationItems(oldIndex, 0, newPosition);
      newList.add(homeList[0]);
    } else if (newIndex + 1 == homeList.length ||
        homeList[newIndex + 1].completed) {
      if (homeList[newIndex].position != 0) {
        swapLocationItems(oldIndex, newIndex, 0);
        newList.add(homeList[newIndex]);
      } else {
        int belowPosition = 0;
        int upperPosition = homeList[newIndex - 1].position;
        swapLocationItems(oldIndex, newIndex, 0);
        if (upperPosition - belowPosition > 1) {
          newPosition =
              belowPosition + ((upperPosition - belowPosition) / 2).toInt();
          homeList[newIndex - 1].position = newPosition;
          newList.add(homeList[newIndex - 1]);
          newList.add(homeList[newIndex]);
        } else {
          reAssignAllPosition();
        }
      }
    } else {
      swapLocationItems(oldIndex, newIndex, newPosition);
      int belowPosition = homeList[newIndex + 1].position;
      int upperPosition = homeList[newIndex - 1].position;
      if (upperPosition - belowPosition > 1) {
        newPosition =
            belowPosition + ((upperPosition - belowPosition) / 2).toInt();
        homeList[newIndex].position = newPosition;
        newList.add(homeList[newIndex]);
      } else {
        reAssignAllPosition();
      }
    }

    for (int i = 0; i < newList.length; i++) {
      updateData(newList[i].id, newList[i].position);
    }
    print('New Position: $newPosition');
  }

  void reAssignAllPosition() {
    int position = 0;
    for (int i = homeList.length - 1; i >= 0; i--) {
      final item = homeList[i];
      if (!item.completed) {
        item.position = position;
        updateData(item.id, item.position);
        position += DISTANCE;
      }
    }
  }

  void swapLocationItems(int oldIndex, int newIndex, int newPosition) {
    setState(() {
      final HomeListModel item = homeList.removeAt(oldIndex);
      item.position = newPosition;
      homeList.insert(newIndex, item);
    });
  }

  void openInputScreen(BuildContext context, String result) {
    //final result = await Navigator.pushNamed(context, INPUT_SCREEN);
    if (result != null && result.toString().trim().length > 0) {
      int position =
          homeList.length == 0 ? 0 : (homeList.first.position + DISTANCE);
      String id = UniqueKey().hashCode.toString();
      homeList.add(HomeListModel(result, false, position, id));
      setState(() {
        sort();
        print(homeList);
      });
      sendData(result, false, position, id);
    }
  }

  void readData() async {
    DataSnapshot snapshot = await liveDataManager.readData();
    print('Data : ${snapshot.value}');
    if (snapshot.value != null) {
      var map = snapshot.value[FLUTTER];
      map.forEach((k, v) {
        //print('${k}: ${v['text']}');
        homeList.add(HomeListModel(v[TASK], v[COMPLETED], v[POSITION], v[ID]));
      });
      setState(() {
        sort();
      });
    } else {
      Fluttertoast.showToast(
          msg: 'List is Blank. Drag from Top to create',
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_LONG);
    }
  }

  void sendData(String task, bool isDisabled, int position, String id) async {
    await liveDataManager.sendData(task, isDisabled, position, id);
  }

  void deleteData(String id, int index) async {
    setState(() {
      homeList.removeAt(index);
    });
    await liveDataManager.deleteData(id, index);
  }

  void updateData(String id, int index) async {
    await liveDataManager.updateData(id, index);
  }

  void completeData(String id, int index) async {
    int lastItemPosition = homeList.last.position;
    int newPosition = lastItemPosition >= 0 ? -1 : lastItemPosition - 1;
    setState(() {
      final HomeListModel item = homeList.removeAt(index);
      item.completed = true;
      item.position = newPosition;
      homeList.add(item);
    });
    await liveDataManager.completeData(id, newPosition);
  }

  void sort() {
    //Reverse the list to show in reverse order
    homeList.sort((a, b) {
      var aPosition = a.position;
      var bPosition = b.position;
      return bPosition.compareTo(aPosition);
    });
  }
}
