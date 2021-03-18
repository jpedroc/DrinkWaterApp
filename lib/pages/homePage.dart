import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:procura_se/controllers/user_water_controller.dart';
import 'package:procura_se/domain/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> historic = [];
  String _today;
  double percentGoal = 0.0;
  User userInfo = new User();
  UserWaterController controller = new UserWaterController();
  String _hour;
  String _minute;
  String _time;
  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  TextEditingController bedtimeController = TextEditingController();
  TextEditingController wakeUpTimeController = TextEditingController();
  TextEditingController waterGoalController = TextEditingController();
  TextEditingController amountDrink = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  Future<List<String>> _loadHistoric() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list;
    return prefs.getStringList('historic').map((e) => list.add(e));
  }

  _initPage() async {
    this.historic = _loadHistoric().then((value) => value);
    print(_getDateNow());
    this.userInfo = new User();
    this._today = _getDateNow();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      String date = (prefs.getString('today') ?? null);
      if(date != null || _today != date) {
        _today = date;
        prefs.setString('today', _today);
        _setHistoric(this.userInfo.progressDay);
        userInfo.progressDay = 0;
        this.percentGoal = 0.0;
      }
      else {
        this.userInfo.progressDay = prefs.getInt('progressDay') ?? 0;
        this.percentGoal = prefs.getDouble('percentGoal');
      }
      this.userInfo.waterGoal = prefs.getInt("waterGoal") ?? 0;
      this.waterGoalController.text = prefs.getInt("waterGoal").toString() ?? "";
      this.userInfo.timeWakeUp = prefs.getString('timeWakeUp');
      this.wakeUpTimeController.text = prefs.getString("timeWakeUp") ?? "";
      this.userInfo.bedtime = prefs.getString('bedtime');
      this.bedtimeController.text = prefs.getString("bedtime") ?? "";
    });
  }

  String _getDateNow() {
    return formatDate(DateTime.now(), [dd, '/', mm, '/', yy]);
  }

  _setHistoric(int progressDay) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(this.historic.length == 7) {
      this.historic.removeAt(0);
      this.historic = historic.where((day) => day != null).toList();
    }
    this.historic.add("${_getDateNow()}, ${progressDay}");
  }

  Future<void> _selectTime(BuildContext contexte, TextEditingController controller, String keyTime) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
        _hour = selectedTime.hour.toString();
        _minute = selectedTime.minute.toString();
        _time = _hour + ' : ' + _minute;
        controller.text = _time;
        controller.text = formatDate(
            DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
            [hh, ':', nn, " ", am]).toString();
        prefs.setString(keyTime, _time);
      });
    }
  }

  void drinkWater() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(this.userInfo.waterGoal > 0) {
      this.userInfo.progressDay += int.parse(this.amountDrink.text);
      prefs.setInt('progressDay', this.userInfo.progressDay);
      this.percentGoal = (userInfo.progressDay / userInfo.waterGoal).toDouble() > 1.0 ? 1.0 : (userInfo.progressDay / userInfo.waterGoal).toDouble();
      prefs.setDouble('percentGoal', this.percentGoal);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Drink Water'),
      ),
      body: ListView(
        padding: EdgeInsets.only(top: 8.0),
        children: <Widget>[
          new Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: new InkWell(
                onTap:() => setState(() {
                  _selectTime(context, wakeUpTimeController, "timeWakeUp");
                }),
                child: TextFormField(
                  decoration: InputDecoration(
                      labelText: "Horario que acorda",
                      hintText: wakeUpTimeController.text
                  ),
                  keyboardType: TextInputType.text,
                  enabled: false,
                  controller: wakeUpTimeController,
                )
            ),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: new InkWell(
                onTap:() => setState(() {
                  _selectTime(context, bedtimeController, "bedtime");
                }),
                child: TextFormField(
                  decoration: InputDecoration(
                      labelText: "Horario que dorme",
                      hintText: wakeUpTimeController.text
                  ),
                  keyboardType: TextInputType.text,
                  enabled: false,
                  controller: bedtimeController,
                )
            )
          ),
          new Padding(
              padding: EdgeInsets.only(top:8.0),
              child: new TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    hintText: "Qual sua meta? (em ml)",
                    labelText: "Meta:"
                ),
                controller: waterGoalController,
                onEditingComplete:
                    () => setState(() {
                  setWaterGoal();
                }),
              ),
          ),
          new Padding(
            padding: EdgeInsets.all(0.8),
            child: new TextFormField(
              keyboardType: TextInputType.number,
              controller: amountDrink,
              decoration: InputDecoration(
                  hintText: "Quantos mls você bebeu?",
                  labelText: "Quantidade bebida:"
              ),
            ),
          ),
          new Padding(
              padding: EdgeInsets.only(top:8.0),
              child: new Ink(
                decoration: const ShapeDecoration(
                    color: Colors.blue,
                    shape: CircleBorder()
                ),
                child: IconButton(
                  alignment: Alignment.center,
                  color: Colors.white,
                  onPressed: () => setState(() {drinkWater();}),
                  icon: const Icon(Icons.local_drink_outlined ),
                ),
              )
          ),
          new Padding(
            padding: EdgeInsets.only(top:8.0),
            child: new CircularPercentIndicator(
              radius: 200.0,
              lineWidth: 20.0,
              center: new Text("${userInfo.progressDay} ml"),
              percent: percentGoal,
              progressColor: Colors.blue,
            )
          ),
          new Padding(
            padding: EdgeInsets.only(top:15.0),
            child: createTable(),
          )
        ],
      )
    );
  }

}
