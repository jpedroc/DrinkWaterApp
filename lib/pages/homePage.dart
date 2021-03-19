import 'package:date_format/date_format.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:procura_se/domain/user.dart';
import 'package:procura_se/water_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _message = "";
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final controller = WaterController();

  @override
  void initState() {
    super.initState();
    _registerOnFirebase();
    getMessage();
    _initPage();
  }

  _registerOnFirebase() {
    _firebaseMessaging.subscribeToTopic('all');
    _firebaseMessaging.getToken().then((token) => print(token));
  }

  void getMessage() {
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          // if()
          setState(() => _message = message["notification"]["body"]);
        }, onResume: (Map<String, dynamic> message) async {
      setState(() => _message = message["notification"]["body"]);
    }, onLaunch: (Map<String, dynamic> message) async {
      setState(() => _message = message["notification"]["body"]);
    });
  }

  _initPage() async {
    controller.loadHistoric().then((value) => controller.historic = value);
    controller.userInfo = new User();
    controller.today = controller.getDateNow();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      String date = prefs.getString('today');
      if(date != null && controller.today != date) {
        controller.today = date;
        prefs.setString('today', controller.today);
        controller.setHistoric(controller.userInfo.progressDay);
        controller.userInfo.progressDay = 0;
        controller.percentGoal = 0.0;
      }
      else {
        controller.userInfo.progressDay = prefs.getInt('progressDay') ?? 0;
        controller.percentGoal = prefs.getDouble('percentGoal') ?? 0.0;
      }
      controller.userInfo.waterGoal = prefs.getInt("waterGoal") ?? 0;
      controller.waterGoalController.text = prefs.getInt("waterGoal").toString() ?? "";
      controller.userInfo.timeWakeUp = prefs.getString('timeWakeUp');
      controller.wakeUpTimeController.text = prefs.getString("timeWakeUp") ?? "";
      controller.userInfo.bedtime = prefs.getString('bedtime');
      controller.bedtimeController.text = prefs.getString("bedtime") ?? "";
    });
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
                  controller.selectTime(context, controller.wakeUpTimeController, "timeWakeUp");
                }),
                child: TextFormField(
                  decoration: InputDecoration(
                      labelText: "Horario que acorda",
                      hintText: controller.wakeUpTimeController.text
                  ),
                  keyboardType: TextInputType.text,
                  enabled: false,
                  controller: controller.wakeUpTimeController,
                )
            ),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: new InkWell(
                onTap:() => setState(() {
                  controller.selectTime(context, controller.bedtimeController, "bedtime");
                }),
                child: TextFormField(
                  decoration: InputDecoration(
                      labelText: "Horario que dorme",
                      hintText: controller.wakeUpTimeController.text
                  ),
                  keyboardType: TextInputType.text,
                  enabled: false,
                  controller: controller.bedtimeController,
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
                controller: controller.waterGoalController,
                onEditingComplete:
                    () => setState(() {
                      controller.setWaterGoal();
                }),
              ),
          ),
          new Padding(
            padding: EdgeInsets.all(0.8),
            child: new TextFormField(
              keyboardType: TextInputType.number,
              controller: controller.amountDrink,
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
                  onPressed: () => setState(() {controller.drinkWater(this.context);}),
                  icon: const Icon(Icons.local_drink_outlined ),
                ),
              )
          ),
          new Padding(
            padding: EdgeInsets.only(top:8.0),
            child: new CircularPercentIndicator(
              radius: 200.0,
              lineWidth: 20.0,
              center: new Text("${controller.userInfo.progressDay} ml"),
              percent: controller.percentGoal,
              progressColor: Colors.blue,
            )
          ),
          new Padding(
            padding: EdgeInsets.only(top:15.0),
            child: controller.createTable(),
          )
        ],
      )
    );
  }

}
