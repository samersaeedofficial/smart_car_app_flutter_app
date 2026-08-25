import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'models/car_mode.dart';
import 'providers/car_controller_provider.dart';
import 'screens/connect_screen.dart';
import 'screens/manual_control_screen.dart';
import 'screens/mode_selection_screen.dart';
import 'screens/move_freely_screen.dart';
import 'screens/move_line_screen.dart';
import 'theme/cyber_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set immersive dark system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: CyberTheme.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => CarControllerProvider(),
      child: const SmartCarApp(),
    ),
  );
}

class SmartCarApp extends StatelessWidget {
  const SmartCarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Car Control (JDY-31)',
      debugShowCheckedModeBanner: false,
      theme: CyberTheme.darkTheme,
      home: const RootNavigator(),
    );
  }
}

class RootNavigator extends StatelessWidget {
  const RootNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CarControllerProvider>();

    // Step 1: If not connected to Bluetooth, show standalone modern ConnectScreen
    if (!provider.isConnected) {
      return const ConnectScreen();
    }

    // Step 2: When connected, route based on current active CarMode
    switch (provider.currentMode) {
      case CarMode.moveFreely:
        return MoveFreelyScreen(
          onBackToMenu: () => provider.setMode(CarMode.menu),
        );
      case CarMode.control:
        return ManualControlScreen(
          onBackToMenu: () => provider.setMode(CarMode.menu),
        );
      case CarMode.moveLine:
        return MoveLineScreen(
          onBackToMenu: () => provider.setMode(CarMode.menu),
        );
      case CarMode.menu:
      default:
        return ModeSelectionScreen(
          onModeSelected: (mode) => provider.setMode(mode),
        );
    }
  }
}
