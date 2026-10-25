import 'package:flutter/material.dart';

void main() {
  runApp(const PrismaApp());
}

class PrismaApp extends StatelessWidget {
  const PrismaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prisma App Service',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prisma App Service')),
      body: const Center(child: Text('Bienvenido')),
    );
  }
}
