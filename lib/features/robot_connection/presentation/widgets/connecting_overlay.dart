import 'package:flutter/material.dart';

class ConnectingOverlay extends StatelessWidget {
  const ConnectingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A0E27).withOpacity(0.95),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF00F5FF),
                    ),
                  ),
                ),
                Icon(
                  Icons.settings_input_antenna_rounded,
                  size: 60,
                  color: Color(0xFF00F5FF),
                ),
              ],
            ),
            SizedBox(height: 30),
            Text(
              "ESTABLISHING CONNECTION...",
              style: TextStyle(
                color: Color(0xFF00F5FF),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Authenticating secure channel",
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
