
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkSheetStatus{
  String status;
  String entryBy;
  DateTime entryDate;
  WorkSheetStatus(this.status);
  WorkSheetStatus.fromDocumentSnapshot(DocumentSnapshot snapshot){
    this.status = snapshot.data["status"];
    this.entryBy = snapshot.data["entryBy"];
    this.entryDate = snapshot.data["entryDate"];
  }
}