import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialItems{
  String name;
  String details;
  String refkey;
  String materialId;
  String unit;
  String unitPrice;
  MaterialItems(this.name,this.details);
  MaterialItems.fromDs(Map<dynamic,dynamic> ds){
    this.name = ds["name"];
    this.details = ds["details"];
  }
  MaterialItems.fromDocument(DocumentSnapshot snapshot){

      this.name = snapshot.data["name"];
      this.details = snapshot.data["details"]==null?"": snapshot.data["details"];
      this.refkey = snapshot.data["refKey"];
      this.materialId = snapshot.data["materialId"];
      this.unit = snapshot.data["unit"]==null?"":snapshot.data["unit"];
      this.unitPrice = snapshot.data["unitPrice"]==null?"":snapshot.data["unitPrice"].toString();
  }
  Map<String, dynamic> toJson()=>{
    'name': this.name,
    'details': this.details,
    'refKey': this.refkey,
    'materialId':this.materialId,
    'unit': this.unit,
    'unitPrice': this.unitPrice,
  };
}