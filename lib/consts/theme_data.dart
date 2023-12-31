import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../providers/theme_provider.dart';
import '../services/assets_manager.dart';
import '/consts/app_colors.dart';

class Styles {
  static ThemeData themeData({
    required bool isDarkTheme,
    required BuildContext context,
  }) {
    return ThemeData(
      useMaterial3: true,
      primaryColorLight: const Color.fromARGB(255, 94, 75, 236),
      indicatorColor: Colors.red,
      primaryColorDark: const Color(0xFFF7F1FB),
      scaffoldBackgroundColor: isDarkTheme
          ? AppColors.darkScaffoldColor
          : AppColors.lightScaffoldColor,
      cardColor: isDarkTheme
          ? const Color.fromARGB(255, 13, 6, 37)
          : AppColors.lightCardColor,
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      iconTheme: isDarkTheme
          ? const IconThemeData(color: Colors.white)
          : const IconThemeData(color: Colors.black),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: isDarkTheme ? Colors.white : Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.all(10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}

SystemUiOverlayStyle statusBarTheme(ThemeProvider themeProvider) {
  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness:
        themeProvider.getIsDarkTheme ? Brightness.light : Brightness.dark,
  );
}

Padding appBarImage() {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Image.asset(
      AssetsManager.shoppingCart,
    ),
  );
}
