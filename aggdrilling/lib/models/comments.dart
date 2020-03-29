
import 'package:cloud_firestore/cloud_firestore.dart';

class Comments{
  String comment;
  String entryBy;
  DateTime entryDate;
  Comments(this.comment);
  Comments.fromDocumentSnapshot(DocumentSnapshot snapshot){
    this.comment = snapshot.data["comment"];
    this.entryBy = snapshot.data["entryBy"];
    this.entryDate = snapshot.data["entryDate"];
  }
}