import 'package:cloud_firestore/cloud_firestore.dart';

class Holes{
  String code;
  String name;
  Holes(this.code,this.name);
  Holes.fromDs(Map<dynamic,dynamic> ds){
    this.code = ds["code"];
    this.name = ds["name"];
  }
  Holes.fromDocumentSnapShot(DocumentSnapshot snapshot){
    this.code = snapshot.data["code"];
    this.name = snapshot.data["name"];
  }
}