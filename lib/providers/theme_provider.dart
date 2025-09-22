import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';
  static const String _primaryColorKey = 'app_primary_color';
  static const String _fontSizeKey = 'app_font_size';
  
  ThemeMode _themeMode = ThemeMode.system;
  Color _primaryColor = const Color(0xFF2E7D32);
  double _fontSize = 1.0; // Scale factor for font sizes
  bool _isLoading = false;

  // Getters
  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;
  double get fontSize => _fontSize;
  bool get isLoading => _isLoading;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  bool get isLightMode {
    if (_themeMode == ThemeMode.system) {
      return SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.light;
    }
    return _themeMode == ThemeMode.light;
  }

  bool get isSystemMode => _themeMode == ThemeMode.system;

  // Constructor
  ThemeProvider() {
    _loadThemeSettings();
  }

  // Theme mode methods
  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;
    
    _themeMode = themeMode;
    notifyListeners();
    
    await _saveThemeMode();
  }

  Future<void> toggleTheme() async {
    switch (_themeMode) {
      case ThemeMode.light:
        await setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        await setThemeMode(ThemeMode.system);
        break;
      case ThemeMode.system:
        await setThemeMode(ThemeMode.light);
        break;
    }
  }

  // Primary color methods
  Future<void> setPrimaryColor(Color color) async {
    if (_primaryColor == color) return;
    
    _primaryColor = color;
    notifyListeners();
    
    await _savePrimaryColor();
  }

  // Font size methods
  Future<void> setFontSize(double scale) async {
    if (_fontSize == scale) return;
    
    _fontSize = scale.clamp(0.8, 1.5); // Limit font size scale
    notifyListeners();
    
    await _saveFontSize();
  }

  Future<void> increaseFontSize() async {
    await setFontSize(_fontSize + 0.1);
  }

  Future<void> decreaseFontSize() async {
    await setFontSize(_fontSize - 0.1);
  }

  Future<void> resetFontSize() async {
    await setFontSize(1.0);
  }

  // Predefined color themes
  List<Color> get availableColors => [
    const Color(0xFF2E7D32), // Default Green
    const Color(0xFF1976D2), // Blue
    const Color(0xFF7B1FA2), // Purple
    const Color(0xFFD32F2F), // Red
    const Color(0xFFF57C00), // Orange
    const Color(0xFF388E3C), // Light Green
    const Color(0xFF0288D1), // Light Blue
    const Color(0xFF5E35B1), // Deep Purple
    const Color(0xFFE64A19), // Deep Orange
    const Color(0xFF00695C), // Teal
    const Color(0xFF455A64), // Blue Grey
    const Color(0xFF6A1B9A), // Purple
  ];

  Map<String, Color> get namedColors => {
    'Green': const Color(0xFF2E7D32),
    'Blue': const Color(0xFF1976D2),
    'Purple': const Color(0xFF7B1FA2),
    'Red': const Color(0xFFD32F2F),
    'Orange': const Color(0xFFF57C00),
    'Teal': const Color(0xFF00695C),
    'Indigo': const Color(0xFF303F9F),
    'Pink': const Color(0xFFC2185B),
    'Brown': const Color(0xFF5D4037),
    'Grey': const Color(0xFF455A64),
  };

  String get currentColorName {
    for (final entry in namedColors.entries) {
      if (entry.value.value == _primaryColor.value) {
        return entry.key;
      }
    }
    return 'Custom';
  }

  // Theme mode display names
  String get themeModeDisplayName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  // Font size display names
  String get fontSizeDisplayName {
    if (_fontSize <= 0.85) return 'Small';
    if (_fontSize <= 1.15) return 'Normal';
    return 'Large';
  }

  // Private methods
  Future<void> _loadThemeSettings() async {
    _setLoading(true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load theme mode
      final themeModeString = prefs.getString(_themeKey);
      if (themeModeString != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (e) => e.toString() == themeModeString,
          orElse: () => ThemeMode.system,
        );
      }
      
      // Load primary color
      final colorValue = prefs.getInt(_primaryColorKey);
      if (colorValue != null) {
        _primaryColor = Color(colorValue);
      }
      
      // Load font size
      final fontSizeValue = prefs.getDouble(_fontSizeKey);
      if (fontSizeValue != null) {
        _fontSize = fontSizeValue.clamp(0.8, 1.5);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _saveThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, _themeMode.toString());
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }

  Future<void> _savePrimaryColor() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_primaryColorKey, _primaryColor.value);
    } catch (e) {
      debugPrint('Error saving primary color: $e');
    }
  }

  Future<void> _saveFontSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_fontSizeKey, _fontSize);
    } catch (e) {
      debugPrint('Error saving font size: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Utility methods
  Future<void> resetToDefaults() async {
    _themeMode = ThemeMode.system;
    _primaryColor = const Color(0xFF2E7D32);
    _fontSize = 1.0;
    
    notifyListeners();
    
    // Save all defaults
    await Future.wait([
      _saveThemeMode(),
      _savePrimaryColor(),
      _saveFontSize(),
    ]);
  }

  // Export/Import settings
  Map<String, dynamic> exportSettings() {
    return {
      'themeMode': _themeMode.toString(),
      'primaryColor': _primaryColor.value,
      'fontSize': _fontSize,
    };
  }

  Future<void> importSettings(Map<String, dynamic> settings) async {
    try {
      // Import theme mode
      final themeModeString = settings['themeMode'] as String?;
      if (themeModeString != null) {
        final themeMode = ThemeMode.values.firstWhere(
          (e) => e.toString() == themeModeString,
          orElse: () => ThemeMode.system,
        );
        _themeMode = themeMode;
      }

      // Import primary color
      final colorValue = settings['primaryColor'] as int?;
      if (colorValue != null) {
        _primaryColor = Color(colorValue);
      }

      // Import font size
      final fontSizeValue = settings['fontSize'] as double?;
      if (fontSizeValue != null) {
        _fontSize = fontSizeValue.clamp(0.8, 1.5);
      }

      notifyListeners();

      // Save imported settings
      await Future.wait([
        _saveThemeMode(),
        _savePrimaryColor(),
        _saveFontSize(),
      ]);
    } catch (e) {
      debugPrint('Error importing theme settings: $e');
      rethrow;
    }
  }

  // Helper methods for UI
  bool isPrimaryColor(Color color) {
    return color.value == _primaryColor.value;
  }

  Color getColorShade(Color color, double shade) {
    // Shade: 0.0 = original color, 1.0 = black
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((1.0 - shade) * hsl.lightness).toColor();
  }

  Color getColorTint(Color color, double tint) {
    // Tint: 0.0 = original color, 1.0 = white
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness(tint + (1.0 - tint) * hsl.lightness).toColor();
  }

  // Get theme-appropriate colors
  Color getTextColor(BuildContext context) {
    return isDarkMode ? Colors.white : Colors.black;
  }

  Color getSubtitleColor(BuildContext context) {
    return isDarkMode ? Colors.white70 : Colors.black54;
  }

  Color getCardColor(BuildContext context) {
    return isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  }

  Color getBackgroundColor(BuildContext context) {
    return isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F5F5);
  }

  // Animation duration based on system preferences
  Duration get animationDuration {
    return const Duration(milliseconds: 300);
  }

  // System theme change listener
  void handleSystemThemeChange() {
    if (_themeMode == ThemeMode.system) {
      notifyListeners();
    }
  }
}