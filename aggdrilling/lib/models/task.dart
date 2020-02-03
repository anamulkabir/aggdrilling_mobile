
class Task
{
  String name;
  Type type;
  Task(this.name,this.type);
  Task.fromDs(Map<dynamic,dynamic> ds){
    this.name = ds["core"].toString();
    this.type = Type.values.firstWhere((entry) => entry.toString().toLowerCase()==ds["type"].toString().toLowerCase());
  }
  static List<Task> fromDsList(List<dynamic> sizes)
  {
    List<Task> taskList = sizes.map((entry) => Task.fromDs(entry)).toList();
    return taskList;
  }

}
enum Type{
  EmpHoursOnly,
  EmpHoursWithMeasure,
  EmpHoursNoTask,
  HoursOnly,
  None
}