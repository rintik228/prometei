import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/machine_service.dart';
import '../models/machine.dart';

class ProductionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1F2833),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 80),
            Text(
              'Готовая продукция',
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
            Consumer<MachineService>(
              builder: (context, machineService, child) {
                final machines = machineService.machines;

                return Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Table(
                      border: TableBorder.all(color: Color(0xFF45A29E), width: 1),
                      columnWidths: {
                        0: FlexColumnWidth(1),  // Номер машины
                        1: FlexColumnWidth(2),  // Продукция
                        2: FlexColumnWidth(1),  // Количество циклов
                        3: FlexColumnWidth(2),  // Заглушенные крышки
                      },
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            color: Color(0xFF45A29E),
                          ),
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                '№',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Продукция',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Кол-во циклов',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Заглушенные крышки',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        for (var machine in machines)
                          TableRow(
                            decoration: BoxDecoration(
                              color: machine.isStopped
                                  ? Color(0xFF3E0000) // Стиль для остановленных машин
                                  : Colors.black,
                            ),
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  machine.number,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: machine.isStopped ? Colors.red : Colors.white, // Красный для остановленных
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: EditableTextField(
                                  initialValue: machine.product,
                                  onChanged: (value) {
                                    machineService.updateMachineProduct(machine, value);
                                  },
                                  isStopped: machine.isStopped,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  machine.calculateProducedItems().toString(), // Подсчет с учетом остановки
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: machine.isStopped ? Colors.red : Colors.white,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: EditableTextField(
                                  initialValue: machine.caps == 0 ? '' : machine.caps.toString(),
                                  onChanged: (value) {
                                    machineService.updateMachineCaps(machine, int.tryParse(value) ?? 0); // сохраняем изменения
                                  },
                                  isStopped: machine.isStopped,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class EditableTextField extends StatelessWidget {
  final String initialValue;
  final Function(String) onChanged;
  final bool isStopped;

  EditableTextField({
    required this.initialValue,
    required this.onChanged,
    required this.isStopped,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController.fromValue(
        TextEditingValue(
          text: initialValue,
          selection: TextSelection.collapsed(offset: initialValue.length),
        ),
      ),
      onChanged: onChanged,
      style: TextStyle(
        color: isStopped ? Colors.grey : Colors.white,
      ),
      decoration: InputDecoration(
        border: InputBorder.none,
        filled: true,
        fillColor: Color(0xFF0B0C10),
      ),
      textAlign: TextAlign.center,
      maxLines: null,
    );
  }
}

// Виджет для анимированной кнопки "Назад"
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
