import 'package:flutter/material.dart';

class MachineItem extends StatelessWidget {
  final String machineNumber;
  final double cycleTime;
  final String nextProductionTime;
  final VoidCallback onSettingsPressed;
  final VoidCallback onDeletePressed;

  MachineItem({
    required this.machineNumber,
    required this.cycleTime,
    required this.nextProductionTime,
    required this.onSettingsPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF0B0C10),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.cyanAccent,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$machineNumber (Цикл: ${cycleTime.toStringAsFixed(1)} мин) Следующий выход:',
                  style: TextStyle(
                    color: Color(0xFFC5C6C7),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFF0B0C10),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        nextProductionTime,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF66FCF1),
                          shadows: [
                            Shadow(
                              blurRadius: 5.0,
                              color: Color(0xFF66FCF1).withOpacity(0.5),
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              SizedBox(width: 10),
              TextButton(
                onPressed: onSettingsPressed,
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFF45A29E),
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
              SizedBox(width: 10), // Отступ между кнопками
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
