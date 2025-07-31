import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/download_service.dart';
import 'screens/loading_screen.dart'; 
import 'providers/theme_provider.dart';
import 'providers/genre_provider.dart';
import 'providers/auth_provider.dart'; 



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final String? themeModeName = prefs.getString(ThemeProvider.themePrefKey);

  ThemeMode initialThemeMode;
  if (themeModeName == 'light') {
    initialThemeMode = ThemeMode.light;
  } else if (themeModeName == 'dark') {
    initialThemeMode = ThemeMode.dark;
  } else {
    initialThemeMode = ThemeMode.system;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(initialTheme: initialThemeMode),
        ),
        ChangeNotifierProvider(
          create: (_) => GenreProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => DownloadService(),
        ),
         ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'DonghuaHub',
          
          // TEMA CLARO COM PADRÃO AZUL
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.white,
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.blue,
              brightness: Brightness.light,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 0,
            ),
            // 👇 CORREÇÃO AQUI
            tabBarTheme: const TabBarThemeData( 
              indicatorColor: Colors.blue,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.black54,
            ),
            progressIndicatorTheme: const ProgressIndicatorThemeData(
              color: Colors.blue,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
            ),
            cardTheme: CardThemeData(
              color: Colors.white,
              shadowColor: Colors.black.withOpacity(0.1),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            textTheme: const TextTheme(
              headlineLarge: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
              bodyLarge: TextStyle(color: Colors.black87),
              bodyMedium: TextStyle(color: Colors.black54),
            ),
          ),
          
          // TEMA ESCURO COM PADRÃO AZUL
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: const Color(0xFF121212),
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.blue,
              brightness: Brightness.dark,
            ).copyWith(
              surface: const Color(0xFF1E1E1E),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            // 👇 E CORREÇÃO AQUI
            tabBarTheme: const TabBarThemeData(
              indicatorColor: Colors.blue,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.white70,
            ),
            progressIndicatorTheme: const ProgressIndicatorThemeData(
              color: Colors.blue,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
            ),
            cardTheme: CardThemeData(
              color: const Color(0xFF1E1E1E),
              shadowColor: Colors.black.withOpacity(0.3),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            textTheme: const TextTheme(
              headlineLarge: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white70),
            ),
          ),
          
          themeMode: themeProvider.themeMode,
          
          home: const LoadingScreen(),
          
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}