import 'package:flutter/material.dart';
import '../../disconnect_constants.dart';

class DisconnectDataStrip extends StatelessWidget {
  const DisconnectDataStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          _DataChip(label: "SESSION",    value: "TERMINATED"),
          _DataChip(label: "SOCKET",     value: "CLOSED"),
          _DataChip(label: "ROS BRIDGE", value: "OFFLINE"),
        ],
      ),
    );
  }
}

class _DataChip extends StatelessWidget {
  const _DataChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF883333),
            fontSize: 8,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: DisconnectConstants.red,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}