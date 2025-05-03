import 'package:atelier_manager/widgets/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'setting_screen.dart';
import 'products_screen.dart';
import 'prints_screen.dart';
import 'finalization_screen.dart';
import 'sales_screen.dart';
import 'events_screen.dart';
import 'home_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    ProductsScreen(),
    PrintsScreen(),
    FinalizationScreen(),
    SalesScreen(),
    EventsScreen(),
  ];

  static const List<BottomNavigationBarItem> _bottomNavBarItems =
  <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Dashboard',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.shopping_cart),
      label: 'Produtos',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.print),
      label: 'Impressão',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.check_circle),
      label: 'Finalização',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.attach_money),
      label: 'Vendas',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.event),
      label: 'Eventos',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navegar de volta para a tela de login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      // Tratar erros, se houver
      print('Erro ao fazer logout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtendo informações do usuário
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'Usuário';
    final email = user?.email ?? 'Email não disponível';

    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _bottomNavBarItems,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}