import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/aivo_theme.dart';
import 'screens/main_container.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set transparent dark status bar for seamless edge-to-edge glowing aesthetic
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AivoColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const AivoApp());
}

class AivoApp extends StatelessWidget {
  const AivoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aivo',
      debugShowCheckedModeBanner: false,
      theme: AivoTheme.darkTheme,
      home: const MainContainer(),
    );
  }
}
