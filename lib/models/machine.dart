class Machine {
  int? id;
  String number;
  double cycleTime;
  String product;
  int caps;
  DateTime nextProductionTime;
  DateTime addedTime;
  DateTime? stopTime;
  bool isStopped;

  Machine({
    this.id,
    required this.number,
    required this.cycleTime,
    this.product = '',
    this.caps = 0,
    required this.nextProductionTime,
    required this.addedTime,
    this.stopTime,
    this.isStopped = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number': number,
      'cycleTime': cycleTime,
      'product': product,
      'caps': caps,
      'nextProductionTime': nextProductionTime.toIso8601String(),
      'addedTime': addedTime.toIso8601String(),
      'stopTime': stopTime?.toIso8601String(),
      'isStopped': isStopped ? 1 : 0,
    };
  }

  static Machine fromMap(Map<String, dynamic> map) {
    return Machine(
      id: map['id'],
      number: map['number'],
      cycleTime: map['cycleTime'],
      product: map['product'],
      caps: map['caps'],
      nextProductionTime: DateTime.parse(map['nextProductionTime']),
      addedTime: DateTime.parse(map['addedTime']),
      stopTime: map['stopTime'] != null ? DateTime.parse(map['stopTime']) : null,
      isStopped: map['isStopped'] == 1,
    );
  }

  void updateNextProductionTime() {
    nextProductionTime = nextProductionTime.add(Duration(minutes: cycleTime.toInt()));
  }

  int calculateProducedItems() {
    // Логика для подсчета продукции с учетом остановки машины
    final currentTime = DateTime.now();
    if (stopTime != null) {
      return stopTime!.difference(addedTime).inMinutes ~/ cycleTime;
    } else {
      return currentTime.difference(addedTime).inMinutes ~/ cycleTime;
    }
  }
}
