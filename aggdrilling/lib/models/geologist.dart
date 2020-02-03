
class Geologist{
  String name;
  String phone;
  String address;
  String email;
  Geologist(this.name,this.phone,this.address,this.email);
  Geologist.fromDs(Map<dynamic,dynamic> ds){
    this.name = ds["name"];
    this.phone = ds["phone"];
    this.address = ds["address"];
    this.email = ds["email"];
  }
  static List<Geologist> fromDsList(List<dynamic> sizes)
  {
    List<Geologist> geologistList = sizes.map((entry) => Geologist.fromDs(entry)).toList();
    return geologistList;
  }
}