import 'package:aggdrilling/models/app_settings.dart';
import 'package:aggdrilling/models/project.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
typedef void OnCompleteLoad(User user);

class User{
  String firstName;
  String middleName;
  String lastName;
  String email;
  String phone;
  String role;
  List<PermitProjects> permitProjects;
  AppSettings appSettings;
  User.fromSnapshot(DocumentSnapshot snapshot)
  {
    this.firstName = snapshot.data["firstName"];
    this.lastName = snapshot.data["lastName"];
    this.email = snapshot.data["email"];
    this.phone = snapshot.data["phone"];
    this.role = snapshot.data["role"];
    this.permitProjects =  this.getAllPermitsFromDocumentSnapshot(snapshot);

  }
  User.fromDs(Map<dynamic, dynamic> ds){
    this.firstName = ds["firstName"];
    this.lastName = ds["lastName"];
    this.email = ds["email"];
    this.phone = ds["phone"];
    this.role = ds["role"];
  }
  void setAppSettingsFromSnapshot(DocumentSnapshot snapshot){
    this.appSettings = AppSettings.fromDocumentSnapShot(snapshot);
  }
  Map<String, dynamic> toJson()=>{
    'firstName': this.firstName,
    'lastName': this.lastName,
    'email': this.email,
    'phone': this.phone,
    'role': this.role
  };
  List<PermitProjects> getAllPermitsFromDocumentSnapshot(DocumentSnapshot snapshot){
    List<PermitProjects> permits = new List();
    snapshot.reference.collection("permitProjects").getDocuments().then((QuerySnapshot querySnapShot){
      for(DocumentSnapshot document in querySnapShot.documents)
      {
        permits.add(PermitProjects.fromDoc(document));
      }
      return permits;
    });

  }
  List<PermitProjects> getAllPermits(DocumentSnapshot snapshot,OnCompleteLoad _OnLoadComplete) {
    this.permitProjects = new List();
    snapshot.reference.collection("permitProjects").getDocuments().then((QuerySnapshot querySnapShot){
      for(DocumentSnapshot document in querySnapShot.documents)
        {
          this.permitProjects.add(PermitProjects.fromDoc(document));
        }
    _OnLoadComplete(this);
    });
  }

  List<String> getProjectCode()
  {
    List<String> projectCodes =[];
    for(PermitProjects permit in this.permitProjects)
      {
        projectCodes.add(permit.permitProject.projectCode);
      }
    return projectCodes;
  }
  PermitProjects getUserPermitProjectByCode(String code)
  {
    PermitProjects permitProjects;
    for(PermitProjects permit in this.permitProjects)
    {
      if(permit.permitProject.projectCode.contains(code))
        permitProjects = permit;
    }
    return permitProjects;
  }
}
class PermitProjects{
  Project permitProject;
  List<String> permitSteps;

  PermitProjects(this.permitProject,this.permitSteps);

  
  PermitProjects.fromDoc(DocumentSnapshot documentSnapshot)
  {
    this.permitProject = Project.fromDs(documentSnapshot.data["project"]);
   this.permitSteps = List.from(documentSnapshot.data["permitSteps"]);
  }

}
