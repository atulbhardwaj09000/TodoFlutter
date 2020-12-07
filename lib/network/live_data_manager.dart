import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_assignment/common/constant.dart';

class LiveDataManager {
  var databaseReference;

  LiveDataManager() {
    databaseReference = FirebaseDatabase.instance.reference();
  }

  Future<DataSnapshot> readData() async {
    DataSnapshot snapshot = await databaseReference.once();
    return snapshot;
  }

  Future sendData(String task, bool isDisabled, int position, String id) async {
    await databaseReference
        .child(FLUTTER)
        .child(id)
        .set({TASK: task, COMPLETED: false, POSITION: position, ID: id});
  }

  Future deleteData(String id, int index) async {
    await databaseReference.child(FLUTTER).child(id).remove();
  }

  Future updateData(String id, int index) async {
    await databaseReference.child(FLUTTER).child(id).update({POSITION: index});
  }

  Future completeData(String id, int newPosition) async {
    await databaseReference
        .child(FLUTTER)
        .child(id)
        .update({COMPLETED: true, POSITION: newPosition});
  }
}
