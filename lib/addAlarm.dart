import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:alarm_demo_clock/util/widgetsUtil.dart';
import 'package:alarm_demo_clock/util/notificationUtil.dart';
import 'main.dart';
import 'storage.dart';

class AddAlarmPage extends StatefulWidget {


  @override
  _AddAlarmPageState createState() => _AddAlarmPageState();
}

class _AddAlarmPageState extends State<AddAlarmPage> {
  final _formKey = GlobalKey<FormState>();
  late String _dateString = DateFormat.MMMMd()
      .format(DateTime.now())
      .toString();
      late String _timeString = DateFormat.MMMMd()
      .format(DateTime.now())
      .toString();
  late DateTime _date = DateTime.now(), _time =  DateTime.now();
  late String _remarks = "";
  late String _password = "";

  static Future<void> callback(docId, notificationId, remarks) async {
    var now = tz.TZDateTime.now(
            tz.getLocation(await FlutterNativeTimezone.getLocalTimezone()))
        .add(Duration(seconds: 10));
    await singleNotification(localNotificationsPlugin, now, "Flutter alarm",
        remarks, notificationId, docId, sound: '');
  }

  void onChangePassword(value) => {
        setState(() {
          this._password = value;
        })
      };

  void onChangedRemarks(value) => {
        setState(() {
          this._remarks = value;
        })
      };

  void onConfirmTime(time) {
    setState(() {
      _time = time;
      _timeString = DateFormat.jm().format(_time).toString();
    });
  }

  void onConfirmDate(date) {
    setState(() {
      _date = date;
      _dateString = DateFormat.MMMMd().format(_date).toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF1F8FF),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 25.0),
          child: Form(
            key: _formKey,
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            DatePicker.showDatePicker(
                              context,
                              showTitleActions: true,
                              onConfirm: onConfirmDate,
                              minTime: DateTime.now(),
                              maxTime: DateTime.now().add(Duration(days: 14)),
                            );
                          },
                          child: Text(
                            _dateString == null ?
                                DateFormat.MMMMd()
                                    .format(DateTime.now())
                                    .toString() : _dateString,
                            style:
                                TextStyle(color: Colors.blueGrey, fontSize: 18),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            DatePicker.showTimePicker(
                              context,
                              showTitleActions: true,
                              onConfirm: onConfirmTime,
                              showSecondsColumn: false,
                            );
                          },
                          child: Text(

                                _timeString == null ?
                                DateFormat.jm()
                                    .format(DateTime.now())
                                    .toString() : _timeString,
                            style: TextStyle(color: Colors.amber, fontSize: 60),
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          child: Column(
                            children: [
                              buildRemarksField(onChangedRemarks, initialValue: ''),
                              Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: buildPasswordField(onChangePassword, initialValue: ''),
                              ),
                              buildPasswordRules(),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            RaisedButton(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(color: Colors.green),
                                  borderRadius: BorderRadius.circular(15.0)),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  int notificationId = Random().nextInt(1000);
                                  var docId = await Storage.addAlarm({
                                    'remarks': _remarks,
                                    'date': _date == null ? DateTime.now() : _date,
                                    'time': _time == null ? DateTime.now() : _time,
                                    'password': _password,
                                    'notificationId': notificationId,
                                  });
                                  callback(
                                      docId, notificationId, this._remarks);
                                  Navigator.pop(context);
                                }
                              },
                              child: Text(
                                'Save',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            buildCancelButton(context),
                          ],
                        ),
                      ]),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
