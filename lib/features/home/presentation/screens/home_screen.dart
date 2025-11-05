import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  int _selectedIndex = 1;
  final List<String> _tabs = ['NEW', 'Trending', 'TOP'];

  final List<String> _dessertImages = [
    'assets/images/dessert1.png',
    'assets/images/dessert2.jpg',
    'assets/images/dessert3.jpg',
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            children: [
              Image.asset(
                'assets/images/logo2.png',
                height: 100,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 40),

              // Карточка с QR-кодом и дисконтом
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF967A0),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Your discount',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '%',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Image(
                      image: AssetImage('assets/images/qr1.jpg'),
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 22),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Табы
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_tabs.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      child: Column(
                        children: [
                          Text(
                            _tabs[index],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: _selectedIndex == index ? FontWeight.bold : FontWeight.normal,
                              color: _selectedIndex == index ? Colors.black : Colors.grey[600],
                            ),
                          ),
                          if (_selectedIndex == index)
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              width: 50,
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF967A0),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),

              SizedBox(
                height: 450,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return SlideTransition(
                      position: animation.drive(
                        Tween(begin: const Offset(0, 0.05), end: Offset.zero),
                      ),
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    key: ValueKey(_selectedIndex),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        _dessertImages[_selectedIndex % _dessertImages.length],
                        fit: BoxFit.cover,
                        height: 450,
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}