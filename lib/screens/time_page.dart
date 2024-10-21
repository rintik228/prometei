import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vibration/vibration.dart';
import '../services/machine_service.dart';
import '../models/machine.dart';
import 'dart:async';

class TimePage extends StatefulWidget {
  @override
  _TimePageState createState() => _TimePageState();
}

class _TimePageState extends State<TimePage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Запускаем таймер для обновления времени каждые 45 секунд
    _timer = Timer.periodic(Duration(seconds: 45), (Timer t) => updateTimes());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void updateTimes() {
    setState(() {
      // Обновляем время машин
      Provider.of<MachineService>(context, listen: false).updateProductionTimes();
    });
  }

  void showSettingsDialog(BuildContext context, Machine machine) {
  TextEditingController cycleTimeController = TextEditingController(text: machine.cycleTime.toString());
  TextEditingController nextTimeController = TextEditingController(
      text: "${machine.nextProductionTime.hour.toString().padLeft(2, '0')}:${machine.nextProductionTime.minute.toString().padLeft(2, '0')}");

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFF1F2833),
            border: Border.all(
              color: Color(0xFF888888),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Provider.of<MachineService>(context, listen: false).toggleMachineState(machine);
                        },
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return ScaleTransition(scale: animation, child: child);
                          },
                          child: SvgPicture.asset(
                            machine.isStopped ? 'assets/icons/toggle_off.svg' : 'assets/icons/toggle_on.svg',
                            key: ValueKey<bool>(machine.isStopped),
                            width: 24,  // Размер иконки
                            height: 24,
                            color: machine.isStopped ? Colors.red : Colors.green,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(
                          Icons.close,
                          color: Color(0xFFAAAAAA),
                          size: 28,  // Размер крестика
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),  // Отступ перед заголовком
              Text(
                'Настройки машины',
                style: TextStyle(
                  color: Color(0xFFC5C6C7),
                  fontSize: 20,  // Уменьшенный шрифт заголовка
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Изменить цикл (мин):',
                style: TextStyle(
                  color: machine.isStopped ? Colors.grey : Color(0xFFC5C6C7),
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 5),
              TextField(
                controller: cycleTimeController,
                enabled: !machine.isStopped,
                style: TextStyle(color: machine.isStopped ? Colors.grey : Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: machine.isStopped ? Color(0xFF3E3E3E) : Color(0xFF0B0C10),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF45A29E), width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF45A29E), width: 1),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              Text(
                'Задать время (чч:мм):',
                style: TextStyle(
                  color: machine.isStopped ? Colors.grey : Color(0xFFC5C6C7),
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 5),
              TextField(
                controller: nextTimeController,
                enabled: !machine.isStopped,
                style: TextStyle(color: machine.isStopped ? Colors.grey : Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: machine.isStopped ? Color(0xFF3E3E3E) : Color(0xFF0B0C10),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF45A29E), width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF45A29E), width: 1),
                  ),
                ),
                keyboardType: TextInputType.datetime,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: machine.isStopped ? null : () {
                  double newCycleTime = double.tryParse(cycleTimeController.text) ?? machine.cycleTime;
                  List<String> timeParts = nextTimeController.text.split(":");
                  int hours = int.tryParse(timeParts[0]) ?? machine.nextProductionTime.hour;
                  int minutes = int.tryParse(timeParts[1]) ?? machine.nextProductionTime.minute;
                  DateTime newNextProductionTime = DateTime(
                    machine.nextProductionTime.year,
                    machine.nextProductionTime.month,
                    machine.nextProductionTime.day,
                    hours,
                    minutes,
                  );
                  Provider.of<MachineService>(context, listen: false).updateMachineSettings(machine, newCycleTime, newNextProductionTime);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: machine.isStopped ? Colors.grey : Color(0xFF45A29E),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Сохранить',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1F2833),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 80), // Увеличен отступ для "Время [1 цех]"
                Text(
                  'Время [1 цех]',
                  style: TextStyle(
                    color: Color(0xFFC5C6C7),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 40),
                CustomAnimatedButton(
                  label: 'Назад',
                  onPressed: () => Navigator.of(context).pop(),
                ),
                SizedBox(height: 20),
                CustomAnimatedButton(
                  label: 'Добавить машину',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        String machineNumber = '';
                        String cycleTime = '';
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Color(0xFF1F2833),
                              border: Border.all(
                                color: Color(0xFF888888),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Добавить машину',
                                      style: TextStyle(
                                        color: Color(0xFFC5C6C7),
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => Navigator.of(context).pop(),
                                      child: Icon(
                                        Icons.close,
                                        color: Color(0xFFAAAAAA),
                                        size: 28,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'Номер машины:',
                                  style: TextStyle(
                                    color: Color(0xFFC5C6C7),
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 5),
                                TextField(
                                  onChanged: (value) => machineNumber = value,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Color(0xFF0B0C10),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFF45A29E), width: 1),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFF45A29E), width: 1),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Цикл (мин):',
                                  style: TextStyle(
                                    color: Color(0xFFC5C6C7),
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 5),
                                TextField(
                                  onChanged: (value) => cycleTime = value,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Color(0xFF0B0C10),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFF45A29E), width: 1),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFF45A29E), width: 1),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    Provider.of<MachineService>(context, listen: false)
                                        .addMachine(machineNumber, double.parse(cycleTime));
                                    Navigator.of(context).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF45A29E),
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    minimumSize: Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Добавить',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Consumer<MachineService>(
                    builder: (context, machineService, child) {
                      final machines = machineService.machines;
                      machines.sort((a, b) {
                        if (a.isStopped && !b.isStopped) {
                          return 1;
                        } else if (!a.isStopped && b.isStopped) {
                          return -1;
                        } else {
                          return a.nextProductionTime.compareTo(b.nextProductionTime);
                        }
                      });

                      return ListView.builder(
                        itemCount: machines.length,
                        itemBuilder: (context, index) {
                          final machine = machines[index];
                          final isHighlighted = index < 2 && !machine.isStopped;

                          return MachineItem(
                            machineNumber: machine.number,
                            cycleTime: machine.cycleTime,
                            nextProductionTime: "${machine.nextProductionTime.hour.toString().padLeft(2, '0')}:${machine.nextProductionTime.minute.toString().padLeft(2, '0')}",
                            onSettingsPressed: () {
                              showSettingsDialog(context, machine);
                            },
                            onDeletePressed: () {
                              Provider.of<MachineService>(context, listen: false).deleteMachine(machine);
                            },
                            isHighlighted: isHighlighted,
                            isStopped: machine.isStopped,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.only(bottom: 20),
                padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                decoration: BoxDecoration(
                  color: Color(0xFF1F2833),
                  border: Border.all(
                    color: Color(0xFF45A29E),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: Offset(0, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: Text(
                  getCurrentShift(),
                  style: TextStyle(
                    color: Color(0xFFC5C6C7),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getCurrentShift() {
    final currentTime = DateTime.now();
    final dayShiftStart = TimeOfDay(hour: 7, minute: 30);
    final nightShiftStart = TimeOfDay(hour: 19, minute: 30);

    if ((currentTime.hour > dayShiftStart.hour ||
            (currentTime.hour == dayShiftStart.hour && currentTime.minute >= dayShiftStart.minute)) &&
        (currentTime.hour < nightShiftStart.hour ||
            (currentTime.hour == nightShiftStart.hour && currentTime.minute < nightShiftStart.minute))) {
      return 'Дневная смена';
    } else {
      return 'Ночная смена';
    }
  }
}
class CustomAnimatedButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const CustomAnimatedButton({required this.label, required this.onPressed});

  @override
  _CustomAnimatedButtonState createState() => _CustomAnimatedButtonState();
}

class _CustomAnimatedButtonState extends State<CustomAnimatedButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            _isPressed = true;
          });
        },
        onTapUp: (_) {
          setState(() {
            _isPressed = false;
          });
          widget.onPressed();
        },
        onTapCancel: () {
          setState(() {
            _isPressed = false;
          });
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          transform: Matrix4.translationValues(
            0,
            _isHovered ? -3.0 : (_isPressed ? 2.0 : 0.0),
            0,
          ),
          decoration: BoxDecoration(
            color: _isHovered
                ? Color(0xFF66FCF1)
                : (_isPressed ? Color(0xFF338F89) : Color(0xFF45A29E)),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              if (_isPressed)
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: Offset(0, 5),
                  blurRadius: 15,
                ),
              if (_isHovered)
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: Offset(0, 5),
                  blurRadius: 10,
                ),
            ],
          ),
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              style: TextStyle(
                color: _isHovered ? Color(0xFF0B0C10) : Colors.white,
                fontSize: _isHovered ? 20 : 18,
                fontWeight: FontWeight.w500,
              ),
              child: Text(widget.label),
            ),
          ),
        ),
      ),
    );
  }
}

class MachineItem extends StatelessWidget {
  final String machineNumber;
  final double cycleTime;
  final String nextProductionTime;
  final VoidCallback onSettingsPressed;
  final VoidCallback onDeletePressed;
  final bool isHighlighted;
  final bool isStopped;

  const MachineItem({
    required this.machineNumber,
    required this.cycleTime,
    required this.nextProductionTime,
    required this.onSettingsPressed,
    required this.onDeletePressed,
    required this.isHighlighted,
    required this.isStopped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isStopped
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF3E0000),
                  Color(0xFF1F0000),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1F2833),
                  Color(0xFF0B0C10),
                ],
              ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isStopped
              ? Colors.red
              : (isHighlighted ? Color(0xFF66FCF1) : Colors.transparent),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isStopped
                ? Colors.red.withOpacity(0.6)
                : (isHighlighted
                    ? Color(0xFF66FCF1).withOpacity(0.6)
                    : Colors.black.withOpacity(0.3)),
            blurRadius: 20,
            spreadRadius: 1,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$machineNumber',
                style: TextStyle(
                  fontFamily: 'Segoe UI',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC5C6C7),
                ),
              ),
              SizedBox(width: 5),
              Text(
                '(Цикл: ${cycleTime.toStringAsFixed(1)} мин)',
                style: TextStyle(
                  color: Color(0xFFC5C6C7),
                ),
              ),
              SizedBox(width: 5),
              Text(
                'Следующий выход:',
                style: TextStyle(
                  color: Color(0xFFC5C6C7),
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Container(
  width: double.infinity,  // Задает ширину для всей строки
  child: Text(
    nextProductionTime,
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Color(0xFF66FCF1),
      shadows: [
        Shadow(
          blurRadius: 5.0,
          color: Color(0xFF66FCF1).withOpacity(0.5),
          offset: Offset(0, 0),
        ),
      ],
    ),
    textAlign: TextAlign.center,  // Центрирует текст внутри контейнера
  ),
),

          SizedBox(height: 10),
          if (isStopped)
            Text(
              'Цикл: ${cycleTime.toStringAsFixed(1)} мин\nВыпущено продукции: 0 шт.',
              style: TextStyle(
                color: Color(0xFFC5C6C7),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: onSettingsPressed,
                style: TextButton.styleFrom(
                  backgroundColor: isStopped ? Colors.grey : Color(0xFF45A29E),
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  'Настройка',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 10),
              TextButton(
                onPressed: onDeletePressed,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  'Удалить',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
