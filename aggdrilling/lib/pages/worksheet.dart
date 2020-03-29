import 'package:aggdrilling/models/comments.dart';
import 'package:aggdrilling/models/coresize.dart';
import 'package:aggdrilling/models/holes.dart';
import 'package:aggdrilling/models/material.dart';
import 'package:aggdrilling/models/project.dart';
import 'package:aggdrilling/models/rigs.dart';
import 'package:aggdrilling/models/task.dart';
import 'package:aggdrilling/models/task_log.dart';
import 'package:aggdrilling/models/used_materials.dart';
import 'package:aggdrilling/models/user.dart';
import 'package:aggdrilling/models/worker.dart';
import 'package:aggdrilling/models/worksheet.dart';
import 'package:aggdrilling/models/worksheet_status.dart';
import 'package:aggdrilling/models/worsheet_stage.dart';
import 'package:aggdrilling/utils/input_format.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';

class WorkSheetPage extends StatefulWidget{
  WorkSheetPage({this.mWorkSheet,this.mProject,this.mUser});
  WorkSheet mWorkSheet;
  final Project mProject;
  final User mUser;
  @override
  State<StatefulWidget> createState() {
    return new _WorkSheetPageState();
  }

}
class _WorkSheetPageState extends State<WorkSheetPage>{
  bool _isLoading;
  final format = DateFormat("yyyy-MM-dd");
  final timeFormat = DateFormat("hh:mm a");
  final  _dbReference = Firestore.instance.collection('projects');
  final _formKey = GlobalKey<FormState>();
  Rigs _selectedRigs;
  Holes _selectedHoles;
  Worker _selectedWorker;
  Task _selectedTask;
  CoreSize _selectedCoreSize;
  MaterialItems _selectedMaterial;
  ConsumeMaterials _selectedUsedMaterial;
  double _startMeter;
  double _endMeter;
  String _selectedNote;
  List<TaskLog> _taskLogs = new List();
  List<ConsumeMaterials> _consumeMaterials = new List();
  List<Comments> _comments;
  List<String> _nextStages = new List();
  WorkSheetStage _worksheetStages;
  WorkSheetStatus _workSheetStatus;
  String _selectedStatus;
  AutoCompleteTextField<Rigs> ddlRigs;
  AutoCompleteTextField<Holes> ddlHoles;
  AutoCompleteTextField<Task> ddlTasks;
  AutoCompleteTextField<CoreSize> ddlCoreSize;
  AutoCompleteTextField<Worker> ddlWorker;
  AutoCompleteTextField<MaterialItems> ddlMaterials;
  AutoCompleteTextField<String> ddlNextStages;
  GlobalKey keyRigs = new GlobalKey<AutoCompleteTextFieldState<Rigs>>();
  GlobalKey keyHoles = new GlobalKey<AutoCompleteTextFieldState<Holes>>();
  GlobalKey keyWorker = new GlobalKey<AutoCompleteTextFieldState<Worker>>();
  GlobalKey keyCoreSize = new GlobalKey<AutoCompleteTextFieldState<CoreSize>>();
  GlobalKey keyTasks = new GlobalKey<AutoCompleteTextFieldState<Task>>();
  GlobalKey keyMaterialItems = new GlobalKey<AutoCompleteTextFieldState<MaterialItems>>();
  GlobalKey keyNextStages = new GlobalKey<AutoCompleteTextFieldState<String>>();
  final DateTimeWrapper _workDate = new DateTimeWrapper(dateTime:DateTime.now());
  TimeWrapper _startTime = new TimeWrapper(timeOfDay: TimeOfDay.now());
  TimeWrapper _endTime = new TimeWrapper(timeOfDay: TimeOfDay.now());
  bool taskLogAddNew = true;
  bool addNewMaterial = true;
  bool addNewRemark = true;
  bool worksheetUpdate = false;

  int taskIndexForUpdate = -1;
  int usedMaterialIndexForUpdate = -1;
  final rigController = new TextEditingController();
  final holeController = new TextEditingController();
  final taskController = new TextEditingController();
  final workerController = new TextEditingController();
  final noteController = new TextEditingController();
  final startMController = new TextEditingController();
  final endMController = new TextEditingController();
  final coreSizeController = new TextEditingController();
  final materialItemController = new TextEditingController();
  final materialQtyController = new TextEditingController();
  final commentController = new TextEditingController();
  final nextStagesController = new TextEditingController();


  @override
  void initState() {
    super.initState();
    ddlRigs = new AutoCompleteTextField<Rigs>(
      decoration: new InputDecoration(
        labelText: 'Rigs',
        hintText: 'Select Rigs',
      ),
        itemSubmitted: (item) {
        setState(() {
          _selectedRigs = item;
          rigController.text=_selectedRigs.serial;
        });
        },
        key: keyRigs,
        clearOnSubmit: false,
        minLength: 0,
        suggestions: widget.mProject.rigs,
        itemBuilder: (context,suggestion) => new Padding(
            child: new ListTile(
              title: new Text(suggestion.serial,
              ),
            ),
          padding: EdgeInsets.all(8.0),
        ),
        controller: rigController,
        itemSorter: (a, b) => a.serial.compareTo(b.serial),
        itemFilter: (suggestion,input) =>
            suggestion.serial.toLowerCase().startsWith(input.toLowerCase())
    );
    ddlHoles = new AutoCompleteTextField<Holes>(
        decoration: new InputDecoration(
          labelText: 'Holes',
          hintText: 'Select Holes',
        ),
        itemSubmitted: (item) {
          setState(() {
            _selectedHoles = item;
            holeController.text=_selectedHoles.name;
          });
        },
        key: keyHoles,
        clearOnSubmit: false,
        minLength: 0,
        suggestions: widget.mProject.holes,
        itemBuilder: (context,suggestion) => new Padding(
          child: new ListTile(
            title: new Text(suggestion.name,
            ),
          ),
          padding: EdgeInsets.all(8.0),
        ),
        controller: holeController,
        itemSorter: (a, b) => a.name.compareTo(b.name),
        itemFilter: (suggestion,input) =>
            suggestion.name.toLowerCase().startsWith(input.toLowerCase())
    );
    ddlTasks = new AutoCompleteTextField<Task>(
      decoration: new InputDecoration(
        labelText: 'Tasks',
        hintText: 'Select Task',
      ),
      itemSubmitted: (item) {
        setState(() {
          _selectedTask = item;
          taskController.text=_selectedTask.name;
        });
      },
      key: keyTasks,
      clearOnSubmit: false,
      minLength: 0,
      suggestions: widget.mProject.tasks,
      itemBuilder: (context,suggestion) => new Padding(
        child: new ListTile(
          title: new Text(suggestion.name),
        ),
        padding: EdgeInsets.all(8.0),
      ),
      controller: taskController,
      itemSorter: (a, b) => a.name.compareTo(b.name),
      itemFilter: (suggestion,input) =>
          suggestion.name.toLowerCase().startsWith(input.toLowerCase()),
    );
    ddlWorker = new AutoCompleteTextField<Worker>(
        decoration: new InputDecoration(
          labelText: 'Worker',
          hintText: 'Select Employee',
        ),
        itemSubmitted: (item) {
          setState(() {
            _selectedWorker = item;
            workerController.text=_selectedWorker.lastName+' '+_selectedWorker.firstName;
          });
        },
        key: keyWorker,
        clearOnSubmit: false,
        minLength: 0,
        suggestions: widget.mProject.workers,
        itemBuilder: (context,suggestion) => new Padding(
          child: new ListTile(
            title: new Text(suggestion.lastName +' '+ suggestion.firstName),
            trailing: new Text(suggestion.designation),
          ),
          padding: EdgeInsets.all(8.0),
        ),
        controller: workerController,
        itemSorter: (a, b) => a.lastName.compareTo(b.lastName),
        itemFilter: (suggestion,input) =>
            suggestion.lastName.toLowerCase().startsWith(input.toLowerCase())
    );
    ddlCoreSize = new AutoCompleteTextField<CoreSize>(
        decoration: new InputDecoration(
          labelText: 'CoreSize',
          hintText: 'Select CoreSize',
        ),
        itemSubmitted: (item) {
          setState(() {
            _selectedCoreSize = item;
            coreSizeController.text=_selectedCoreSize.core;
          });
        },
        key: keyCoreSize,
        clearOnSubmit: false,
        minLength: 0,
        suggestions: widget.mProject.coreSizes,
        itemBuilder: (context,suggestion) => new Padding(
          child: new ListTile(
            title: new Text(suggestion.core,
            ),
          ),
          padding: EdgeInsets.all(8.0),
        ),
        controller: coreSizeController,
        itemSorter: (a, b) => a.core.compareTo(b.core),
        itemFilter: (suggestion,input) =>
            suggestion.core.toLowerCase().startsWith(input.toLowerCase()),
    );
    ddlMaterials = new AutoCompleteTextField<MaterialItems>(
      decoration: new InputDecoration(
        labelText: 'Used Material',
        hintText: 'Select Used materials'
      ),
        itemSubmitted: (item){
        setState(() {
          _selectedMaterial = item;
          materialItemController.text = _selectedMaterial.name;
        });
        },
        key: keyMaterialItems,
        clearOnSubmit: false,
        minLength: 0,
        suggestions: widget.mProject.materials,
        itemBuilder: (context,suggestion)=> new Padding(
          child: new ListTile(
            title: new Text(suggestion.name),
          ), 
            padding: EdgeInsets.all(8.0)),
        controller: materialItemController,
        itemSorter: (a, b)=>a.name.compareTo(b.name),
        itemFilter: (suggestion, input) =>
            suggestion.name.toLowerCase().startsWith(input.toLowerCase()),
    );

    _isLoading = false;
    if(widget.mWorkSheet !=null) {
      loadWorkSheet(widget.mWorkSheet);
      }
  }
  void loadWorkSheet(WorkSheet workSheet){
    if(workSheet==null)
      return;
      _workDate.dateTime = workSheet.workDate;
      _selectedRigs = workSheet.rigs;
      rigController.text = _selectedRigs.serial;
      _selectedHoles = workSheet.holes;
      holeController.text = _selectedHoles!=null?_selectedHoles.name:'';
      _taskLogs = workSheet.taskLogs;
      _consumeMaterials = workSheet.consumeMaterials;
      _comments = workSheet.comments;
    _workSheetStatus = getCurrentStatus(workSheet.status);
    _worksheetStages = getWorkSheetStagesFromList(widget.mProject.workSheetStages,_workSheetStatus);
    _nextStages.addAll(_worksheetStages.nextStages);
//    ddlNextStages.updateSuggestions(_nextStages);
    ddlNextStages = new AutoCompleteTextField<String>(
      decoration: new InputDecoration(
          labelText: 'Submit To',
          hintText: 'Submit To'
      ),
      itemSubmitted: (item){
        setState(() {
          _selectedStatus = item;
          nextStagesController.text = _selectedStatus;
        });
      },
//      key: keyNextStages,
      onFocusChanged: (hasFocus){},
      clearOnSubmit: false,
      minLength: 0,
      suggestions: _nextStages,
      itemBuilder: (context,suggestion)=> new Padding(
          child: new ListTile(
            title: new Text(suggestion),
          ),
          padding: EdgeInsets.all(8.0)),
      controller: nextStagesController,
      itemSorter: (a, b)=>a.compareTo(b),
      itemFilter: (suggestion, input) =>
          suggestion.toLowerCase().startsWith(input.toLowerCase()),
    );


  }
  WorkSheetStatus getCurrentStatus(List<WorkSheetStatus> status)
  {
    WorkSheetStatus status = new WorkSheetStatus('enableOP');
    return status;
  }
  WorkSheetStage getWorkSheetStagesFromList(List<WorkSheetStage> stages,  WorkSheetStatus status){
    for(WorkSheetStage workSheetStage in stages){
      if(workSheetStage.name.toLowerCase().contains(status.status.toLowerCase()))
        return workSheetStage;
    }
    return null;
  }
  _showDialog(String error) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Data Error"),
          content: new Text(error),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }
  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
        length: choices.length,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: new AppBar(
            title: Text(widget.mProject.projectName),
              actions: <Widget>[
                if(worksheetUpdate)
                  new Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 0, 20, 0),
                    child: IconButton(icon: Icon(Icons.done),
                        onPressed: saveWorkSheet),
                  ),

              ],
              bottom: TabBar(
                isScrollable: true,
                tabs: choices.map((TabMenu choice) {
                  return Tab(
                    text: choice.title,
                  );
                }).toList(),
              ),

          ),
          body: TabBarView(
                children: choices.map((TabMenu choice) {
                switch(choice.shortName){
                  case 'task':
                    return loadTasksForm();
                  case 'material':
                    return loadMaterialForm();
                  case 'remark':
                    return loadCommentForm();
                  default:
                    return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ChoiceCard(choice: choice),
                          );
                }
                }).toList(),
          ),

      ),

    );

  }
  Widget loadTasksForm(){
    if(_isLoading) {
      return _showCircularProgress();
    }
    return Column(
      children: <Widget>[
        new Row(
          mainAxisAlignment: MainAxisAlignment.start, //change here don't //worked
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Expanded(
              child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(10, 5, 5, 0),
                child: new TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Enter Work Date',
                    labelText: 'Work Date',
                  ),
                  onTap: (){
                    FocusScope.of(context).requestFocus(new FocusNode());
                    callDatePicker(_workDate);
                  },
                  controller:  TextEditingController(text: format.format(_workDate.dateTime)),

                ),
              ),
            ),
            new Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 0),
                  child:  ddlRigs,
                  ),
            ),
            new Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 0),
                child:  ddlHoles,
              ),
            ),
          ],

        ),
        new Row(
          mainAxisAlignment: MainAxisAlignment.start, //change here don't //worked
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                child:  ddlTasks,
              ),
            ),
            if(_selectedTask !=null && _selectedTask.taskType.contains('coring'))
              new Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                  child:  ddlCoreSize,
                ),
              ),
            if(_selectedTask!=null && _selectedTask.logType.contains('E'))
              new Expanded(
              flex: 3,
              child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
              child:  ddlWorker,
              ),
              ),
            if(_selectedTask!=null && _selectedTask.logType.contains('C'))
              new Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                  child:  new TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Note',
                      labelText: 'Note'
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(50),
                    ],

                    controller: noteController,

                  ),
                ),
              ),

          ],

        ),
        new Row(
          mainAxisAlignment: MainAxisAlignment.start, //change here don't //worked
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(10, 0, 5, 0),
                child: new TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Start Time',
                    labelText: 'Start Time',
                  ),
                  onTap: (){
                    FocusScope.of(context).requestFocus(new FocusNode());
                    callTimePicker(_startTime);
                  },
                  controller:  TextEditingController(text: _startTime!=null && _startTime.timeOfDay !=null ?_startTime.timeOfDay.format(context) :''),

                ),
              ),
            ),
            new Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(10, 0, 5, 0),
                child: new TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'End Time',
                    labelText: 'End Time',
                  ),
                  onTap: (){
                    FocusScope.of(context).requestFocus(new FocusNode());
                    callTimePicker(_endTime);
                  },
                  controller:  TextEditingController(text: _endTime!=null && _endTime.timeOfDay !=null?_endTime.timeOfDay.format(context) :''),

                ),
              ),
            ),
            if(_selectedTask !=null && _selectedTask.logType.contains('P'))
            new Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                child: new TextFormField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(8),
                    BlacklistingTextInputFormatter.singleLineFormatter,
                    ValidatorInputFormatter(
                      editingValidator: DecimalNumberSubmitValidator(
                      ),
                    )
                  ],
                  decoration: const InputDecoration(
                    hintText: 'Start(M)',
                    labelText: 'Start(M)',
                  ),
                  controller: startMController,
                ),
              ),
            ),
            if(_selectedTask !=null && _selectedTask.logType.contains('P'))
              new Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                  child: new TextFormField(
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(8),
                      BlacklistingTextInputFormatter.singleLineFormatter,
                      ValidatorInputFormatter(
                        editingValidator: DecimalNumberSubmitValidator(
                        ),
                      )
                    ],
                    decoration: const InputDecoration(
                      hintText: 'End(M)',
                      labelText: 'End(M)',
                    ),
                    controller:  endMController,
                  ),
                ),
              ),
            new Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(5, 10, 5, 0),
                child: IconButton(
                  icon: Icon(taskLogAddNew?Icons.add:Icons.done),
                  onPressed: () {
                      setTaskLog();
                  },
                ),
              ),
            ),
          ],
        ),
        new Container(
          color: Colors.grey,
          padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Expanded(
                    flex: 3,
                    child:Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 5),
                      child: new Text("Task",style: TextStyle(fontSize: 16.0),) ,
                    )
                ),
                new Expanded(
                    flex: 2,
                    child:Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 5),
                      child: new Text("Worker",style: TextStyle(fontSize: 16.0),) ,
                    )
                ),
                new Expanded(
                    flex: 2,
                    child:Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 5),
                      child: new Text("Work(H)",style: TextStyle(fontSize: 16.0),) ,
                    )
                ),
                new Expanded(
                    flex: 2,
                    child:Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 5),
                      child: new Text("Note",style: TextStyle(fontSize: 16.0),) ,
                    )
                ),
                new Expanded(
                    flex: 1,
                    child:Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 5),
                      child: new Text(" ") ,
                    )
                )
              ]
          ),
        ),
        loadLogTaskList(),
      ],
    );

  }
  Widget loadMaterialForm(){
    if(_isLoading){
      return _showCircularProgress();
    }
    return Column(
      children: <Widget>[
        new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Expanded(
              flex: 5,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
                  child: ddlMaterials,
                ),
            ),
            new Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(5, 10, 10, 10),
                child: new TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    hintText: 'Quantity'
                  ),
                  controller: materialQtyController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(4),
                    BlacklistingTextInputFormatter.singleLineFormatter,
                  ],
                ),

              ),
            ),
            new Expanded(
              flex: 2,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 10, 10, 10),
                  child: new IconButton(
                    icon: Icon(addNewMaterial?Icons.arrow_forward_ios:Icons.done),
                    onPressed: (){
                      setConsumeMaterial();
                    },
                  ),
                )
            ),
          ],
        ),
        new Container(
          color: Colors.grey,
          padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Expanded(
                  flex: 5,
                    child:Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 5),
                      child: new Text("Material",style: TextStyle(fontSize: 16.0),) ,
                    )
                ),
                new Expanded(
                  flex: 3,
                    child:Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 5),
                      child: new Text("Quantity",style: TextStyle(fontSize: 16.0),) ,
                    )
                ),
                new Expanded(
                  flex: 2,
                    child:Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 5),
                      child: new Text(" ") ,
                    )
                )
              ]
          ),
        ),
        loadUsedMaterialList(),
      ],
    );
  }
  Widget loadCommentForm(){
    if(_isLoading){
      return _showCircularProgress();
    }
    return Column(
      children: <Widget>[
        new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Expanded(
              flex: 5,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(5, 10, 10, 10),
                child: new TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Comments',
                      hintText: 'Comments'
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  maxLength: 200,
                  controller: commentController,
                ),

              ),
            ),
            new Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(5, 10, 10, 10),
                  child: new IconButton(
                    icon: Icon(Icons.add),
                    onPressed: (){
                      setComment();
                    },
                  ),
                )
            ),
          ],
        ),
        new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(10, 5, 0, 10),
                child: ddlNextStages,
              ),
            ),
            new Expanded(
              flex: 3,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(5, 10, 10, 10),
                  child: new FlatButton(
                    child: Text('Submit'),
                    onPressed: (){
                      submitWorkSheet();
                    },
                  ),
                )
            ),
          ],
        ),
        new Container(
          color: Colors.grey,
          padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Expanded(
                    flex: 3,
                    child:Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 5),
                      child: new Text("Comment",style: TextStyle(fontSize: 16.0),) ,
                    )
                ),
              ]
          ),
        ),
        loadCommentList(),
      ],
    );
  }
  void setTaskLog(){
    if(isValidTask()){
      if(taskLogAddNew){
        TaskLog taskLog = new TaskLog(task: _selectedTask,
            startTime: _startTime.timeOfDay.format(context),
            endTime: _endTime.timeOfDay.format(context) );
        taskLog.startMeter = double.parse(startMController.text.isEmpty?"0":startMController.text);
        taskLog.endMeter = double.parse(endMController.text.isEmpty?"0":endMController.text);
        taskLog.worker = _selectedWorker;
        _selectedNote = noteController.text;
        taskLog.remarks = _selectedNote;
        taskLog.coreSize = _selectedCoreSize;
      }
      else{
        TaskLog taskLog;
        if(taskIndexForUpdate>=0){
          taskLog = _taskLogs[taskIndexForUpdate];
          taskLog.task = _selectedTask;
          taskLog.startTime = _startTime.timeOfDay.format(context);
          taskLog.endTime = _endTime.timeOfDay.format(context);
          taskLog.coreSize = _selectedCoreSize;
          taskLog.worker = _selectedWorker;
          _selectedNote = noteController.text;
          taskLog.remarks = _selectedNote;
          taskLog.startMeter = double.parse(startMController.text.isEmpty?"0":startMController.text);
          taskLog.endMeter = double.parse(endMController.text.isEmpty?"0":endMController.text);
        }
        setState(() {
        taskLogAddNew = true;
        worksheetUpdate = true;
        if(taskIndexForUpdate>=0){
        _taskLogs[taskIndexForUpdate]=taskLog;
        }
        else{
          _taskLogs.add(taskLog);
        }
        clearTaskInput();
        });
      }
    }

  }
  void clearTaskInput(){
    _selectedTask = null;
    _startMeter = 0;
    _endMeter = 0;
    _selectedWorker = null;
    _selectedNote ="";
    _selectedCoreSize = null;
    taskController.text="";
    coreSizeController.text="";
    workerController.text="";
    noteController.text="";
    startMController.text="";
    endMController.text="";
    taskIndexForUpdate = -1;
  }
  bool isValidTask()
  {
    return true;
  }
  void setConsumeMaterial(){
    if(true){
      if(_consumeMaterials == null){
        _consumeMaterials = new List();
      }
      ConsumeMaterials consumeMaterials;
      if(addNewMaterial){
        consumeMaterials = new ConsumeMaterials(_selectedMaterial,
            double.parse(materialQtyController.text.isEmpty?"0":materialQtyController.text));

      }
      else{
        consumeMaterials = _consumeMaterials[usedMaterialIndexForUpdate];
        consumeMaterials.material = _selectedMaterial;
        consumeMaterials.qty = double.parse(materialQtyController.text.isEmpty?"0":materialQtyController.text);
      }
      setState(() {
        addNewMaterial = true;
        worksheetUpdate = true;
        if(usedMaterialIndexForUpdate >= 0){
          _consumeMaterials[usedMaterialIndexForUpdate]=consumeMaterials;
        }
        else{
          _consumeMaterials.add(consumeMaterials);
        }
      clearConsumeMaterialInput();
      });

    }
  }
  void clearConsumeMaterialInput(){
    _selectedUsedMaterial = null;
    _selectedMaterial = null;
    materialQtyController.text = "";
    materialItemController.text = "";
  }
  void setComment(){
    if(true){
      if(_comments == null){
        _comments = new List();
      }
      Comments comments;
        comments = new Comments(commentController.text);
        setState(() {
          worksheetUpdate = true;
          _comments.add(comments);
          clearComment();
        });
      }

  }
  void clearComment(){
    commentController.text = "";
  }
  Future<DateTime> getDate() {
    // Imagine that this function is
    // more complex and slow.
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2018),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light(),
          child: child,
        );
      },
    );
  }
  Future<TimeOfDay> getTime(){
    return showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
    );
  }
  void callDatePicker(DateTimeWrapper dateTime) async {
    DateTime _datetime = await getDate();
    setState(() {
      if(_datetime !=null){
        dateTime.dateTime = _datetime;
      }

    });
  }
  void callTimePicker(TimeWrapper time) async {
    TimeOfDay tod = await getTime();
    setState(() {
      if(tod !=null){
        time.timeOfDay = tod;
      }

    });
  }
  Widget loadLogTaskList()
  {
    if(_isLoading)
      return _showCircularProgress();
    if(_taskLogs !=null && _taskLogs.length>0)
      {
        return ListView.separated(
          shrinkWrap: true,
          separatorBuilder: (context, index) {
            return Divider();
          },
          itemCount: _taskLogs.length,
          itemBuilder: (BuildContext context,int index){
//            var format = DateFormat("hh:mm a");
            var startTime = timeFormat.parse(_taskLogs[index].startTime);
            var endTime = timeFormat.parse(_taskLogs[index].endTime);
            if(startTime.isAfter(endTime))
              endTime = endTime.add(Duration(days: 1));
            var hoursWorked = endTime.difference(startTime);
            var duration = (hoursWorked.inMinutes/60).toStringAsFixed(2);
            _startMeter = _taskLogs[index].startMeter;
            _endMeter = _taskLogs[index].endMeter;
             var workDoneProgress = (_endMeter -_startMeter).abs();
            String displayProgress = workDoneProgress.toStringAsFixed(2)+"M";
            var displayNote = _taskLogs[index].remarks;
            return new Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Expanded(
                  flex:3,
                  child:ListTile(
                    title: Text(_taskLogs[index].task.name),
                  ),
                ),
                new Expanded(
                  flex:2,
                  child:ListTile(
                    title: Text(_taskLogs[index].worker!=null?_taskLogs[index].worker.lastName+' '+_taskLogs[index].worker.firstName:'-'),
                  ),
                ),
                new Expanded(
                  flex:2,
                  child:ListTile(
                    title: Text(duration),
                  ),
                ),
                new Expanded(
                  flex:2,
                  child:ListTile(
                    title: Text(workDoneProgress>0?displayProgress:displayNote),
                  ),
                ),
                new Expanded(
                  flex: 1,
                    child:Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                      child: IconButton(
                        icon: Icon(Icons.arrow_forward_ios),
                        onPressed: () {
                          setState(() {
                            taskLogAddNew=false;
                            loadTaskForUpdate(index);
                          });
                        },
                      ),
                    )
                ),
              ],
            );
          },
        );
      }
    else {
      return Padding(
        padding: EdgeInsetsDirectional.fromSTEB(10, 10, 0, 0),
          child: Text(
            "No Task found",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15.0),
          ));
    }

  }
  Widget loadUsedMaterialList()
  {
    if(_isLoading)
      return _showCircularProgress();
    if(_consumeMaterials !=null && _consumeMaterials.length>0)
    {
      return ListView.separated(
        shrinkWrap: true,
        separatorBuilder: (context, index) {
          return Divider();
        },
        itemCount: _consumeMaterials.length,
        itemBuilder: (BuildContext context,int index){
          return new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Expanded(
                flex: 5,
                child:ListTile(
                  title: Text(_consumeMaterials[index].material.name),
                ),
              ),
              new Expanded(
                flex:3,
                child:ListTile(
                  title: Text(_consumeMaterials[index].qty.toString()),
                ),
              ),
              new Expanded(
                  flex: 2,
                  child:Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                    child: IconButton(
                      icon: Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        setState(() {
                          addNewMaterial=false;
                          loadUsedMaterialForUpdate(index);
                        });
                      },
                    ),
                  )
              ),
            ],
          );
        },
      );
    }
    else {
      return Padding(
          padding: EdgeInsetsDirectional.fromSTEB(10, 10, 0, 0),
          child: Text(
            "No Used material found",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15.0),
          ));
    }

  }
  Widget loadCommentList()
  {
    if(_isLoading)
      return _showCircularProgress();
    if(_comments !=null && _comments.length>0)
    {
      return ListView.separated(
        shrinkWrap: true,
        separatorBuilder: (context, index) {
          return Divider();
        },
        itemCount: _comments.length,
        itemBuilder: (BuildContext context,int index){
          return new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Expanded(
                flex:3,
                child:ListTile(
                  title: Text(_comments[index].comment),
                ),
              ),
            ],
          );
        },
      );
    }
    else {
      return Padding(
          padding: EdgeInsetsDirectional.fromSTEB(10, 10, 0, 0),
          child: Text(
            "No Comments",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15.0),
          ));
    }

  }
  void loadTaskForUpdate(int index){
    if(_taskLogs.length>index)
      {
        taskIndexForUpdate = index;
        _selectedTask = _taskLogs[index].task;
        taskController.text=_selectedTask.name;
        _selectedCoreSize =_taskLogs[index].coreSize;
        coreSizeController.text =_selectedCoreSize!=null?_selectedCoreSize.core:'';
        _selectedWorker =_taskLogs[index].worker;
        workerController.text=_selectedWorker!=null? _selectedWorker.lastName:'';
        _startTime = new TimeWrapper(timeOfDay: TimeOfDay.fromDateTime(timeFormat.parse(_taskLogs[index].startTime)));
        _endTime = new TimeWrapper(timeOfDay: TimeOfDay.fromDateTime(timeFormat.parse(_taskLogs[index].endTime)));
        _startMeter =_taskLogs[index].startMeter;
        startMController.text=_startMeter.toString();
        _endMeter = _taskLogs[index].endMeter;
        endMController.text = _endMeter.toString();
        _selectedNote = _taskLogs[index].remarks;
        noteController.text = _selectedNote;
      }
  }
  void loadUsedMaterialForUpdate(int index){
    if(_consumeMaterials.length > index){
      usedMaterialIndexForUpdate = index;
      _selectedUsedMaterial = _consumeMaterials[index];
      _selectedMaterial = _selectedUsedMaterial.material;
      materialItemController.text = _selectedMaterial.name;
      materialQtyController.text = _selectedUsedMaterial.qty.toString();

    }
  }
  void saveWorkSheet(){

    if(widget.mWorkSheet==null)
      {
        widget.mWorkSheet = new WorkSheet(null, null);
        widget.mWorkSheet.entryDate = DateTime.now();
        widget.mWorkSheet.entryBy = widget.mUser.lastName;
      }
    widget.mWorkSheet.rigs = _selectedRigs;
    widget.mWorkSheet.holes = _selectedHoles;
    widget.mWorkSheet.workDate = _workDate.dateTime;
    widget.mWorkSheet.taskLogs = _taskLogs;
    widget.mWorkSheet.consumeMaterials = _consumeMaterials;
    widget.mWorkSheet.comments = _comments;
//    widget.mWorkSheet.status;
    setState(() {
      worksheetUpdate = false;
    });

  }
  void submitWorkSheet(){
    _selectedStatus = nextStagesController.text;

  }

}
class DateTimeWrapper{
  DateTime dateTime;
  DateTimeWrapper({this.dateTime});
}
class TimeWrapper{
  TimeOfDay timeOfDay;
  TimeWrapper({this.timeOfDay});
}
class TabMenu {
  const TabMenu({this.title, this.shortName, this.icon});

  final String title;
  final String shortName;
  final IconData icon;
}

const List<TabMenu> choices = const <TabMenu>[
  const TabMenu(title: 'Tasks', shortName: 'task', icon: Icons.directions_car),
  const TabMenu(title: 'Used Materials', shortName: 'material', icon: Icons.directions_bike),
  const TabMenu(title: 'Remark/Submit',shortName: 'remark', icon: Icons.directions_boat),
];

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({Key key, this.choice}) : super(key: key);

  final TabMenu choice;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.display1;

    return Card(
      color: Colors.white,
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(choice.icon, size: 128.0, color: textStyle.color),
            Text(choice.title, style: textStyle),
          ],
        ),
      ),
    );
  }
}

