import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:procura_se/domain/user.dart';

class UserWaterController {
  User userInfo;
  TextEditingController badtimeController = TextEditingController();
  TextEditingController wakeUpTimeController = TextEditingController();
  TextEditingController waterGoalController = TextEditingController();
  TextEditingController amountDrink = TextEditingController();
  double percentGoal;


  void initUserConfig() {
    userInfo = new User();
  }

  void drinkWater() {
    userInfo.progressDay += int.parse(amountDrink.text);
    percentGoal = userInfo.waterGoal / userInfo.progressDay;
  }


}
