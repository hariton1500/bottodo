import 'dart:convert';
import 'dart:developer';

import 'task.dart';
import 'telega_class.dart';

class User {
  int? telegramId;
  String? name;
  String status = 'new';
  Task candidate = Task(periodicType: 'ones', name: '');
  List<Task> tasks = [];

  User({required this.name, required this.telegramId});

  Map<String, dynamic> toJson() {
    return {
      'telegramId': telegramId,
      'name': name,
      'status': status,
      'candidate': candidate,
      'tasks': tasks
    };
  }

  User.fromJson(Map<String, dynamic> json) {
    log('loading User');
    telegramId = json['telegramId'];
    name = json['name'];
    status = json['status'];
    candidate = Task.fromJson(json['candidate']);
    tasks = List.from((json['tasks'] as List).map((e) => Task.fromJson(e)));
  }

  @override
  String toString() {
    return 'User($telegramId: $name)';
  }

  void analizeMessage(Map<String, dynamic> incomeMessage, Telega telega) {
    String text = incomeMessage['message']['text'] ?? '';
    print('text entered');
    if (text != '') {
      switch (status) {
        case 'new':
          switch (text) {
            case '':
              break;
            default:
              print('no such command');
              telega.sendMessage(this, 'no such command. try one of those:',
                  reply: inline(['new task', 'list of tasks'],
                      ['newtask', 'listoftasks']));
          }
          break;
        case 'asking task name':
          candidate.name = text;
          telega.sendMessage(this, 'task created.',
              reply: inline(
                  ['new task', 'list of tasks'], ['newtask', 'listoftasks']));
          status = 'new';
          tasks.add(candidate);
          break;
        default:
      }
    }
  }

  void analizeInline(Map<String, dynamic> incomeMessage, Telega telega) {
    String data = incomeMessage['callback_query']['data'];
    print('inline button pressed');
    print('status: $status');
    switch (status) {
      case 'new':
        print('data: $data');
        switch (data) {
          case 'newtask':
            status = 'newtask_start';
            telega.sendMessage(
                this, 'creating new task. please choose task periodic type:',
                reply: inline([
                  'one time',
                  'every day',
                  'every week',
                  'every month',
                  'every year'
                ], [
                  'one time',
                  'every day',
                  'every week',
                  'every month',
                  'every year'
                ]));
            break;
          case 'listoftasks':
            telega.sendMessage(this, 'List of tasks:',
                reply: inline(
                    tasks.map((t) => t.name).toList(),
                    tasks
                        .map((t) => 'enter_task:${tasks.indexOf(t)}')
                        .toList()));
            break;
          default:
            if (data.startsWith('enter_task')) {
              int taskIndex = int.parse(data.split(':').last);
              status = 'task_selected:$taskIndex';
            } else {
              print('no such command');
              telega.sendMessage(this, 'no such command. try one of those:',
                  reply: inline(['new task', 'list of tasks'],
                      ['newtask', 'listoftasks']));
            }
        }
        break;
      case 'newtask_start':
        print('status: new task start');
        status = 'asking task name';
        telega.sendMessage(this, 'enter task name');
        print('data: $data');
        switch (data) {
          case 'one time':
            candidate.periodicType = 'ones';
            break;
          case 'every day':
            candidate.periodicType = 'day';
            break;
          case 'every week':
            candidate.periodicType = 'week';
            break;
          case 'every month':
            candidate.periodicType = 'month';
            break;
          case 'every year':
            candidate.periodicType = 'year';
            break;
        }
        break;
      case 'listoftasks':
        print(data);
        int taskIndex = int.parse(data.split(':').last);
        status = 'entered_task:$taskIndex';
        telega.sendMessage(this, 'choose comand for this task:',
            reply: inline([
              'delete',
              'mark as done',
              'return'
            ], [
              'delete task:$taskIndex',
              'mark as done:$taskIndex',
              'return'
            ]));
        break;

      default:
        if (status.startsWith('entered_task')) {
          int taskIndex = int.parse(status.split(':').last);
          print('entered task ${tasks[taskIndex].name}');
          print('data: $data');
          switch (data) {
            case 'delete':
              tasks.removeAt(taskIndex);
              break;
            case 'mark as done':
              tasks[taskIndex].isDone = true;
              break;
            default:
          }
          status = 'listoftasks';
          telega.sendMessage(this, 'List of tasks:',
              reply: inline(tasks.map((t) => t.name).toList(),
                  tasks.map((t) => 'enter_task:${tasks.indexOf(t)}').toList()));
        }
        if (status.startsWith('task_selected')) {
          int taskIndex = int.parse(status.split(':').last);
          print('selected task ${tasks[taskIndex].name}');
          status = 'entered_task:$taskIndex';
          telega.sendMessage(this, 'choose comand for this task:',
              reply: inline([
                'delete',
                'mark as done',
                'return'
              ], [
                'delete task:$taskIndex',
                'mark as done:$taskIndex',
                'return'
              ]));
        }
    }
  }

  String inline(List<String> texts, List<String> callbacks) {
    var res = {
      'inline_keyboard': [
        for (int i = 0; i < texts.length; i++)
          [
            {'text': texts[i], 'callback_data': callbacks[i]}
          ]
      ]
    };
    //print(res);
    return json.encode(res);
  }
}
