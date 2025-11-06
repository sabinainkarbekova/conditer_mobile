import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Импорт сервисов и моделей
import '/services/api_service.dart';
import '/models/cake_model.dart';
import '/models/payment_card.dart';

// Импорт экранов
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/qrcode_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/admin/presentation/screens/admin_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/profile/presentation/screens/payment_screen.dart';
import 'features/profile/presentation/screens/card_payment_screen.dart';
import 'features/cart/presentation/screens/cart_screen.dart';
import 'features/box-design/presentation/screens/boxdesign_screen.dart';
import 'features/cake-constructor/presentation/screens/layer_selection.dart'; // Убедитесь, что этот импорт правильный
import 'screens/catalog_screen.dart';
import 'widgets/custom_bottom_nav.dart';
import 'bloc/catalog_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Создаем ApiService один раз, чтобы использовать его в разных местах
    final http.Client httpClient = http.Client();
    final ApiService apiService = ApiService(client: httpClient);

    return MultiProvider(
      providers: [
        // Создаем CakeModel один раз для всего приложения
        ChangeNotifierProvider(create: (_) => CakeModel()),
        // Создаем CatalogBloc, передав ему ApiService
        BlocProvider(
          create: (context) => CatalogBloc(apiService: apiService)..add(LoadProducts()),
        ),
      ],
      child: MaterialApp(
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

        // Устанавливаем начальный маршрут
        initialRoute: '/splash',

        // Определяем все маршруты приложения
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/main': (context) => const MainAppScreen(),
          '/cart': (context) => const CartScreen(),
          '/admin': (context) => const AdminPanelScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/payment': (context) => const PaymentScreen(),
          '/catalog': (context) => const CatalogScreen(),
          '/boxdesign': (context) => const BoxDesignScreen(),
          '/qrcode': (context) => const QRCodeScreen(),

          // Маршрут для экрана оплаты с конкретной картой
          '/card_payment': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as PaymentCard?;
            if (args == null) {
              // Обработка ошибки, если аргументы не переданы
              return const Scaffold(
                body: Center(child: Text('Error: Card data not provided')),
              );
            }
            return CardPaymentScreen(card: args);
          },

          // Маршрут для экрана конструктора торта
          '/layer': (context) {
            // Получаем CakeModel из провайдера, установленного выше в дереве
            final cakeModel = context.read<CakeModel>();
            // Используем общий экземпляр ApiService
            // final apiService = context.read<ApiService>(); // Это не сработает, т.к. ApiService не в провайдерах
            // Лучше создать новый экземпляр для этого экрана или передать общий
            // Если ApiService нужен в других местах как провайдер, его можно добавить в MultiProvider
            // Но для простоты, создаем новый для этого экрана
            final apiServiceForScreen = ApiService(client: http.Client());

            return LayerSelectionScreen(
              cakeModel: cakeModel,
              apiService: apiServiceForScreen, // Передаем модель и сервис
            );
          },
        },
      ),
    );
  }
}

// Основной экран с нижней навигацией
class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _selectedIndex = 0;

  // Список экранов для нижней навигации
  final List<Widget> _screens = [
    const HomeScreen(),         // Индекс 0
    const CatalogScreen(),      // Индекс 1
    const CartScreen(),         // Индекс 2
    const ProfileScreen(),      // Индекс 3
  ];

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack отображает только один виджет из списка по индексу
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