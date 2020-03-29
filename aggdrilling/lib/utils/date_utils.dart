import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
class BasicDateField extends StatelessWidget {
  final format = DateFormat("yyyy-MM-dd");
  String text;
  BasicDateField({this.text});
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
//      Text('${text} (${format.pattern})'),
      DateTimeField(
        format: format,
        onShowPicker: (context, currentValue) {
          return showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              initialDate: currentValue ?? DateTime.now(),
              lastDate: DateTime(2100));
        },
      ),
    ]);
  }
}

class BasicTimeField extends StatelessWidget {
  final format = DateFormat("hh:mm a");
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Text('Basic time field (${format.pattern})'),
      DateTimeField(
        format: format,
        onShowPicker: (context, currentValue) async {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
          );
          return DateTimeField.convert(time);
        },
      ),
    ]);
  }
}

class BasicDateTimeField extends StatelessWidget {
  final format = DateFormat("yyyy-MM-dd HH:mm");
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Text('Basic date & time field (${format.pattern})'),
      DateTimeField(
        format: format,
        onShowPicker: (context, currentValue) async {
          final date = await showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              initialDate: currentValue ?? DateTime.now(),
              lastDate: DateTime(2100));
          if (date != null) {
            final time = await showTimePicker(
              context: context,
              initialTime:
              TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
            );
            return DateTimeField.combine(date, time);
          } else {
            return currentValue;
          }
        },
      ),
    ]);
  }
}

class IosStylePickers extends StatefulWidget {
  @override
  _IosStylePickersState createState() => _IosStylePickersState();
}

class _IosStylePickersState extends State<IosStylePickers> {
  final format = DateFormat("yyyy-MM-dd HH:mm");
  DateTime value;

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Text('iOS style pickers (${format.pattern})'),
      DateTimeField(
        initialValue: value,
        format: format,
        onShowPicker: (context, currentValue) async {
          await showCupertinoModalPopup(
              context: context,
              builder: (context) {
                return CupertinoDatePicker(
                  onDateTimeChanged: (DateTime date) {
                    value = date;
                  },
                );
              });
          setState(() {});
          return value;
        },
      ),
    ]);
  }
}

class ComplexDateTimeField extends StatefulWidget {
  @override
  _ComplexDateTimeFieldState createState() => _ComplexDateTimeFieldState();
}

class _ComplexDateTimeFieldState extends State<ComplexDateTimeField> {
  final format = DateFormat("yyyy-MM-dd HH:mm");
  final initialValue = DateTime.now();

  bool autoValidate = false;
  bool readOnly = true;
  bool showResetIcon = true;
  DateTime value = DateTime.now();
  int changedCount = 0;
  int savedCount = 0;

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Text('Complex date & time field (${format.pattern})'),
      DateTimeField(
        format: format,
        onShowPicker: (context, currentValue) async {
          final date = await showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              initialDate: currentValue ?? DateTime.now(),
              lastDate: DateTime(2100));
          if (date != null) {
            final time = await showTimePicker(
              context: context,
              initialTime:
              TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
            );
            return DateTimeField.combine(date, time);
          } else {
            return currentValue;
          }
        },
        autovalidate: autoValidate,
        validator: (date) => date == null ? 'Invalid date' : null,
        initialValue: initialValue,
        onChanged: (date) => setState(() {
          value = date;
          changedCount++;
        }),
        onSaved: (date) => setState(() {
          value = date;
          savedCount++;
        }),
        resetIcon: showResetIcon ? Icon(Icons.delete) : null,
        readOnly: readOnly,
        decoration: InputDecoration(
            helperText: 'Changed: $changedCount, Saved: $savedCount, $value'),
      ),
      CheckboxListTile(
        title: Text('autoValidate'),
        value: autoValidate,
        onChanged: (value) => setState(() => autoValidate = value),
      ),
      CheckboxListTile(
        title: Text('readOnly'),
        value: readOnly,
        onChanged: (value) => setState(() => readOnly = value),
      ),
      CheckboxListTile(
        title: Text('showResetIcon'),
        value: showResetIcon,
        onChanged: (value) => setState(() => showResetIcon = value),
      ),
    ]);
  }
}

class Clock24Example extends StatelessWidget {
  final format = DateFormat("HH:mm");
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Text('24 hour clock'),
      DateTimeField(
        format: format,
        onShowPicker: (context, currentValue) async {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
            builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(alwaysUse24HourFormat: true),
                child: child),
          );
          return DateTimeField.convert(time);
        },
      ),
    ]);
  }
}

class LocaleExample extends StatelessWidget {
  final format = DateFormat("yyyy-MM-dd HH:mm");

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Text('Changing the pickers\' language'),
      DateTimeField(
        format: format,
        onShowPicker: (context, currentValue) async {
          final date = await showDatePicker(
            context: context,
            firstDate: DateTime(1900),
            initialDate: DateTime.now(),
            lastDate: DateTime(2100),
            builder: (context, child) =>
                Localizations.override(
                  context: context,
                  locale: Locale('zh'),
                  child: child,
                ),
          );
          if (date != null) {
            final time = await showTimePicker(
              context: context,
              initialTime:
              TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
              builder: (context, child) =>
                  Localizations.override(
                    context: context,
                    locale: Locale('zh'),
                    child: child,
                  ),
            );
            return DateTimeField.combine(date, time);
          } else {
            return currentValue;
          }
        },
      ),
    ]);
  }
}
class DateTimePicker extends StatelessWidget {
  const DateTimePicker(
      {Key key,
        this.labelText,
        this.selectedDate,
        this.selectedTime,
        this.selectDate,
        this.selectTime})
      : super(key: key);

  final String labelText;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final ValueChanged<DateTime> selectDate;
  final ValueChanged<TimeOfDay> selectTime;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: new DateTime(1970, 8),
        lastDate: new DateTime(2101));
    if (picked != null && picked != selectedDate) selectDate(picked);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay picked =
    await showTimePicker(context: context, initialTime: selectedTime);
    if (picked != null && picked != selectedTime) selectTime(picked);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle valueStyle = Theme.of(context).textTheme.body1;
    return new Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        new Expanded(
          flex: 4,
          child: new InputDropdown(
            labelText: labelText,
            valueText: new DateFormat.yMMMd().format(selectedDate),
            valueStyle: valueStyle,
            onPressed: () {
              _selectDate(context);
            },
          ),
        ),
        const SizedBox(width: 12.0),
        new Expanded(
          flex: 3,
          child: new InputDropdown(
            valueText: selectedTime.format(context),
            valueStyle: valueStyle,
            onPressed: () {
              _selectTime(context);
            },
          ),
        ),
      ],
    );
  }
}
class InputDropdown extends StatelessWidget {
  const InputDropdown(
      {Key key,
        this.child,
        this.labelText,
        this.valueText,
        this.valueStyle,
        this.onPressed})
      : super(key: key);

  final String labelText;
  final String valueText;
  final TextStyle valueStyle;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return new InkWell(
      onTap: onPressed,
      child: new InputDecorator(
        decoration: new InputDecoration(
          labelText: labelText,
        ),
        baseStyle: valueStyle,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Text(valueText, style: valueStyle),
            new Icon(Icons.arrow_drop_down,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey.shade700
                    : Colors.white70),
          ],
        ),
      ),
    );
  }
}