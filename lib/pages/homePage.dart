
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

  _initPage() async {
    this.userInfo = new User();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      String date = (prefs.getString('today') ?? null);
      if(date != null && _today != date) {
        _today = date;
        prefs.setString('today', _today);
        userInfo.progressDay = 0;
      }
      else {
        this.userInfo.progressDay = prefs.getInt('progressDay') ?? 0;
      }
      this.userInfo.waterGoal = prefs.getInt("waterGoal") ?? 0;
      this.waterGoalController.text = prefs.getInt("waterGoal").toString() ?? "";
      this.userInfo.timeWakeUp = prefs.getString('timeWakeUp');
      this.wakeUpTimeController.text = prefs.getString("timeWakeUp") ?? "";
      this.userInfo.bedtime = prefs.getString('bedtime');
      this.bedtimeController.text = prefs.getString("bedtime") ?? "";
      this.percentGoal = prefs.getDouble('percentGoal') ?? 0.0;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Drink Water'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new InkWell(
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
            new InkWell(
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
            ),
            new TextFormField(
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
            new Padding(
              padding: EdgeInsets.all(0.8),
            ),
            new TextFormField(
              keyboardType: TextInputType.number,
              controller: amountDrink,
              decoration: InputDecoration(
                hintText: "Quantos mls você bebeu?",
                labelText: "Quantidade bebida:"
              ),
            ),
            new Ink(
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
            ),
            new CircularPercentIndicator(
              radius: 200.0,
              lineWidth: 20.0,
              center: new Text("${userInfo.progressDay} ml"),
              percent: percentGoal,
              progressColor: Colors.blue,
            )
          ],
        ),
      ),
    );
  }

}
