import 'dart:async';
import 'package:flutter/material.dart';

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

  late int _focusSecondsInTotalMode;
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
    _setTotalSeconds = widget.workMinutes * 60; // total per set (toggle ON iken)

    if (widget.includeBreaksInTotal) {
      _focusSecondsInTotalMode = _setTotalSeconds - _breakSeconds;
      if (_focusSecondsInTotalMode < 0) _focusSecondsInTotalMode = 0;

      _isFocus = true;
      _remainingSeconds = _focusSecondsInTotalMode;
    } else {
      _focusSecondsInTotalMode = 0;
      _isFocus = true;
      _remainingSeconds = widget.workMinutes * 60;
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
      // Total mod: Focus -> Break -> next Set Focus
      if (_isFocus) {
        _isFocus = false;

        _remainingSeconds = _breakSeconds;
        if (_remainingSeconds == 0) _advancePhase();
        return;
      }

      // Break bitti -> sonraki set
      _isFocus = true;

      if (_currentSet < widget.sets) {
        _currentSet++;
        _remainingSeconds = _focusSecondsInTotalMode;
        return;
      }

      _isRunning = false;
      _timer?.cancel();
      _showFinishedDialog();
      return;
    }

    // Normal mod: Focus -> Break -> next Focus
    if (_isFocus) {
      _isFocus = false;

      final breakSec = widget.breakMinutes * 60;
      _remainingSeconds = breakSec > 0 ? breakSec : 0;

      if (_remainingSeconds == 0) _advancePhase();
      return;
    }

    _isFocus = true;

    if (_currentSet < widget.sets) {
      _currentSet++;
      _remainingSeconds = widget.workMinutes * 60;
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
              Navigator.pop(context);
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
    final title = _isFocus ? 'Focus' : 'Break';
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
                    onPressed: () => setState(() => _isRunning = !_isRunning),
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