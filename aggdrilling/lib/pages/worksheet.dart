import 'package:aggdrilling/models/comments.dart';
import 'package:aggdrilling/models/coresize.dart';
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
import 'package:aggdrilling/utils/common_functions.dart';
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
class _WorkSheetPageState extends State<WorkSheetPage> with WidgetsBindingObserver{
  bool _isLoading;
  final format = DateFormat("yyyy-MM-dd");
  final formatDateTime = DateFormat("yyyy-MM-dd hh:mm a");
  final timeFormat = DateFormat("hh:mm a");
  final _dbReference = Firestore.instance.collection('projects');
  Rigs _selectedRigs;
  String _selectedHoles;
  String _dip;
  Worker _selectedWorker1;
  Worker _selectedWorker2;
  Worker _selectedDriller;
  Worker _selectedHelper;
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
  Comments _selectedComments;
  List<String> _nextStages = new List();
  WorkSheetStage _worksheetStages;
  WorkSheetStatus _currentWorkSheetStatus;
  WorkSheetStatus _selectedWorkSheetStatus;
  String _selectedStatus;
  AutoCompleteTextField<String> ddlHoles;
  AutoCompleteTextField<String> ddlNextStages;
  GlobalKey keyNextStages = new GlobalKey<AutoCompleteTextFieldState<String>>();
  final DateTimeWrapper _workDate = new DateTimeWrapper(dateTime:DateTime.now());
  String _startTime;
  String _endTime;
  bool taskLogAddNew = true;
  bool addNewMaterial = true;
  bool addNewRemark = true;
  bool worksheetUpdate = false;
  bool hasPermitStatus = false;
  bool hasSubmitStatus = false;
  int taskIndexForUpdate = -1;
  int usedMaterialIndexForUpdate = -1;
  final dipController = new TextEditingController();
  final noteController = new TextEditingController();
  final startMController = new TextEditingController();
  final endMController = new TextEditingController();
  final materialQtyController = new TextEditingController();
  final commentController = new TextEditingController();
  final nextStagesController = new TextEditingController();
  final holeController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTime ="7:00 AM";
    _endTime = "7:00 AM";
    if(widget.mWorkSheet != null){
      _isLoading = true;
      loadWorksheetDetail();
    }
    else {
      loadUI();
      _isLoading = false;
    }

  }
  @override
  void dispose(){
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  @override
  void didChangeMetrics(){

  }
  loadWorksheetDetail() async{
    _dbReference.document(widget.mProject.docId).collection("worksheet").
    document(widget.mWorkSheet.docId).get().then((DocumentSnapshot snapshot){
      widget.mWorkSheet.loadAllDs(snapshot, onComplete: (value)=>{
      setState((){
        _isLoading = false;
        loadUI();
      })
      }, onError: (error)=>{
        setState(() {
          _isLoading = false;
        }),
        _showDialog(error),
      });
    });
  }
  loadUI(){
    _isLoading = false;
    if(widget.mWorkSheet !=null) {
      loadWorkSheet(widget.mWorkSheet);
    }
    loadProjectPermitStatus();
    checkPermitStatus();
  }
  List<Worker> filterWorkerByDesignation(List<Worker> workers,String filter){
    List<Worker> workerRs = new List();
    for(Worker worker in workers){
      if(worker.designation.toLowerCase().contains(filter)){
        workerRs.add(worker);
      }
    }
    return workerRs;
  }
  void loadWorkSheet(WorkSheet workSheet){
      _workDate.dateTime = workSheet.workDate;
      _selectedRigs = workSheet.rigs;
      _selectedHoles = workSheet.holes;
      _dip = workSheet.dip;
      holeController.text=_selectedHoles;
      dipController.text = _dip !=null?_dip:'';
      _taskLogs = workSheet.taskLogs;
      _consumeMaterials = workSheet.consumeMaterials;
      _comments = workSheet.comments;
  }
  void loadProjectPermitStatus(){
    if(widget.mWorkSheet == null){
      _currentWorkSheetStatus = getCurrentStatus(null);
    }
    else
      {
        _currentWorkSheetStatus = getCurrentStatus(widget.mWorkSheet.status);
      }
    _worksheetStages = getWorkSheetStagesFromList(widget.mProject.workSheetStages,_currentWorkSheetStatus);
    if(_worksheetStages !=null){
    _nextStages.addAll(_worksheetStages.nextStages);
    }
    ddlHoles = new AutoCompleteTextField<String>(
      decoration: new InputDecoration(
          labelText: 'Holes',
      ),
      itemSubmitted: (item){
        setState(() {
          _selectedHoles = item;
          holeController.text = _selectedHoles;
          worksheetUpdate = true;
        });
      },
      onFocusChanged: (hasFocus){},
      clearOnSubmit: false,
      minLength: 0,
      suggestions: widget.mProject.holes,
      textChanged: (value){
        _selectedHoles=value;
        setState(() {
          worksheetUpdate = true;
        });
      },
      itemBuilder: (context,suggestion)=> new Padding(
          child: new ListTile(
            title: new Text(suggestion ),
          ),
          padding: EdgeInsets.all(8.0)),
      controller: holeController,
      itemSorter: (a, b)=>a.compareTo(b),
      itemFilter: (suggestion, input) =>
          suggestion.toLowerCase().startsWith(input.toLowerCase()),
    );
    ddlNextStages = new AutoCompleteTextField<String>(
      decoration: new InputDecoration(
          labelText: 'Submit To',
          hintText: 'Submit To'
      ),
      itemSubmitted: (item){
        setState(() {
          _selectedStatus = item;
          nextStagesController.text = widget.mUser.appSettings.getStageDetails(_selectedStatus);
        });
      },
      onFocusChanged: (hasFocus){},
      clearOnSubmit: false,
      minLength: 0,
      suggestions: _nextStages,
      itemBuilder: (context,suggestion)=> new Padding(
          child: new ListTile(
            title: new Text(widget.mUser.appSettings.getStageDetails(suggestion) ),
          ),
          padding: EdgeInsets.all(8.0)),
      controller: nextStagesController,
      itemSorter: (a, b)=>a.compareTo(b),
      itemFilter: (suggestion, input) =>
          suggestion.toLowerCase().startsWith(input.toLowerCase()),
    );
  }
  void checkPermitStatus(){
    PermitProjects permitProjects = widget.mUser.getUserPermitProjectByCode(widget.mProject.projectCode);
    if(permitProjects != null && permitProjects.permitSteps!=null
    && permitProjects.permitSteps.indexOf(_currentWorkSheetStatus.status)>=0 ){
      for(WorkSheetStage workSheetStage in widget.mProject.workSheetStages){
        if(workSheetStage.name.toLowerCase().contains(_currentWorkSheetStatus.status.toLowerCase())){
          if(workSheetStage.actions.indexOf("add")>=0 ||
              workSheetStage.actions.indexOf("update")>=0){
            setState(() {
              hasPermitStatus = true;
            });
          }
          if(workSheetStage.actions.indexOf("submit")>=0){
            hasSubmitStatus = true;
          }

        }
      }
    }
  }
  WorkSheetStatus getCurrentStatus(List<WorkSheetStatus> status)
  {
    WorkSheetStatus workSheetStatus;
    if(status == null || status.length==0) {
      workSheetStatus = new WorkSheetStatus('enableOP');
    }
    else{
      status.sort((a, b){
       return b.entryDate.compareTo(a.entryDate);
      });
      workSheetStatus = status[0];
    }
    return workSheetStatus;
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
          appBar: new AppBar(
            title: Text(widget.mProject.projectName),
              actions: <Widget>[
                if(hasPermitStatus && worksheetUpdate)
                  new Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 0, 20, 0),
                    child: FlatButton(child: Text('Save',style: TextStyle(fontSize: 18.0,color: Colors.white),),
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
              flex: 2,
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
              flex: 2,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 25, 0, 5),
                  child:  _createRigsDdl(widget.mProject.rigs),
                  ),
            ),
            new Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 0),
                child:  ddlHoles,
              ),
            ),
            new Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(5, 15, 5, 0),
                child: new TextFormField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(5),
                    BlacklistingTextInputFormatter.singleLineFormatter,
                    ValidatorInputFormatter(
                      editingValidator: DecimalNumberSubmitValidator(
                      ),
                    )
                  ],
                  decoration: const InputDecoration(
                    hintText: 'DIP',
                  ),
                  controller:  dipController,
                  textAlign: TextAlign.center,
                  onChanged: (value){
                    _dip=value;
                    setState(() {
                      worksheetUpdate = true;
                    });
                  },
                ),
              ),
            )

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
                child:  _createTaskDdl(widget.mProject.tasks),
              ),
            ),
            if(_selectedTask !=null && _selectedTask.taskType.toLowerCase().contains('drilling'))
              new Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                  child:  _createCoreDdl(widget.mProject.coreSizes),
                ),
              ),

          ],

        ),
        if(_selectedTask!=null && _selectedTask.logType.contains('X'))
        new Row(
          mainAxisAlignment: MainAxisAlignment.start, //change here don't //worked
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
              new Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                  child:  _createDrillerDdl(filterWorkerByDesignation(widget.mProject.workers,"driller")),
                ),
              ),
            new Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                child:  _createHelperDdl(filterWorkerByDesignation(widget.mProject.workers, "helper")),
              ),
            )

          ],

        ),
        if(_selectedTask!=null && _selectedTask.logType.contains('E'))
        new Row(
              mainAxisAlignment: MainAxisAlignment.start, //change here don't //worked
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                    child:  _createWorker1Ddl(widget.mProject.workers),
                  ),
                ),
                new Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                    child:  _createWorker2Ddl(widget.mProject.workers),
                  ),
                )

              ],

            ),
        new Row(
          mainAxisAlignment: MainAxisAlignment.start, //change here don't //worked
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(5, 10, 0, 0),
                child: _createStartTimeDdl(CommonFunction.getAllSiftWorkHours()),
              ),
            ),
            new Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(5, 10, 0, 0),
                child: _createEndTimeDdl(CommonFunction.getAllSiftWorkHours()),
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

                  ),
                  controller: startMController,
                  textAlign: TextAlign.center,
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
                    ),
                    controller:  endMController,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

          ],
        ),
        new Row(
          mainAxisAlignment: MainAxisAlignment.start, //change here don't //worked
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
//            if(_selectedTask!=null && _selectedTask.logType.contains('C'))
              new Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                  child:  new TextFormField(
                    decoration: const InputDecoration(
                        hintText: 'Note',
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(50),
                    ],

                    controller: noteController,

                  ),
                ),
              ),
            if(hasPermitStatus)
              new Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 10, 5, 0),
                  child: FlatButton(
                    child: Text(taskLogAddNew?'ADD':'Update',style: TextStyle(color: Colors.blueAccent),),
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
                      child: new Text("Start Time",style: TextStyle(fontSize: 16.0),) ,
                    )
                ),
                new Expanded(
                    flex: 2,
                    child:Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 5),
                      child: new Text("End Time",style: TextStyle(fontSize: 16.0),) ,
                    )
                ),
                new Expanded(
                    flex: 3,
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
        Expanded(
         child: loadLogTaskList()
          ),
      ],
    );

  }
  Widget _createRigsDdl(List<Rigs> values){
    values.sort((a,b) => a.serial.compareTo(b.serial));
    return DropdownButton<Rigs>(
      hint: Text("Select Rigs"), // Not necessary for Option 1//
      value: _selectedRigs==null?_selectedRigs:values.where((i) =>i.serial==_selectedRigs.serial).first as Rigs,
      onChanged: (newValue) {
        setState(() {
          _selectedRigs = newValue;
          worksheetUpdate = true;
        });
      },
      items: values.map((data) {
        return DropdownMenuItem<Rigs>(
          child: new Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
            child: new Text(data.serial, style: TextStyle(fontSize: 15.0),),
          ),
          value: data,
        );
      }).toList(),
    );
  }
  Widget _createTaskDdl(List<Task> values){
    values.sort((a,b) => a.name.compareTo(b.name));
    return DropdownButton<Task>(
      hint: Text("Task"), // Not necessary for Option 1//
      value: _selectedTask==null?_selectedTask:values.where( (i) => i.name == _selectedTask.name).first as Task,
      elevation: 16,
      onChanged: (newValue) {
        setState(() {
          _selectedTask = newValue;
        });
      },
      isExpanded: true,
      items: values.map((data) {
        return DropdownMenuItem<Task>(
          child: new Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 10, 5, 10),
            child: new Text(data.name, style: TextStyle(fontSize: 15.0),),
          ),
          value: data,
        );
      }).toList(),
    );
  }
  Widget _createCoreDdl(List<CoreSize> values){
    values.sort((a,b) => a.core.compareTo(b.core));
    return DropdownButton<CoreSize>(
      hint: Text("Core Size"), // Not necessary for Option 1//
      value: _selectedCoreSize==null?_selectedCoreSize:values.where((i) =>i.core==_selectedCoreSize.core).first as CoreSize,
      onChanged: (newValue) {
        setState(() {
          _selectedCoreSize = newValue;
        });
      },
      items: values.map((data) {
        return DropdownMenuItem<CoreSize>(
          child: new Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 10, 5, 10),
            child: new Text(data.core, style: TextStyle(fontSize: 15.0),),
          ),
          value: data,
        );
      }).toList(),
    );
  }
  Widget _createDrillerDdl(List<Worker> values){
    values.sort((a,b) => (a.lastName+a.firstName).compareTo(b.lastName+b.firstName));
    return DropdownButton<Worker>(
      hint: Text("Select Driller"), // Not necessary for Option 1//
      value: _selectedDriller == null?_selectedDriller:values.where((i) =>i.lastName==_selectedDriller.lastName &&
          i.firstName==_selectedDriller.firstName).first as Worker,
      elevation: 16,
      onChanged: (newValue) {
        setState(() {
          _selectedDriller= newValue;
        });
      },
      items: values.map((data) {
        return DropdownMenuItem<Worker>(
          child: new Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 10, 5, 10),
            child: new Text(data.lastName+' '+data.firstName, style: TextStyle(fontSize: 15.0),),
          ),
          value: data,
        );
      }).toList(),
    );
  }
  Widget _createHelperDdl(List<Worker> values){
    values.sort((a,b) => (a.lastName+a.firstName).compareTo(b.lastName+b.firstName));
    return DropdownButton<Worker>(
      hint: Text("Select Helper"), // Not necessary for Option 1//
      value: _selectedHelper == null?_selectedHelper:values.where((i) =>i.lastName==_selectedHelper.lastName &&
          i.firstName==_selectedHelper.firstName).first as Worker,
      elevation: 16,
      onChanged: (newValue) {
        setState(() {
          _selectedHelper= newValue;
        });
      },
      items: values.map((data) {
        return DropdownMenuItem<Worker>(
          child: new Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 10, 5, 10),
            child: new Text(data.lastName+' '+data.firstName, style: TextStyle(fontSize: 15.0),),
          ),
          value: data,
        );
      }).toList(),
    );
  }
  Widget _createWorker1Ddl(List<Worker> values){
    values.sort((a,b) => (a.lastName+a.firstName).compareTo(b.lastName+b.firstName));
    return DropdownButton<Worker>(
      hint: Text("Select Worker1"), // Not necessary for Option 1//
      value: _selectedWorker1 == null?_selectedWorker1:values.where((i) =>i.lastName==_selectedWorker1.lastName &&
          i.firstName==_selectedWorker1.firstName).first as Worker,
      elevation: 16,
      onChanged: (newValue) {
        setState(() {
          _selectedWorker1= newValue;
        });
      },
      items: values.map((data) {
        return DropdownMenuItem<Worker>(
          child: new Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 10, 5, 10),
            child: new Text(data.lastName+' '+data.firstName, style: TextStyle(fontSize: 15.0),),
          ),
          value: data,
        );
      }).toList(),
    );
  }
  Widget _createWorker2Ddl(List<Worker> values){
    values.sort((a,b) => (a.lastName+a.firstName).compareTo(b.lastName+b.firstName));
    return DropdownButton<Worker>(
      hint: Text("Select Worker2"), // Not necessary for Option 1//
      value: _selectedWorker2 == null?_selectedWorker2:values.where((i) =>i.lastName==_selectedWorker2.lastName &&
          i.firstName==_selectedWorker2.firstName).first as Worker,
      elevation: 16,
      onChanged: (newValue) {
        setState(() {
          _selectedWorker2= newValue;
        });
      },
      items: values.map((data) {
        return DropdownMenuItem<Worker>(
          child: new Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 10, 5, 10),
            child: new Text(data.lastName+' '+data.firstName, style: TextStyle(fontSize: 15.0),),
          ),
          value: data,
        );
      }).toList(),
    );
  }
  Widget _createStartTimeDdl(List<String> values){
    return DropdownButton<String>(
      hint: Text("Start Time"), // Not necessary for Option 1//
      value: _startTime,
      onChanged: (newValue) {
        setState(() {
          _startTime = newValue;
        });
      },
      items: values.map((data) {
        return DropdownMenuItem<String>(
          child: new Text(data, style: TextStyle(fontSize: 14.0),),
          value: data,
        );
      }).toList(),
    );
  }
  Widget _createEndTimeDdl(List<String> values){
    return DropdownButton<String>(
      hint: Text("End Time"), // Not necessary for Option 1
      value: _endTime,
      onChanged: (newValue) {
        setState(() {
          _endTime = newValue;
        });
      },
      items: values.map((data) {
        return DropdownMenuItem<String>(
          child: new Text(data, style: TextStyle(fontSize: 14.0)),
          value: data,
        );
      }).toList(),
    );
  }
  Widget _createMaterialDdl(List<MaterialItems> values){
    values.sort((a,b) => (a.name+a.details).compareTo(b.name+b.details));
    return DropdownButton<MaterialItems>(
      hint: Text("Select Material"), // Not necessary for Option 1//
      value: _selectedMaterial==null?_selectedMaterial:values.where((i) =>i.name==_selectedMaterial.name &&
        i.details==_selectedMaterial.details).first as MaterialItems,
      onChanged: (newValue) {
        setState(() {
          _selectedMaterial = newValue;
        });
      },
      items: values.map((data) {
        return DropdownMenuItem<MaterialItems>(
          child: new Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 10, 5, 10),
            child: new Text(data.name+" "+data.details, style: TextStyle(fontSize: 15.0),),
          ),
          value: data,
        );
      }).toList(),
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
                  child: _createMaterialDdl(widget.mProject.materials),
                ),
            ),
            new Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 5),
                child: new TextFormField(
                  decoration: InputDecoration(
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
            if(hasPermitStatus)
            new Expanded(
              flex: 2,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 10, 5, 0),
                  child: new FlatButton(
                    child: Text(addNewMaterial?'Add':'Update',style: TextStyle(color: Colors.blueAccent)),
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
        Expanded(
          child: loadUsedMaterialList(),
        )
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
            ],
          ),
          if(hasSubmitStatus)
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
                        color: Colors.blueAccent,
                        textColor: Colors.white,
                        onPressed: (){
                          _submitConfirmation(context);
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
          Expanded(
            child: loadCommentList(),
          )
        ],
    );

  }
  void setTaskLog(){
    if(isValidTask()){
      TaskLog taskLog;
      if(_taskLogs == null){
        _taskLogs = new List();
      }
      var tempDayShiftStart = timeFormat.parse(widget.mUser.appSettings.dayShiftStart);
      var tempDayShiftEnd = timeFormat.parse(widget.mUser.appSettings.dayShiftEnd);
      if(taskLogAddNew) {
        taskLog = new TaskLog(task: _selectedTask,
            startTime: _startTime,
            endTime: _endTime
        );
      }
      else {
        if(taskIndexForUpdate>=0) {
          taskLog = _taskLogs[taskIndexForUpdate];
          taskLog.task = _selectedTask;
          taskLog.startTime = _startTime;
          taskLog.endTime = _endTime;
        }
      }
        taskLog.coreSize = _selectedCoreSize;
        taskLog.startMeter = double.parse(startMController.text.isEmpty?"0":startMController.text);
        taskLog.endMeter = double.parse(endMController.text.isEmpty?"0":endMController.text);
        taskLog.worker1 = _selectedWorker1;
        taskLog.worker2 = _selectedWorker2;
        taskLog.driller = _selectedDriller;
        taskLog.helper = _selectedHelper;
        var startTime = timeFormat.parse(taskLog.startTime);
        var endTime = timeFormat.parse(taskLog.endTime);
        if(startTime.isAfter(endTime))
          endTime = endTime.add(Duration(days: 1));
        var hoursWorked = endTime.difference(startTime);
        var duration = (hoursWorked.inMinutes/60).toStringAsFixed(2);
        taskLog.workHours=double.parse(duration);
        _selectedNote = noteController.text;
        taskLog.comment = _selectedNote;
        taskLog.coreSize = _selectedCoreSize;

        taskLog.entryDate = DateTime.now();
        taskLog.entryBy = widget.mUser;
        if(startTime.compareTo(tempDayShiftStart)>=0 && startTime.compareTo(tempDayShiftEnd)<=0){
          taskLog.shift="D";
        }
        else{
          taskLog.shift="N";
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
  void clearTaskInput(){
    _selectedTask = null;
    _startTime ="7:00 AM";
    _endTime = "7:00 AM";
    _startMeter = 0;
    _endMeter = 0;
    _selectedWorker1 = null;
    _selectedWorker2 = null;
    _selectedDriller = null;
    _selectedHelper = null;
    _selectedNote ="";
    _selectedCoreSize = null;
    noteController.text="";
    startMController.text="";
    endMController.text="";
    taskIndexForUpdate = -1;
  }
  bool isValidWorkSheet(){
    if(_selectedRigs == null){
      _showDialog("Please choose Rigs");
      return false;
    }

    if(_workDate == null){
      _showDialog("Please put work date");
      return false;
    }
    return true;
  }
  bool isValidTask()
  {
    if(_selectedTask == null){
      _showDialog("Please Choose task");
      return false;
    }
    if(_selectedTask.logType.contains("X")){
      if(_selectedDriller == null && _selectedHelper == null){
        _showDialog("Please choose driller or helper");
        return false;
      }
    }
    if(_selectedTask.logType.contains('E')){
      if(_selectedWorker1 == null){
        _showDialog("Please choose worker!");
            return false;
      }
      if(_selectedWorker1 !=null && _selectedWorker1==_selectedWorker2){
        _showDialog("Please choose different worker!");
        return false;
      }
    }

    if(_selectedTask.logType.contains('P')){
      _startMeter = double.parse(startMController.text.isEmpty?"0":startMController.text);
      _endMeter = double.parse(endMController.text.isEmpty?"0":endMController.text);
      if(_startMeter>_endMeter){
        _showDialog("End meter can not be less than Start meter");
        return false;
      }
    }
    var startTime = timeFormat.parse(_startTime);
    var endTime = timeFormat.parse(_endTime);
    if(startTime.isAfter(endTime))
      endTime = endTime.add(Duration(days: 1));
    var hoursWorked = endTime.difference(startTime);
    if(hoursWorked.inMinutes<=0){
      _showDialog("Start Time Can not be smaller than End time");
      return false;
    }
    return true;
  }
  void setConsumeMaterial(){
    if(isValidConsumeMaterial()){
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
      consumeMaterials.entryBy = widget.mUser;
      consumeMaterials.entryDate = DateTime.now();
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
  }
  void clearComment(){
    commentController.text = "";
    _selectedStatus = null;
    _selectedWorkSheetStatus = null;
  }
  bool isValidConsumeMaterial()
  {
    if(_selectedMaterial == null){
      _showDialog("Please Choose Material");
      return false;
    }
    if(!CommonFunction.isNumeric(materialQtyController.text)){
        _showDialog("Please put quantity!");
        return false;
    }
    return true;
  }
  bool isValidComment()
  {
    if(commentController.text.isEmpty){
      _showDialog("Please put comment!");
      return false;
    }
    return true;
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

  Widget loadLogTaskList()
  {
    if(_isLoading)
      return _showCircularProgress();
    if(_taskLogs !=null && _taskLogs.length>0)
      {

          _taskLogs.sort((a,b){
            var aStartTime = timeFormat.parse(a.startTime);
            var bStartTime = timeFormat.parse(b.startTime);
            return aStartTime.compareTo(bStartTime);
          });
        return ListView.separated(
          shrinkWrap: true,
          separatorBuilder: (context, index) {
            return Divider();
          },
          itemCount: _taskLogs.length,
          itemBuilder: (BuildContext context,int index){
            var startTime = timeFormat.parse(_taskLogs[index].startTime);
            var endTime = timeFormat.parse(_taskLogs[index].endTime);
            if(startTime.isAfter(endTime))
              endTime = endTime.add(Duration(days: 1));
            var hoursWorked = endTime.difference(startTime);
            var duration = (hoursWorked.inMinutes/60).toStringAsFixed(2);
            _startMeter = _taskLogs[index].startMeter;
            _endMeter = _taskLogs[index].endMeter;
            String displayWorker ="";
            if(_taskLogs[index].task.logType.contains("X")){
              displayWorker = _taskLogs[index].driller !=null?('(D)'+_taskLogs[index].driller.lastName+' '+ _taskLogs[index].driller.firstName+'\n'):'';
              displayWorker+= _taskLogs[index].helper !=null?('(H)'+_taskLogs[index].helper.lastName+' '+ _taskLogs[index].helper.firstName+''):'';
            }
            else if(_taskLogs[index].task.logType.contains("E")){
              displayWorker = _taskLogs[index].worker1 !=null?(_taskLogs[index].worker1.lastName+' '+ _taskLogs[index].worker1.firstName+'(1)\n'):'';
              displayWorker += _taskLogs[index].worker2 !=null?(_taskLogs[index].worker2.lastName+' '+ _taskLogs[index].worker2.firstName)+'(2)':'';
            }
            String displayProgress;
            double workDoneProgress=0;
            if(_endTime !=null && _startMeter !=null){
              workDoneProgress = (_endMeter -_startMeter).abs();
             displayProgress = workDoneProgress.toStringAsFixed(2)+"M";
            }
            String displayNote = _taskLogs[index].comment!=null?_taskLogs[index].comment:"";
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
                    title: Text(_taskLogs[index].startTime),
                  ),
                ),
                new Expanded(
                  flex:2,
                  child:ListTile(
                    title: Text(_taskLogs[index].endTime),
                  ),
                ),
                new Expanded(
                  flex:3,
                  child:ListTile(
                    title: Text(displayNote),
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
                  title: Text(_consumeMaterials[index].material.name+'-'+_consumeMaterials[index].material.details),
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
      _comments.sort((a,b){
        return b.entryDate.compareTo(a.entryDate);
      });
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
              new Expanded(
                  child:ListTile(
                    title: Text(_comments[index].entryBy.lastName),
                  )),
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
        _selectedCoreSize =_taskLogs[index].coreSize;
        _selectedWorker1 =_taskLogs[index].worker1;
        _selectedWorker2 =_taskLogs[index].worker2;
        _selectedDriller = _taskLogs[index].driller;
        _selectedHelper = _taskLogs[index].helper;
        _startTime = _taskLogs[index].startTime;
        _endTime = _taskLogs[index].endTime;
        _startMeter =_taskLogs[index].startMeter;
        startMController.text=_startMeter !=null?_startMeter.toString():"";
        _endMeter = _taskLogs[index].endMeter;
        endMController.text = _endMeter !=null?_endMeter.toString():"";
        _selectedNote = _taskLogs[index].comment;
        noteController.text = _selectedNote;
      }
  }
  void loadUsedMaterialForUpdate(int index){
    if(_consumeMaterials.length > index){
      usedMaterialIndexForUpdate = index;
      _selectedUsedMaterial = _consumeMaterials[index];
      _selectedMaterial = _selectedUsedMaterial.material;
      materialQtyController.text = _selectedUsedMaterial.qty.toString();

    }
  }
  void saveWorkSheet(){
    _selectedHoles = holeController.text;
    if(!isValidWorkSheet()) {
      return;
    }
    if(widget.mWorkSheet==null)
      {
        widget.mWorkSheet = new WorkSheet(null, null);
        widget.mWorkSheet.entryDate = DateTime.now();
        widget.mWorkSheet.entryBy = widget.mUser;
      }
    widget.mWorkSheet.rigs = _selectedRigs;
    widget.mWorkSheet.dip = dipController.text;
    widget.mWorkSheet.holes = _selectedHoles;
    widget.mWorkSheet.workDate = _workDate.dateTime;
    widget.mWorkSheet.taskLogs = _taskLogs;
    widget.mWorkSheet.consumeMaterials = _consumeMaterials;
    widget.mWorkSheet.comments = _comments;
    if(_selectedWorkSheetStatus == null && widget.mWorkSheet.currentStatus == null){
      _selectedWorkSheetStatus = new WorkSheetStatus("enableOP");
      _selectedWorkSheetStatus.entryBy=widget.mUser;
      _selectedWorkSheetStatus.entryDate = new DateTime.now();
    }
    saveWorkSheetDB();
//    widget.mWorkSheet.status;
    setState(() {
      worksheetUpdate = false;
    });

  }
  void saveWorkSheetDB() async{
    if(widget.mWorkSheet !=null){
      try {
        if (widget.mWorkSheet.docId == null ||
            widget.mWorkSheet.docId.isEmpty) {
          DocumentReference ref = await _dbReference.document(
              widget.mProject.docId).
          collection("worksheet").add(widget.mWorkSheet.toJson());
          for (TaskLog taskLog in widget.mWorkSheet.taskLogs) {
            await ref.collection("taskLogs").add(
                taskLog.toJson()
            );
          }
          for (ConsumeMaterials material in widget.mWorkSheet
              .consumeMaterials) {
            await ref.collection("consumeMaterials").add(
                material.toJson()
            );
          }
          if (_selectedComments != null) {
            await ref.collection("msg").add(
                _selectedComments.toJson()
            );
          }
          if(_selectedWorkSheetStatus != null){
            await ref.collection("status").add(_selectedWorkSheetStatus.toJson());
            await ref.updateData({"currentStatus":_selectedWorkSheetStatus.status});
          }

        }
        else {
          DocumentReference ref = await _dbReference.document(
              widget.mProject.docId).
          collection("worksheet").document(widget.mWorkSheet.docId);
          ref.setData(widget.mWorkSheet.toJson());
          ref.collection("taskLogs").getDocuments().then((snapshot) {
            for (DocumentSnapshot docs in snapshot.documents) {
              docs.reference.delete();
            }
            for (TaskLog taskLog in widget.mWorkSheet.taskLogs) {
              ref.collection("taskLogs").add(
                  taskLog.toJson()
              );
            }
          });

          ref.collection("consumeMaterials").getDocuments().then((snapshot) {
            for (DocumentSnapshot docs in snapshot.documents) {
              docs.reference.delete();
            }
            for (ConsumeMaterials material in widget.mWorkSheet
                .consumeMaterials) {
              ref.collection("consumeMaterials").add(
                  material.toJson()
              );
            }
          });

          if (_selectedComments != null) {
            await ref.collection("msg").add(
                _selectedComments.toJson()
            );
          }
          if(_selectedWorkSheetStatus != null){
            await ref.collection("status").add(_selectedWorkSheetStatus.toJson());
            await ref.updateData({"currentStatus":_selectedWorkSheetStatus.status});
          }
        }
        clearTaskInput();
        clearConsumeMaterialInput();
        clearComment();
        Navigator.pop(context, 'reload');
      }catch(exception){
        _showDialog(exception.toString());
      }

    }
  }
  void submitWorkSheet(){

   // _selectedStatus = nextStagesController.text;
    _selectedComments = new Comments(commentController.text);
    _selectedComments.entryDate = DateTime.now();
    _selectedComments.entryBy = widget.mUser;
    if(_selectedStatus!=null && _selectedStatus.isNotEmpty){

      _selectedWorkSheetStatus = new WorkSheetStatus(_selectedStatus);
      _selectedWorkSheetStatus.entryBy=widget.mUser;
      _selectedWorkSheetStatus.entryDate = new DateTime.now();
    }
    saveWorkSheet();
  }
   _submitConfirmation(BuildContext context){
    if(nextStagesController.text.isEmpty){
      _showDialog("Select Submit to ");
      return false;
    }
    if(widget.mUser.appSettings.getStageDetails(_selectedStatus)!=nextStagesController.text){
      _showDialog("Plesae select submit to");
      return false;
    }
    return showDialog(
      context: context,
      child: AlertDialog(
        title: Text('Submit Worksheet'),
        content: Text('Are you sure to submit the worksheet?'),
        actions: <Widget>[
          FlatButton(
            onPressed: (){
              Navigator.of(context).pop(false);
            },
            child: Text('No'),
          ),
          FlatButton(
            onPressed: (){
              submitWorkSheet();
              Navigator.of(context).pop(false);
            },
            child: Text('Yes'),
          )
        ],
      ),
    );
  }

}
class DateTimeWrapper{
  DateTime dateTime;
  DateTimeWrapper({this.dateTime});
}
class TabMenu {
  const TabMenu({this.title, this.shortName, this.icon});

  final String title;
  final String shortName;
  final IconData icon;
}

const List<TabMenu> choices = const <TabMenu>[
  const TabMenu(title: 'Tasks', shortName: 'task', icon: Icons.directions_car),
  const TabMenu(title: 'Used Materials', shortName: 'material', icon: Icons.arrow_forward),
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

