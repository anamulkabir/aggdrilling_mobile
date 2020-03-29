
import 'package:aggdrilling/models/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConsumeMaterials{
  MaterialItems material;
  double qty;
  String entryBy;
  DateTime entryDate;
  ConsumeMaterials(this.material,this.qty);
  ConsumeMaterials.fromDocumentSnapshot(DocumentSnapshot snapshot){
    this.material = snapshot.data["material"];
    this.qty = snapshot.data["qty"];
    this.entryBy = snapshot.data["entryBy"];
    this.entryDate = snapshot.data["entryDate"];
  }
}