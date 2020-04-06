
import 'package:aggdrilling/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Comments{
  String comment;
  User entryBy;
  DateTime entryDate;
  final formatDateTime = DateFormat("yyyy-MM-dd hh:mm:ss a");
  Comments(this.comment);
  Comments.fromDocumentSnapshot(DocumentSnapshot snapshot){
    this.comment = snapshot.data["comment"];
    this.entryBy = User.fromDs(snapshot.data["entryBy"]);
    this.entryDate = formatDateTime.parse(snapshot.data["entryDate"]);
  }
  Map<String, dynamic> toJson()=>{
    'comment': this.comment,
    'entryBy': this.entryBy.toJson(),
    'entryDate': formatDateTime.format(this.entryDate),
  };
}