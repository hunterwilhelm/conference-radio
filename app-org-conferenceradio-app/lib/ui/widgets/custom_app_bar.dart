import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double appBarHeight = 49;

  const CustomAppBar({super.key});
  @override
  Size get preferredSize => Size.fromHeight(appBarHeight);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pop();
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFEEEEEE),
          border: Border(
            left: BorderSide(color: Color(0x4C818181)),
            top: BorderSide(color: Color(0x4C818181)),
            right: BorderSide(color: Color(0x4C818181)),
            bottom: BorderSide(width: 1, color: Color(0x4C818181)),
          ),
        ),
        child: const SafeArea(
          child: Padding(
            padding: EdgeInsets.all(11.0),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(FluentIcons.chevron_left_12_regular),
                ),
                Center(
                  child: Text(
                    'Filter',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF818181),
                      fontSize: 25.67,
                      fontFamily: 'REM',
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.05,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
