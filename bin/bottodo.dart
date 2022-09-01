import 'dart:convert';
import 'dart:developer';

import 'package:hive/hive.dart';

import 'models/telega_class.dart';
import 'models/user.dart';
import 't.dart';

List<User> users = [];

Future<void> main(List<String> args) async {
  print('dart TO_DO bot v1 start...');

  Telega telega = Telega(tkn: token);

  Hive.init('./');

  var box = await Hive.openBox('users');

  //users = List.from((box.get('users') ?? '[]').map((e) => User.fromJson(e)));
  users = List.from(
      json.decode(box.get('users') ?? '[]').map((e) => User.fromJson(e)));

  telega.longPolling().listen((event) {
    handle(event, telega, box);
  });
}

void handle(event, Telega telega, Box<dynamic> box) {
  //log(event.toString());
  Map<String, dynamic> incomeMessage = event;
  log(incomeMessage.toString());
  if (!incomeMessage.containsKey('callback_query')) {
    if (users
        .where(
            (user) => user.telegramId == incomeMessage['message']['chat']['id'])
        .isEmpty) {
      users.add(User(
          telegramId: incomeMessage['message']['chat']['id'],
          name: incomeMessage['message']['chat']['first_name']));
    }
    print(users.toString());
    User thisUser = users.firstWhere(
        (user) => user.telegramId == incomeMessage['message']['chat']['id']);
    thisUser.analizeMessage(incomeMessage, telega);
  } else {
    if (users
        .where((user) =>
            user.telegramId == incomeMessage['callback_query']['from']['id'])
        .isEmpty) {
      users.add(User(
          telegramId: incomeMessage['callback_query']['from']['id'],
          name: incomeMessage['callback_query']['from']['first_name']));
    }
    User thisUser = users.firstWhere((user) =>
        user.telegramId == incomeMessage['callback_query']['from']['id']);
    thisUser.analizeInline(incomeMessage, telega);
  }
  box.put('users', json.encode(users));
}
