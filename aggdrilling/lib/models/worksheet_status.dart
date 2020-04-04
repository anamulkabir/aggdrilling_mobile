
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class WorkSheetStatus{
  String status;
  String entryBy;
  DateTime entryDate;
  final formatDateTime = DateFormat("yyyy-MM-dd hh:mm:ss a");
  WorkSheetStatus(this.status);
  WorkSheetStatus.fromDs(Map<String, dynamic> ds){
    this.status = ds["status"];
    this.entryBy = ds["entryBy"];
    this.entryDate = formatDateTime.parse(ds["entryDate"]);
  }
  WorkSheetStatus.fromDocumentSnapshot(DocumentSnapshot snapshot){
    this.status = snapshot.data["status"];
    this.entryBy = snapshot.data["entryBy"];
    this.entryDate = formatDateTime.parse(snapshot.data["entryDate"]);
  }
  Map<String, dynamic> toJson()=>{
    'status': this.status,
    'entryBy': this.entryBy,
    'entryDate': formatDateTime.format(this.entryDate),
  };
}