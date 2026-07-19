import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main_navigation.dart';
import 'providers/drone_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
          brightness: Brightness.light,
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF5F7FB),
          colorSchemeSeed: Colors.blue,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black87),
            titleTextStyle: const TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        home: const MainNavigation(),
      ),
    );
  }
}
