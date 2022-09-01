import 'dart:convert';
import 'dart:developer';
import 'dart:io';
//import 'helpers.dart';
import 'package:http/http.dart' as http;

import 'user.dart';

//import 'user_class.dart';

// class to work with Telegram Bot API

class Telega {
  String? url;
  int? updateId;
  Stream? incoming;

  Telega({required String tkn}) {
    url = 'https://api.telegram.org/bot$tkn/';
    updateId = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    log('Telega object created!');

    try {
      var res = http.get(Uri.parse('${url!}getMe'));
      res.then((value) =>
          log('my name is ${jsonDecode(value.body)['result']['first_name']}'));
    } catch (e) {
      log(e.toString());
      exit(0);
    }
  }

  Future<void> updater() async {
    try {
      log('req = $updateId');
      var res = await http.get(Uri.parse('${url!}getUpdates?offset=$updateId'));
      //updateId = updateId! - 1;
      String body = res.body;
      if (body != '{"ok":true,"result":[]}') {
        log(res.body);
        if (body.startsWith('{"ok":true,"result":')) {
          var messages = jsonDecode(body)['result'];
          //log(messages.runtimeType);
          if (messages is List) {
            for (var message in messages) {
              updateId = message['update_id'] + 1;
              log(updateId.toString());
            }
          }
        }
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Stream longPolling() async* {
    while (true) {
      try {
        //log('req = $updateId');
        var res = await http
            .get(Uri.parse('${url!}getUpdates?offset=$updateId&timeout=30'));
        //updateId = updateId! - 1;
        String body = res.body;
        if (body != '{"ok":true,"result":[]}') {
          //log(res.body);
          if (body.startsWith('{"ok":true,"result":')) {
            var messages = jsonDecode(body)['result'];
            //log(messages.runtimeType);
            if (messages is List) {
              for (var message in messages) {
                updateId = message['update_id'] + 1;
                //log(updateId);
                //handle(message);
                yield message;
              }
            }
          }
        }
      } catch (e) {
        log(e.toString());
      }
    }
  }

  sendMessage(User user, String text, {String? reply}) {
    Map<String, String> _body = {};
    _body['chat_id'] = user.telegramId.toString();
    _body['text'] = text;
    if (reply != null) {
      _body['reply_markup'] = reply;
    }
    var res = http.post(Uri.parse('${url!}sendMessage'), body: _body);
  }
}
