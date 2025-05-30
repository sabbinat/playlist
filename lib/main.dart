import 'package:flutter/material.dart';
import 'package:playlist/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'services/background_service.dart';
import 'viewmodels/song_viewmodel.dart';
import 'views/home_page.dart';
import 'package:permission_handler/permission_handler.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupNotificationChannel();
  await initializeService();


  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SongViewmodel()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: const HomePage(),
    );
  }
}
