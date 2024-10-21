import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/machine_service.dart';
import '../widgets/machine_item.dart';
import 'time_page.dart';
import 'production_page.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  bool showMessage = false;
  late String messageText;
  late AnimationController _animationController;
  late Animation<double> _bounceAnimation;
  final List<String> messages = [
    "Как дела, Дорогой?",
    "Держись, Дорогой!",
    "Скоро подниму зарплату! Обязательно...",
    "Сможешь выйти завтра? :)",
    "Комаров лепите? Дверь закрой",
    "Дверь закрывайте"
  ];

  @override
  void initState() {
    super.initState();

    // Инициализация messageText значением по умолчанию
    messageText = messages[0];

    // Настройка анимации подпрыгивания
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500), // Общая длительность анимации
    );

    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -30).chain(CurveTween(curve: Curves.easeOut)), // Подпрыгивание вверх
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -30, end: 10).chain(CurveTween(curve: Curves.easeIn)), // Спуск вниз с амортизацией
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 10, end: -10).chain(CurveTween(curve: Curves.easeOut)), // Подпрыгивание вверх снова, но ниже
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -10, end: 0).chain(CurveTween(curve: Curves.easeInOut)), // Возвращение к начальной позиции
        weight: 20,
      ),
    ]).animate(_animationController);

    // Запуск анимации при старте
    _animationController.forward();

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1F2833),
      appBar: AppBar(
        title: Text(
          'Прометей',
          style: TextStyle(
            color: Color(0xFF66FCF1),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF1F2833),
        elevation: 0,
      ),
      body: Consumer<MachineService>(
        builder: (context, machineService, child) {
          return Stack(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                color: Color(0xFF1F2833),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Инструменты',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFFC5C6C7),
                      ),
                    ),
                    SizedBox(height: 40),
                    // Кнопка "Время [1 цех]"
                    CustomAnimatedButton(
                      label: 'Время [1 цех]',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TimePage()),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Кнопка "Готовая продукция"
                    CustomAnimatedButton(
                      label: 'Готовая продукция',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProductionPage()),
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          messageText = messages[Random().nextInt(messages.length)];
                          showMessage = true;
                        });
                        _animationController.forward(from: 0).then((_) {
                          Future.delayed(Duration(seconds: 2), () {
                            setState(() {
                              showMessage = false;
                            });
                          });
                        });
                      },
                      child: Column(
                        children: [
                          AnimatedOpacity(
                            opacity: showMessage ? 1.0 : 0.0,
                            duration: Duration(seconds: 1),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                messageText,
                                style: TextStyle(color: Color(0xFFC5C6C7), fontSize: 16),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(0, _bounceAnimation.value),
                                    child: child,
                                  );
                                },
                                child: SvgPicture.asset(
                                  'assets/icons/mustache.svg', // Используем SVG файл усов
                                  width: 100,
                                  height: 50,
                                  color: Colors.black, // Усы черного цвета
                                ),
                              ),
                              Positioned(
                                bottom: -5,
                                child: AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, child) {
                                    double scale = 1.0 - (_bounceAnimation.value.abs() / 30);
                                    double opacity = (_bounceAnimation.value.abs() / 30).clamp(0.3, 1.0);
                                    return Transform.scale(
                                      scale: scale.clamp(0.7, 1.0),
                                      child: Container(
                                        width: 100 * scale.clamp(0.8, 1.0),
                                        height: 10 * scale.clamp(0.4, 0.6), // Уменьшение высоты для овальной формы
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(opacity),
                                          borderRadius: BorderRadius.circular(50), // Создание овальной формы
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        'By Vakilov',
                        style: TextStyle(
                          color: Color(0xFFC5C6C7),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Кастомный класс кнопки с анимацией при наведении и нажатии
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