import 'package:flutter/material.dart';

class CustomThemes {
  ThemeData get lightTheme {
    return ThemeData(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      primaryColor: Colors.deepOrangeAccent,
      accentColor: Colors.white,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.white,
          foregroundColor: Colors.deepOrangeAccent),
      scaffoldBackgroundColor: Color.fromRGBO(242, 242, 247, 1),
      canvasColor: Colors.white,
      textTheme: TextTheme(
        bodyText1: TextStyle(color: Colors.black, fontSize: 16),
        bodyText2: TextStyle(color: Colors.black, fontSize: 14),
        headline1: TextStyle(color: Colors.black),
        headline2: TextStyle(color: Colors.black),
        headline3: TextStyle(color: Colors.black),
        headline4: TextStyle(color: Colors.black),
        headline5: TextStyle(color: Colors.black),
        headline6: TextStyle(color: Colors.black),
        subtitle1: TextStyle(color: Colors.black),
        subtitle2: TextStyle(color: Colors.black),
        caption: TextStyle(color: Colors.black),
        button: TextStyle(color: Colors.black),
        overline: TextStyle(color: Colors.black),
      ),
      appBarTheme: AppBarTheme(
          elevation: 0,
          textTheme: TextTheme(
            headline6: TextStyle(color: Colors.black, fontSize: 20),
          ),
          foregroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.transparent),
      hoverColor: Colors.grey[600].withOpacity(0.5),
      iconTheme: IconThemeData(color: Colors.black),
      textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.black,
          selectionColor: Colors.grey,
          selectionHandleColor: Colors.grey),
      colorScheme: ColorScheme.light(),
      shadowColor: Colors.grey[400].withOpacity(0.5),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      primaryColor: Colors.deepOrangeAccent,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.deepOrangeAccent),
      scaffoldBackgroundColor: Colors.black,
      accentColor: Colors.black,
      canvasColor: Colors.grey[900],
      textTheme: TextTheme(
        bodyText1: TextStyle(color: Colors.white, fontSize: 16),
        bodyText2: TextStyle(color: Colors.white, fontSize: 14),
        headline1: TextStyle(color: Colors.white),
        headline2: TextStyle(color: Colors.white),
        headline3: TextStyle(color: Colors.white),
        headline4: TextStyle(color: Colors.white),
        headline5: TextStyle(color: Colors.white),
        headline6: TextStyle(color: Colors.white),
        subtitle1: TextStyle(color: Colors.white),
        subtitle2: TextStyle(color: Colors.white),
        caption: TextStyle(color: Colors.white),
        button: TextStyle(color: Colors.white),
        overline: TextStyle(color: Colors.white),
      ),
      appBarTheme: AppBarTheme(
          elevation: 0,
          textTheme: TextTheme(
            headline6: TextStyle(color: Colors.white, fontSize: 20),
          ),
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.transparent),
      hoverColor: Colors.grey[600].withOpacity(0.5),
      iconTheme: IconThemeData(color: Colors.white),
      textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.white,
          selectionColor: Colors.grey,
          selectionHandleColor: Colors.grey),
      colorScheme: ColorScheme.dark(),
      shadowColor: Colors.grey[900].withOpacity(0.5),
    );
  }
}
