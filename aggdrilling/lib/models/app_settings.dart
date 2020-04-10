
import 'package:cloud_firestore/cloud_firestore.dart';

class AppSettings{
  String dayShiftStart;
  String dayShiftEnd;
  List<StageDetails> stageDetails;
  AppSettings.fromDocumentSnapShot(DocumentSnapshot snapshot){
    try{
      this.dayShiftStart = snapshot.data["dayShiftStart"];
      this.dayShiftEnd = snapshot.data["dayShiftEnd"];
      this.stageDetails = snapshot['stageNames'].map<StageDetails>((item) {
        return StageDetails.fromMap(item);
      }).toList();

    }
    catch(error){
      throw error;
    }


  }
  String getStageDetails(String name){
    if(name ==null || name.isEmpty){
      if(stageDetails !=null && stageDetails.length>0){
        return stageDetails[0].description;
      }
      else {
        return "Operator";
      }
    }

    for(StageDetails  details in stageDetails){
      if(details.name.toLowerCase()==name.toLowerCase()){
        return details.description;
      }
    }
    return name;
  }
}
class StageDetails{
  String name;
  String description;
  StageDetails.fromDocumentSnapShot(DocumentSnapshot snapshot){
    this.name = snapshot.data["name"];
    this.description = snapshot.data["description"];
  }
  StageDetails.fromMap(Map<dynamic, dynamic> ds){
    this.name = ds["name"];
    this.description = ds["description"];
  }

}