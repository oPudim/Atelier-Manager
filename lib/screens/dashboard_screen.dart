import 'package:flutter/material.dart';
import 'products_screen.dart';
import 'print_screen.dart';
import 'finish_screen.dart';
import 'out_flow_screen.dart';
import 'events_screen.dart';
import 'home_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 4;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    ProductsScreen(),
    PrintsScreen(),
    FinalizationScreen(),
    OutFlowScreen(),
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
      icon: Icon(Icons.receipt_long),
      label: 'Saidas',
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

  @override
  Widget build(BuildContext context) {

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
      //floatingActionButton: FloatingActionButton( //Comente aqui para testar
      //  onPressed: () {}, //Comente aqui para testar
      //  child: const Icon(Icons.add), //Comente aqui para testar
      //), //Comente aqui para testar
    );
  }
}