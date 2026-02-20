import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'dart:async';

void main() {
  runApp(const FocusJamApp());
}

class FocusJamApp extends StatelessWidget {
  const FocusJamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FocusJam',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _openJoinSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;

        return Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Join a room',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Join code',
                  hintText: 'e.g. AB12CD',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  final code = _codeController.text.trim().toUpperCase();
                  if (code.length != 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code must be 6 characters.')),
                    );
                    return;
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(content: Text('Joining room: $code (demo)')),
                  );
                },
                child: const Text('Join'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }

  String _generateJoinCode({int length = 6}) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    // I, O, 0, 1 gibi karışanları çıkardım
    final rand = Random.secure();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  void _createRoom() {
    final code = _generateJoinCode();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Room created'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Share this code with your friends:'),
            const SizedBox(height: 12),
            SelectableText(
              code,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),

          // ✅ Copy: dialog kapanmasın
          FilledButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: code));
              if (!mounted) return;
              ScaffoldMessenger.of(this.context).showSnackBar(
                const SnackBar(content: Text('Code copied to clipboard')),
              );
            },
            child: const Text('Copy'),
          ),

          // ✅ Continue: dialog kapanır, RoomScreen'e geçer
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.push(
                this.context,
                MaterialPageRoute(
                  builder: (_) => RoomScreen(roomCode: code, isHost: true),
                ),
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 👇 burada senin mevcut Scaffold içeriğin duracak (birazdan butona bağlayacağız)
    return Scaffold(
      appBar: AppBar(
        title: const Text('FocusJam'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Study together. Stay in sync.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _createRoom,
                child: const Text('Create Room'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _openJoinSheet,
                child: const Text('Join with Code'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

            // ✅ Session Settings card
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
                        Text(isHost ? 'Host can edit' : 'View only',
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 12),

                    _SettingRow(
                      label: includeBreaksInTotal ? 'Total per set (min)' : 'Work (min)',
                      value: workMin,
                      enabled: isHost,
                      onMinus: () => setState(() => workMin = (workMin > 5) ? workMin - 5 : workMin),
                      onPlus: () => setState(() => workMin += 5),
                    ),
                    const SizedBox(height: 8),
                    _SettingRow(
                      label: 'Break (min)',
                      value: breakMin,
                      enabled: isHost,
                      onMinus: () => setState(() => breakMin = (breakMin > 1) ? breakMin - 1 : breakMin),
                      onPlus: () => setState(() => breakMin += 1),
                    ),
                    const SizedBox(height: 8),
                    _SettingRow(
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
class _SettingRow extends StatelessWidget {
  final String label;
  final int value;
  final bool enabled;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _SettingRow({
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

class TimerScreen extends StatefulWidget {
  final int workMinutes;
  final int breakMinutes;
  final int sets;
  final bool includeBreaksInTotal;

  const TimerScreen({
    super.key,
    required this.workMinutes,
    required this.breakMinutes,
    required this.sets,
    required this.includeBreaksInTotal,
  });

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Timer? _timer;
  late int _setTotalSeconds;
  late int _breakSeconds;
  bool _isRunning = true;
  bool _isFocus = true;

  int _currentSet = 1;
  late int _remainingSeconds;

  @override
  void initState() {
    super.initState();

    _breakSeconds = widget.breakMinutes * 60;

    if (widget.includeBreaksInTotal) {
      _setTotalSeconds = widget.workMinutes * 60; // total per set
      _remainingSeconds = _setTotalSeconds;
    } else {
      _setTotalSeconds = widget.workMinutes * 60; // focus per set
      _remainingSeconds = _setTotalSeconds;
    }

    _startTicker();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isRunning) return;

      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _advancePhase();
        }
      });
    });
  }

  void _advancePhase() {
    if (widget.includeBreaksInTotal) {
      // Total-per-set modu: set bitince bir sonraki sete geç
      if (_currentSet < widget.sets) {
        _currentSet++;
        _remainingSeconds = _setTotalSeconds;
      } else {
        _isRunning = false;
        _timer?.cancel();
        _showFinishedDialog();
      }
      return;
    }

    // Normal mod: Focus -> Break -> next Focus
    if (_isFocus) {
      _isFocus = false;

      final breakSec = widget.breakMinutes * 60;
      _remainingSeconds = breakSec > 0 ? breakSec : 0;

      if (_remainingSeconds == 0) {
        _advancePhase();
      }
      return;
    }

    _isFocus = true;

    if (_currentSet < widget.sets) {
      _currentSet++;
      _remainingSeconds = _setTotalSeconds;
    } else {
      _isRunning = false;
      _timer?.cancel();
      _showFinishedDialog();
    }
  }

  void _showFinishedDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Session completed 🎉'),
        content: const Text('Great job! You finished all sets.'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // TimerScreen'den geri
            },
            child: const Text('Back to Room'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.includeBreaksInTotal
        ? (_remainingSeconds <= _breakSeconds ? 'Break' : 'Focus')
        : (_isFocus ? 'Focus' : 'Break');
    final timeText = _formatTime(_remainingSeconds);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 24),

            // Basit "ring" görünümü (şimdilik statik)
            Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 18),
              ),
              alignment: Alignment.center,
              child: Text(
                timeText,
                style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w800),
              ),
            ),

            const SizedBox(height: 16),
            Text(
              'Set $_currentSet/${widget.sets}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const Spacer(),

            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      setState(() => _isRunning = !_isRunning);
                    },
                    child: Text(_isRunning ? 'Pause' : 'Resume'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _timer?.cancel();
                      Navigator.pop(context);
                    },
                    child: const Text('End'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}