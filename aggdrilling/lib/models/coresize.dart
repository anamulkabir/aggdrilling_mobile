class CoreSize{
  String core;
  String size;
  String whole;
  CoreSize(this.core, this.size, this.whole);
  CoreSize.fromDs(Map<dynamic,dynamic> ds){
    this.core = ds["core"].toString();
    this.size = ds["size"];
    this.whole = ds["whole"].toString();
  }
  static List<CoreSize> fromDsList(List<dynamic> sizes)
  {
    List<CoreSize> coreSizeList = sizes.map((entry) => CoreSize.fromDs(entry)).toList();
    return coreSizeList;
  }

}