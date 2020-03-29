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
  User.fromSnapshot(DocumentSnapshot snapshot)
  {
    this.firstName = snapshot.data["firstName"];
    this.lastName = snapshot.data["lastName"];
    this.email = snapshot.data["email"];
    this.phone = snapshot.data["phone"];
    this.role = snapshot.data["role"];
    this.permitProjects =  this.getAllPermitsFromDocumentSnapshot(snapshot);
  }
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