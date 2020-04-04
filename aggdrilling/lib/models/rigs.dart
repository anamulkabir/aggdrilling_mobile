import 'package:cloud_firestore/cloud_firestore.dart';

class Rigs{
  String rid;
  String serial;
  String status;
  Rigs(this.rid,this.serial);
  Rigs.fromDs(Map<dynamic,dynamic> ds){
    if(ds == null) return;
    this.rid = ds["rid"];
    this.serial = ds["serial"];
    this.status = ds["status"];
  }
  Rigs.fromDocumentSnapshot(DocumentSnapshot snapshot){
    this.rid = snapshot.data["rid"];
    this.serial = snapshot.data["serial"];
    this.status = snapshot.data["status"];
  }
  Map<dynamic,dynamic> toJson()=>
      {
        'rid': this.rid,
        'serial': this.serial,
        'status': this.status,
      };
}
