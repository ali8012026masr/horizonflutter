import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/storage/cart_manager.dart';
import 'core/storage/session_manager.dart';
import 'theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize persistent singletons
  await SessionManager.instance.init();
  await CartManager.instance.init();
  await ThemeController.instance.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SessionManager>.value(value: SessionManager.instance),
        ChangeNotifierProvider<CartManager>.value(value: CartManager.instance),
        ChangeNotifierProvider<ThemeController>.value(value: ThemeController.instance),
      ],
      child: const HorizonTravelApp(),
    ),
  );
}
