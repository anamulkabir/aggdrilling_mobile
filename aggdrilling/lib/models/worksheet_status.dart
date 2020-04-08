
import 'package:aggdrilling/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class WorkSheetStatus{
  String status;
  User entryBy;
  DateTime entryDate;
  final formatDateTime = DateFormat("yyyy-MM-dd hh:mm:ss a");
  WorkSheetStatus(this.status);
  WorkSheetStatus.fromDs(Map<String, dynamic> ds){
    this.status = ds["status"];
    this.entryBy = User.fromDs(ds["entryBy"]);
    this.entryDate = formatDateTime.parse(ds["entryDate"]);
  }
  WorkSheetStatus.fromDocumentSnapshot(DocumentSnapshot snapshot){
    this.status = snapshot.data["status"];
    this.entryBy = User.fromDs(snapshot.data["entryBy"]);
    this.entryDate = formatDateTime.parse(snapshot.data["entryDate"]);
  }
  Map<String, dynamic> toJson()=>{
    'status': this.status,
    'entryBy': this.entryBy.toJson(),
    'entryDate': formatDateTime.format(this.entryDate),
  };
}