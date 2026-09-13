import 'package:flutter/material.dart';

class AppTheme {
  // Premium Fitness Colors
  static const Color _primaryColor = Color(0xFFE53935); // Strong Red

  
  // Dark Mode Colors
  static const Color _darkBackground = Color(0xFF121212);
  static const Color _darkSurface = Color(0xFF1E1E1E);
  static const Color _darkBubbleAI = Color(0xFF2C2C2E);
  static const Color _darkBubbleUser = Color(0xFFE53935);

  // Light Mode Colors
  static const Color _lightBackground = Color(0xFFF5F5F7);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightBubbleAI = Color(0xFFE5E5EA);
  static const Color _lightBubbleUser = Color(0xFFE53935);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: _primaryColor,
      scaffoldBackgroundColor: _darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: _primaryColor,
        secondary: _primaryColor,
        surface: _darkSurface,
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      extensions: [
        const ChatThemeExtension(
          aiBubbleColor: _darkBubbleAI,
          userBubbleColor: _darkBubbleUser,
          aiTextColor: Colors.white,
          userTextColor: Colors.white,
        ),
      ],
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: _primaryColor,
      scaffoldBackgroundColor: _lightBackground,
      colorScheme: const ColorScheme.light(
        primary: _primaryColor,
        secondary: _primaryColor,
        surface: _lightSurface,
        onSurface: Colors.black87,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      extensions: [
        const ChatThemeExtension(
          aiBubbleColor: _lightBubbleAI,
          userBubbleColor: _lightBubbleUser,
          aiTextColor: Colors.black87,
          userTextColor: Colors.white,
        ),
      ],
    );
  }
}

class ChatThemeExtension extends ThemeExtension<ChatThemeExtension> {
  final Color? aiBubbleColor;
  final Color? userBubbleColor;
  final Color? aiTextColor;
  final Color? userTextColor;

  const ChatThemeExtension({
    this.aiBubbleColor,
    this.userBubbleColor,
    this.aiTextColor,
    this.userTextColor,
  });

  @override
  ThemeExtension<ChatThemeExtension> copyWith({
    Color? aiBubbleColor,
    Color? userBubbleColor,
    Color? aiTextColor,
    Color? userTextColor,
  }) {
    return ChatThemeExtension(
      aiBubbleColor: aiBubbleColor ?? this.aiBubbleColor,
      userBubbleColor: userBubbleColor ?? this.userBubbleColor,
      aiTextColor: aiTextColor ?? this.aiTextColor,
      userTextColor: userTextColor ?? this.userTextColor,
    );
  }

  @override
  ThemeExtension<ChatThemeExtension> lerp(
    covariant ThemeExtension<ChatThemeExtension>? other,
    double t,
  ) {
    if (other is! ChatThemeExtension) {
      return this;
    }
    return ChatThemeExtension(
      aiBubbleColor: Color.lerp(aiBubbleColor, other.aiBubbleColor, t),
      userBubbleColor: Color.lerp(userBubbleColor, other.userBubbleColor, t),
      aiTextColor: Color.lerp(aiTextColor, other.aiTextColor, t),
      userTextColor: Color.lerp(userTextColor, other.userTextColor, t),
    );
  }
}
