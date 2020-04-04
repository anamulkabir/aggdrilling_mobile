
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Comments{
  String comment;
  String entryBy;
  DateTime entryDate;
  final formatDateTime = DateFormat("yyyy-MM-dd hh:mm:ss a");
  Comments(this.comment);
  Comments.fromDocumentSnapshot(DocumentSnapshot snapshot){
    this.comment = snapshot.data["comment"];
    this.entryBy = snapshot.data["entryBy"];
    this.entryDate = formatDateTime.parse(snapshot.data["entryDate"]);
  }
  Map<String, dynamic> toJson()=>{
    'comment': this.comment,
    'entryBy': this.entryBy,
    'entryDate': formatDateTime.format(this.entryDate),
  };
}