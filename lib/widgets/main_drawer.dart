import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('Produtos'),
            onTap: () {
              // Navigate to Products
              Navigator.pop(context); // Close drawer
              Navigator.pushReplacementNamed(context, '/products'); // Replace current route
            },
          ),
          ListTile(
            leading: const Icon(Icons.print),
            title: const Text('Impressões'),
            onTap: () {
              // Navigate to Prints
              Navigator.pop(context); // Close drawer
              Navigator.pushReplacementNamed(context, '/prints'); // Replace current route
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Adicionar Impressão'),
            onTap: () {
              // Navigate to Add Print
              Navigator.pop(context); // Close drawer
              Navigator.pushReplacementNamed(context, '/add-print'); // Replace current route
            },
          ),
          // Add more ListTiles for other menu items
        ],
      ),
    );
  }
}