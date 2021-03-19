import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:procura_se/domain/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class WaterController {
  List<String> historic = [];
  String _hour;
  String _minute;
  String time;
  String today;
  double percentGoal = 0.0;
  User userInfo = new User();
  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  TextEditingController bedtimeController = TextEditingController();
  TextEditingController wakeUpTimeController = TextEditingController();
  TextEditingController waterGoalController = TextEditingController();
  TextEditingController amountDrink = TextEditingController();

  Future<List<String>> loadHistoric() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('historic') ?? ["17/03/2021,1750", "18/03/2021,8000"];
  }

  String getDateNow() {
    return formatDate(DateTime.now(), [dd, '/', mm, '/', yy]);
  }

  setHistoric(int progressDay) async{
    final prefs = await SharedPreferences.getInstance();
    if(this.historic.length == 7) {
      this.historic.removeAt(0);
      this.historic = historic.where((day) => day != null).toList();
    }
    this.historic.add("${getDateNow()}, $progressDay");
    prefs.setStringList('historic', this.historic);
  }

  Future<void> selectTime(BuildContext context, TextEditingController controller, String keyTime) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) {
        selectedTime = picked;
        _hour = selectedTime.hour.toString();
        _minute = selectedTime.minute.toString();
        time = _hour + ' : ' + _minute;
        controller.text = time;
        controller.text = formatDate(
            DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
            [hh, ':', nn, " ", am]).toString();
        prefs.setString(keyTime, time);
    }
  }

  void goalCompleted(BuildContext context) {
    if(this.userInfo.progressDay >= this.userInfo.waterGoal) {
      Toast.show("Parabéns, a meta do dia foi batida!!!", context, duration: Toast.LENGTH_LONG, gravity: Toast.TOP, backgroundColor: Colors.blue);
    }
  }

  void drinkWater(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(this.userInfo.waterGoal > 0) {
      this.userInfo.progressDay += int.parse(this.amountDrink.text);
      prefs.setInt('progressDay', this.userInfo.progressDay);
      this.percentGoal = (userInfo.progressDay / userInfo.waterGoal).toDouble() > 1.0 ? 1.0 : (userInfo.progressDay / userInfo.waterGoal).toDouble();
      prefs.setDouble('percentGoal', this.percentGoal);
      goalCompleted(context);
    }
  }

  void setWaterGoal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.userInfo.waterGoal = int.parse(waterGoalController.text);
    prefs.setInt('waterGoal', this.userInfo.waterGoal);
  }

  _loadTable() {
    return this.historic.map((day) => _createRow(day)) ?? null;
  }

  _createRow(String nameList) {
    return TableRow(
      children: nameList.split(',').map((name) {
        return Container(
          alignment: Alignment.center,
          child: Text(
            name,
            style: TextStyle(fontSize: 20.0),
          ),
          padding: EdgeInsets.all(8.0),
        );
      }).toList(),
    );
  }

  createTable() {
    return Table(
      defaultColumnWidth: FixedColumnWidth(150.0),
      border: TableBorder(
        horizontalInside: BorderSide(
          color: Colors.black,
          style: BorderStyle.solid,
          width: 1.0,
        ),
        verticalInside: BorderSide(
          color: Colors.black,
          style: BorderStyle.solid,
          width: 1.0,
        ),
      ),
      children: [
        _createRow("Dia,Quantidade bebida"),
        ..._loadTable()
      ],
    );
  }
}
