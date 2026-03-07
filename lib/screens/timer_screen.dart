import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../services/room_service.dart';

class TimerScreen extends StatefulWidget {
  final String roomCode;

  const TimerScreen({
    super.key,
    required this.roomCode,
  });

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  StreamSubscription<DatabaseEvent>? _roomSub;
  Timer? _ticker;

  final ValueNotifier<int> _remainingSec = ValueNotifier<int>(0);

  String _phase = 'focus';
  int _setIndex = 1;
  int _setsTotal = 1;
  int _phaseDurationSec = 0;
  int _startAtMs = 0;
  String _status = 'lobby';

  bool _advanceInFlight = false;
  bool _sessionFinished = false;
  bool _amIHost = false;

  String get _myUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();

    _roomSub = RoomService.instance.watchRoom(widget.roomCode).listen((event) {
      final raw = event.snapshot.value;

      if (raw == null) {
        if (mounted) {
          setState(() {
            _sessionFinished = true;
          });
        }
        return;
      }

      final room = (raw as Map).cast<String, dynamic>();
      final hostUid = room['hostUid'] as String?;
      _amIHost = hostUid != null && hostUid == _myUid;

      _status = (room['status'] ?? 'lobby') as String;
      final sessionRaw = room['session'];

      if (_status == 'ended' || sessionRaw == null) {
        if (mounted) {
          setState(() {
            _sessionFinished = true;
          });
        }
        return;
      }

      final session = (sessionRaw as Map).cast<String, dynamic>();

      if (mounted) {
        setState(() {
          _sessionFinished = false;
          _phase = (session['phase'] ?? 'focus') as String;
          _setIndex = (session['setIndex'] ?? 1) as int;
          _setsTotal = (session['setsTotal'] ?? 1) as int;
          _phaseDurationSec = (session['phaseDurationSec'] ?? 0) as int;
          _startAtMs = (session['startAt'] ?? 0) as int;
        });
      }

      _updateRemaining();
    });

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });
  }

  void _updateRemaining() {
    if (_sessionFinished || _startAtMs == 0) return;

    final elapsedSec =
    ((DateTime.now().millisecondsSinceEpoch - _startAtMs) ~/ 1000);
    final remaining = max(0, _phaseDurationSec - elapsedSec);

    if (_remainingSec.value != remaining) {
      _remainingSec.value = remaining;
    }

    if (remaining <= 0 && _amIHost) {
      _advanceIfNeeded();
    }
  }

  Future<void> _advanceIfNeeded() async {
    if (_advanceInFlight) return;
    _advanceInFlight = true;

    try {
      await RoomService.instance.advanceSession(code: widget.roomCode);
    } catch (_) {
      // sessiz geç
    } finally {
      _advanceInFlight = false;
    }
  }

  String _formatTime(int seconds) {
    final safe = max(0, seconds);
    final m = safe ~/ 60;
    final s = safe % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  void dispose() {
    _roomSub?.cancel();
    _ticker?.cancel();
    _remainingSec.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_sessionFinished) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Session'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Session completed 🎉',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              const Text('Great job!'),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Room'),
              ),
            ],
          ),
        ),
      );
    }

    final title = _phase == 'break' ? 'Break' : 'Focus';

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
              child: ValueListenableBuilder<int>(
                valueListenable: _remainingSec,
                builder: (context, value, _) {
                  return Text(
                    _formatTime(value),
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            Text(
              'Set $_setIndex/$_setsTotal',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const Spacer(),

            if (_amIHost)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    await RoomService.instance.endSession(code: widget.roomCode);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                  child: const Text('End Session'),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back to Room'),
                ),
              ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}