import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:atelier_manager/widgets/main_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'Usuário';
    return Scaffold(
        drawer: const MainDrawer(),
        appBar: AppBar(

        ),
        body: Center(
          child: Text('Bem-vindo(a), ${displayName}!'),
        ));
  }
}