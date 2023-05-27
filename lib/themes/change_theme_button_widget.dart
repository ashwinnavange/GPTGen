import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:gptgen/themes/theme_provider.dart';

bool changed= true;

class ChangeThemeButtonWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      padding: EdgeInsets.only(right: 10),
        child: FlutterSwitch(
          width: 50.0,
          height: 30.0,
          toggleSize: 30.0,
          borderRadius: 30.0,
          padding: 2.0,
          activeToggleColor: Color(0xFF6E40C9),
          inactiveToggleColor: Color(0xFF2F363D),
          activeColor: Color(0xFF271052),
          inactiveColor: Colors.white,
          activeIcon: const Icon(
            Icons.nightlight_round,
            color: Color(0xFFF8E3A1),
          ),
          inactiveIcon: const Icon(
            Icons.wb_sunny,
            color: Color(0xFFFFDF5D),
          ),
          value: themeProvider.isDarkMode,
          onToggle: (value) {
            final provider = Provider.of<ThemeProvider>(context, listen: false);
            provider.toggleTheme(value);
            changed=value;
          },
        ),
    );
  }
}