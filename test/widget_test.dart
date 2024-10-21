import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/machine_service.dart';
import '../widgets/machine_item.dart';
import 'time_page.dart';
import 'production_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Прометей', style: TextStyle(color: Color(0xFF66FCF1))),
        backgroundColor: Color(0xFF1F2833),
      ),
      body: Consumer<MachineService>(
        builder: (context, machineService, child) {
          return Container(
            padding: EdgeInsets.all(20),
            color: Color(0xFF0B0C10),
            child: Column(
              children: [
                Text('Инструменты', style: TextStyle(fontSize: 18, color: Color(0xFFC5C6C7))),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TimePage()),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF45A29E),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                  child: Text('Время [1 цех]'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProductionPage()),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF45A29E),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                  child: Text('Готовая продукция'),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: machineService.machines.length,
                    itemBuilder: (context, index) {
                      final machine = machineService.machines[index];
                      return MachineItem(
                        machineNumber: machine.number,
                        cycleTime: machine.cycleTime,
                        onSettingsPressed: () {
                          // Логика открытия настроек для конкретной машины
                        },
                        onDeletePressed: () {
                          machineService.removeMachine(machine.number);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
