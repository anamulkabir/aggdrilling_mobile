import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialItems{
  String name;
  String details;
  String refkey;
  String unit;
  String unitPrice;
  MaterialItems(this.name,this.details);
  MaterialItems.fromDs(Map<dynamic,dynamic> ds){
    this.name = ds["name"];
    this.details = ds["details"];
  }
  MaterialItems.fromDocument(DocumentSnapshot snapshot){

      this.name = snapshot.data["name"];
      this.details = snapshot.data["details"];
      this.refkey = snapshot.data["refKey"];
      this.unit = snapshot.data["unit"];
      this.unitPrice = snapshot.data["unitPrice"].toString();
  }
  Map<String, dynamic> toJson()=>{
    'name': this.name,
    'details': this.details,
    'refKey': this.refkey,
    'unit': this.unit,
    'unitPrice': this.unitPrice,
  };
}