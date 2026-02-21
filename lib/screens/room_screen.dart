import 'package:flutter/material.dart';

import '../widgets/setting_row.dart';
import 'timer_screen.dart';

class RoomScreen extends StatefulWidget {
  final String roomCode;
  final bool isHost;

  const RoomScreen({
    super.key,
    required this.roomCode,
    required this.isHost,
  });

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  int workMin = 25;
  int breakMin = 5;
  int sets = 4;
  bool includeBreaksInTotal = false;

  @override
  Widget build(BuildContext context) {
    final isHost = widget.isHost;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Room'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Leave'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Room Code',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SelectableText(
              widget.roomCode,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            Text(
              isHost ? 'Host: You 👑' : 'Host: (waiting...)',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text('Members: 1 / 16 (demo)'),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Session Settings',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        Text(
                          isHost ? 'Host can edit' : 'View only',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SettingRow(
                      label: includeBreaksInTotal ? 'Total per set (min)' : 'Work (min)',
                      value: workMin,
                      enabled: isHost,
                      onMinus: () => setState(() => workMin = (workMin > 5) ? workMin - 5 : workMin),
                      onPlus: () => setState(() => workMin += 5),
                    ),
                    const SizedBox(height: 8),
                    SettingRow(
                      label: 'Break (min)',
                      value: breakMin,
                      enabled: isHost,
                      onMinus: () => setState(() => breakMin = (breakMin > 1) ? breakMin - 1 : breakMin),
                      onPlus: () => setState(() => breakMin += 1),
                    ),
                    const SizedBox(height: 8),
                    SettingRow(
                      label: 'Sets',
                      value: sets,
                      enabled: isHost,
                      onMinus: () => setState(() => sets = (sets > 1) ? sets - 1 : sets),
                      onPlus: () => setState(() => sets += 1),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Include breaks in total time?'),
                      subtitle: const Text('If ON, total time includes breaks.'),
                      value: includeBreaksInTotal,
                      onChanged: isHost
                          ? (v) => setState(() {
                        includeBreaksInTotal = v;
                        if (includeBreaksInTotal && breakMin >= workMin) {
                          breakMin = (workMin > 1) ? workMin - 1 : 1;
                        }
                      })
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: isHost
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TimerScreen(
                      workMinutes: workMin,
                      breakMinutes: breakMin,
                      sets: sets,
                      includeBreaksInTotal: includeBreaksInTotal,
                    ),
                  ),
                );
              }
                  : null,
              child: const Text('Start Session (host only)'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}