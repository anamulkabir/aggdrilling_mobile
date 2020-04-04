
import 'package:aggdrilling/models/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ConsumeMaterials{
  MaterialItems material;
  double qty;
  String entryBy;
  DateTime entryDate;
  final formatDateTime = DateFormat("yyyy-MM-dd hh:mm:ss a");
  ConsumeMaterials(this.material,this.qty);
  ConsumeMaterials.fromDocumentSnapshot(DocumentSnapshot snapshot){
    this.material = MaterialItems.fromDs(snapshot.data["material"]);
    this.qty = snapshot.data["qty"];
    this.entryBy = snapshot.data["entryBy"];
    this.entryDate = formatDateTime.parse(snapshot.data["entryDate"]);
  }
  Map<String, dynamic> toJson()=>{
    'material':this.material.toJson(),
    'qty': this.qty,
    'entryBy': this.entryBy,
    'entryDate': formatDateTime.format(this.entryDate),
  };
}