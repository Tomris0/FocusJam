import 'package:flutter/material.dart';

class SettingRow extends StatelessWidget {
  final String label;
  final int value;
  final bool enabled;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const SettingRow({
    super.key,
    required this.label,
    required this.value,
    required this.enabled,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        IconButton(
          onPressed: enabled ? onMinus : null,
          icon: const Icon(Icons.remove),
        ),
        SizedBox(
          width: 44,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        IconButton(
          onPressed: enabled ? onPlus : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}