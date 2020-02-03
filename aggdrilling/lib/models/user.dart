import 'package:firebase_database/firebase_database.dart';

class User{
  String name;
  String phone;
  List<Permit> permitProjects;
  User.fromSnapshot(DataSnapshot snapshot)
  {
    this.name = snapshot.value["name"];
    this.phone = snapshot.value["phone"];
    this.permitProjects = Permit.fromDsList(snapshot.value["permitProjects"]);
  }
}
class Permit{
  String code;
  List<String> permitSteps;
  Permit(this.code,this.permitSteps);
  Permit.fromDs(Map<dynamic,dynamic> permit)
  {
    this.code = permit["code"];
    this.permitSteps = List.from(permit["permitSteps"]);
  }
  static List<Permit> fromDsList(List<dynamic> permits)
  {
    List<Permit> permitList = permits.map((entry) => Permit.fromDs(entry)).toList();
    return permitList;
  }

}