import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:madrasati/General/app_localizations.dart';
import 'package:madrasati/General/language_provider.dart'; 
import 'package:madrasati/General/splash_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Madrasati',
          
          theme: ThemeData(
            useMaterial3: false, 
            primaryColor: const Color(0xFF0D47A1),            
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0D47A1), 
              foregroundColor: Colors.white,   
              centerTitle: true,
              elevation: 4,                      
              iconTheme: IconThemeData(color: Colors.white),
            ),

            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          
          locale: languageProvider.appLocale, 
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const SplashScreen(),
        );
      },
    );
  }
}