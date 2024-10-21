import 'package:flutter/foundation.dart';
import '../models/machine.dart'; // Импорт модели Machine
import '../utils/db_helper.dart'; // Импорт DBHelper для работы с базой данных

class MachineService extends ChangeNotifier {
  List<Machine> _machines = [];
  DBHelper dbHelper = DBHelper(); // Инициализация DBHelper

  List<Machine> get machines => _machines;

  // Загрузка машин из базы данных при запуске
  Future<void> loadMachines() async {
    _machines = await dbHelper.getMachines();
    notifyListeners(); // Уведомляем подписчиков об изменении
  }

  // Добавление новой машины
  void addMachine(String number, double cycleTime) {
    final newMachine = Machine(
      number: number,
      cycleTime: cycleTime,
      nextProductionTime: DateTime.now().add(Duration(minutes: cycleTime.toInt())),
      addedTime: DateTime.now(),
    );
    _machines.add(newMachine);
    dbHelper.insertMachine(newMachine); // Сохранение машины в базу данных
    notifyListeners(); // Уведомляем подписчиков об изменении
  }

  // Обновление настроек машины (цикл и время следующего выхода продукции)
  void updateMachineSettings(Machine machine, double newCycleTime, DateTime newNextProductionTime) {
    machine.cycleTime = newCycleTime;
    machine.nextProductionTime = newNextProductionTime;
    dbHelper.updateMachine(machine); // Обновляем машину в базе данных
    notifyListeners(); // Уведомляем подписчиков об изменении
  }

  // Переключение состояния машины (включена/остановлена)
  void toggleMachineState(Machine machine) {
    machine.isStopped = !machine.isStopped;
    if (machine.isStopped) {
      machine.stopTime = DateTime.now(); // Устанавливаем время остановки
    } else {
      machine.stopTime = null; // Сбрасываем время остановки при перезапуске
    }
    dbHelper.updateMachine(machine); // Обновляем машину в базе данных
    notifyListeners(); // Уведомляем подписчиков об изменении
  }

  // Обновление времени производства для каждой машины
  void updateProductionTimes() {
    for (var machine in _machines) {
      if (!machine.isStopped && DateTime.now().isAfter(machine.nextProductionTime)) {
        machine.updateNextProductionTime(); // Обновляем время следующего выхода
        dbHelper.updateMachine(machine); // Сохраняем изменения в базе данных
      }
    }
    notifyListeners(); // Уведомляем подписчиков об изменении
  }

// Удаление машины
void deleteMachine(Machine machine) {
  _machines.remove(machine);
  dbHelper.deleteMachine(machine.id!); // Удаляем машину из базы данных
  notifyListeners(); // Уведомляем подписчиков об изменении сразу
}

  // Обновление продукции для машины
  void updateMachineProduct(Machine machine, String newProduct) {
    machine.product = newProduct;
    dbHelper.updateMachine(machine); // Обновляем в базе данных
    notifyListeners(); // Уведомляем об изменении
  }

  // Обновление заглушенных крышек для машины
  void updateMachineCaps(Machine machine, int newCaps) {
    machine.caps = newCaps;
    dbHelper.updateMachine(machine); // Обновляем в базе данных
    notifyListeners(); // Уведомляем об изменении
  }
}
