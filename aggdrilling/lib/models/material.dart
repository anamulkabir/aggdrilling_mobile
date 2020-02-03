
class Material{
  String name;
  String code;
  Material(this.name,this.code);
  Material.fromDs(Map<dynamic,dynamic> ds){
    this.name = ds["name"];
    this.code = ds["code"];
  }
  static List<Material> fromDsList(List<dynamic> sizes)
  {
    List<Material> materialList = sizes.map((entry) => Material.fromDs(entry)).toList();
    return materialList;
  }
}