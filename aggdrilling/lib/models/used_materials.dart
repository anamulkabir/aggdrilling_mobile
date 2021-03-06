
import 'package:aggdrilling/models/material.dart';
import 'package:aggdrilling/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ConsumeMaterials{
  MaterialItems material;
  double qty;
  User entryBy;
  DateTime entryDate;
  final formatDateTime = DateFormat("yyyy-MM-dd hh:mm:ss a");
  ConsumeMaterials(this.material,this.qty);
  ConsumeMaterials.fromDocumentSnapshot(DocumentSnapshot snapshot){
    this.material = MaterialItems.fromDs(snapshot.data["material"]);
    this.qty = double.parse(snapshot.data["qty"].toString());
    this.entryBy = User.fromDs(snapshot.data["entryBy"]);
    this.entryDate = formatDateTime.parse(snapshot.data["entryDate"]);
  }
  Map<String, dynamic> toJson()=>{
    'material':this.material.toJson(),
    'qty': this.qty,
    'entryBy': this.entryBy.toJson(),
    'entryDate': formatDateTime.format(this.entryDate),
  };
}