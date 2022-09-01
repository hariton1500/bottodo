class Task {
  DateTime start = DateTime.now();
  String periodicType = 'ones';
  String name = '';
  String additionalData = '';
  bool isDone = false;

  Task({required this.periodicType, required this.name});

  Task.fromJson(Map<String, dynamic> json) {
    start = DateTime.fromMillisecondsSinceEpoch(json['start']);
    periodicType = json['periodicType'];
    name = json['name'];
    additionalData = json['additionalData'] ?? '';
    isDone = json['isDone'] ?? false;
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start.millisecondsSinceEpoch,
      'periodicType': periodicType,
      'name': name,
      'additionalData': additionalData,
      'isDone': isDone
    };
  }
}
