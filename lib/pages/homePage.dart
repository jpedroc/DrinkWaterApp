
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:procura_se/controllers/user_water_controller.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _setTime = "00:00";
  UserWaterController controller = new UserWaterController();
  String _hour;
  String _minute;
  String _time;
  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  TextEditingController _timeController = TextEditingController();


  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null)
      selectedTime = picked;
    _hour = selectedTime.hour.toString();
    _minute = selectedTime.minute.toString();
    _time = _hour + ' : ' + _minute;
    _timeController.text = _time;
    _timeController.text = formatDate(
        DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
        [hh, ':', nn, " ", am]).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Drink Water'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text("${_setTime}"),
            SizedBox(height: 20.0,),
            RaisedButton(
              onPressed: () => _selectTime(context),
              child: Text('Informe o horário que você acorda:'),
            ),
          ],
        ),
      ),
    );
  }

}
