import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main_navigation.dart';
import 'providers/drone_provider.dart';

void main() {
  runApp(const VarunaAI());
}

class VarunaAI extends StatelessWidget {
  const VarunaAI({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = DroneProvider();
        provider.start();
        return provider;
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "VARUNA AI",
        theme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF061B34),
          colorSchemeSeed: Colors.cyan,
        ),
        home: const MainNavigation(),
      ),
    );
  }
}