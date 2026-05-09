import 'package:flutter/material.dart';

class ConnectButton extends StatelessWidget {
  final bool isConnecting;
  final VoidCallback onTap;

  const ConnectButton({
    super.key,
    required this.isConnecting,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isConnecting ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isConnecting
                ? [const Color(0xFF555555), const Color(0xFF777777)]
                : [
                    const Color(0xFF00F5FF),
                    const Color(0xFF00D9FF),
                    const Color(0xFF00BFFF),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isConnecting
                  ? Colors.transparent
                  : const Color(0xFF00F5FF).withOpacity(0.5),
              blurRadius: 30,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isConnecting)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            else
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.power_settings_new_rounded,
                    color: Color(0xFF0A0E27),
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Text(
                    "INITIATE CONNECTION",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: Color(0xFF0A0E27),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
