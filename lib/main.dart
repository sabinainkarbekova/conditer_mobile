import 'package:conditer_mobile/features/admin/presentation/screens/admin_screen.dart';
import 'package:flutter/material.dart';
import 'features/cake-constructor/presentation/screens/layer_selection.dart';
import 'features/cart/presentation/screens/cart_screen.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'widgets/custom_bottom_nav.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/box-design/presentation/screens/boxdesign_screen.dart';
import 'features/auth/screens/qrcode_screen.dart';

import '/services/api_service.dart';
import '/models/cake_model.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart'; // Импортируем пакет provider


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crumbl App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: const Color(0xFFF85A9C),
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Poppins'),
        ),
      ),

      initialRoute: '/splash',

      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const MainAppScreen(),
        '/cart': (context) => const CartScreen(),
        '/admin': (context) => const AdminPanelScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/boxdesign': (context) => const BoxDesignScreen(),
        '/qrcode': (context) => const QRCodeScreen(),
        '/layer': (context) {
          return ChangeNotifierProvider(
            create: (context) => CakeModel(),
            child: Builder(
              builder: (context) {
                final cakeModel = Provider.of<CakeModel>(context);
                final apiService = ApiService(client: http.Client());

                return LayerSelectionScreen(
                  cakeModel: cakeModel,
                  apiService: apiService,
                );
              },
            ),
          );
        },
      },
    );
  }
}

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _selectedIndex = 0;
  // Изменяем список _screens, заменив заглушку на реальный экран CartScreen
  final List<Widget> _screens = [
    const HomeScreen(), // Индекс 0
    const Center(child: Text("Likes Screen")), // Индекс 1
    const CartScreen(), // Индекс 2: Заменяем заглушку на реальный экран
    const ProfileScreen(), // Индекс 3
  ];

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTabChange: _onTabChange,
      ),
    );
  }
}