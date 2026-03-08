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

  StreamSubscription<DatabaseEvent>? _offsetSub;
  int _serverOffsetMs = 0;

  bool _autoPopped = false;

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
  bool _isPaused = false;

  String get _myUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();

    _offsetSub = FirebaseDatabase.instance
        .ref('.info/serverTimeOffset')
        .onValue
        .listen((event) {
      final value = event.snapshot.value;
      if (value is int) {
        _serverOffsetMs = value;
      } else if (value is double) {
        _serverOffsetMs = value.toInt();
      } else {
        _serverOffsetMs = 0;
      }
    });

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

      final isPaused = (session['isPaused'] ?? false) as bool;

      if (mounted) {
        setState(() {
          _sessionFinished = false;
          _phase = (session['phase'] ?? 'focus') as String;
          _setIndex = (session['setIndex'] ?? 1) as int;
          _setsTotal = (session['setsTotal'] ?? 1) as int;
          _phaseDurationSec = (session['phaseDurationSec'] ?? 0) as int;
          _startAtMs = (session['startAt'] ?? 0) as int;
          _isPaused = isPaused;
        });
      }

      if (isPaused) {
        final pausedRemaining = (session['remainingSec'] ?? 0) as int;
        _remainingSec.value = max(0, pausedRemaining);
      } else {
        _updateRemaining();
      }
    });

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPaused) {
        _updateRemaining();
      }
    });
  }

  void _updateRemaining() {
    if (_sessionFinished || _startAtMs == 0 || _isPaused) return;

    final serverNowMs = DateTime.now().millisecondsSinceEpoch + _serverOffsetMs;
    final elapsedSec = ((serverNowMs - _startAtMs) ~/ 1000);
    final remaining = max(0, _phaseDurationSec - elapsedSec);

    if (_remainingSec.value != remaining) {
      _remainingSec.value = remaining;
    }

    if (remaining <= 0 && _amIHost && !_isPaused) {
      _advanceIfNeeded();
    }
  }

  Future<void> _advanceIfNeeded() async {
    if (_advanceInFlight) return;
    _advanceInFlight = true;

    try {
      await RoomService.instance.advanceSession(code: widget.roomCode);
    } catch (_) {
      //
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
    _offsetSub?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_sessionFinished) {
      if (!_autoPopped) {
        _autoPopped = true;

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await Future.delayed(const Duration(seconds: 2));
          if (!mounted) return;
          Navigator.pop(context);
        });
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text('Session'),
        ),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Session completed 🎉',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 12),
              Text('Returning to room...'),
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
              _isPaused ? '$title (Paused)' : title,
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
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        if (_isPaused) {
                          await RoomService.instance.resumeSession(
                            code: widget.roomCode,
                          );
                        } else {
                          await RoomService.instance.pauseSession(
                            code: widget.roomCode,
                            remainingSec: _remainingSec.value,
                          );
                        }
                      },
                      child: Text(_isPaused ? 'Resume' : 'Pause'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await RoomService.instance.endSession(code: widget.roomCode);
                        if (!context.mounted) return;
                        Navigator.pop(context);
                      },
                      child: const Text('End Session'),
                    ),
                  ),
                ],
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