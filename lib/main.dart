import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_page.dart';
import 'services/machine_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) {
        MachineService machineService = MachineService();
        machineService.loadMachines();  // Загружаем данные при старте приложения
        return machineService;
      },
      child: MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Прометей',
      theme: ThemeData(
        primaryColor: Color(0xFF1F2833),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Color(0xFF66FCF1),
          background: Color(0xFF0B0C10),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFC5C6C7)),
          bodyMedium: TextStyle(color: Color(0xFFC5C6C7)),
        ),
      ),
      home: HomePage(),
    );
  }
}
