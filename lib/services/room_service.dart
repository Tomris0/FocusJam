import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class RoomService {
  RoomService._();
  static final RoomService instance = RoomService._();

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseDatabase.instance;

  String get uid {
    final u = _auth.currentUser;
    if (u == null) throw Exception('Not authenticated');
    return u.uid;
  }

  DatabaseReference roomRef(String code) => _db.ref('rooms/$code');

  Stream<DatabaseEvent> watchRoom(String code) => roomRef(code).onValue;

  Future<void> createRoom({
    required String code,
    required int workMinutes,
    required int breakMinutes,
    required int sets,
    required bool includeBreaksInTotal,
  }) async {
    await roomRef(code).set({
      'hostUid': uid,
      'createdAt': ServerValue.timestamp,
      'status': 'lobby',
      'settings': {
        'workMinutes': workMinutes,
        'breakMinutes': breakMinutes,
        'sets': sets,
        'includeBreaksInTotal': includeBreaksInTotal,
      },
      'session': null,
    });
  }

  Future<void> joinRoom(String code) async {
    final snap = await roomRef(code).get();
    if (!snap.exists) throw Exception('Room not found');
  }

  Future<void> updateSettings({
    required String code,
    required int workMinutes,
    required int breakMinutes,
    required int sets,
    required bool includeBreaksInTotal,
  }) async {
    await roomRef(code).child('settings').set({
      'workMinutes': workMinutes,
      'breakMinutes': breakMinutes,
      'sets': sets,
      'includeBreaksInTotal': includeBreaksInTotal,
    });
  }

  Future<void> startSession({required String code}) async {
    final snap = await roomRef(code).get();
    if (!snap.exists) throw Exception('Room not found');

    final data = (snap.value as Map).cast<String, dynamic>();
    if (data['hostUid'] != uid) throw Exception('Only host can start');

    final settings = (data['settings'] as Map).cast<String, dynamic>();
    final int workMinutes = (settings['workMinutes'] ?? 25) as int;
    final int breakMinutes = (settings['breakMinutes'] ?? 5) as int;
    final int sets = (settings['sets'] ?? 4) as int;
    final bool includeBreaksInTotal = (settings['includeBreaksInTotal'] ?? false) as bool;

    int phaseDurationSec;
    if (includeBreaksInTotal) {
      final totalSec = workMinutes * 60;
      final breakSec = breakMinutes * 60;
      final focusSec = totalSec - breakSec;
      phaseDurationSec = focusSec < 0 ? 0 : focusSec;
    } else {
      phaseDurationSec = workMinutes * 60;
    }

    await roomRef(code).update({
      'status': 'running',
      'session': {
        'phase': 'focus',
        'setIndex': 1,
        'setsTotal': sets,
        'startAt': ServerValue.timestamp,
        'phaseDurationSec': phaseDurationSec,
        'isPaused': false,
        'remainingSec': null,
      }
    });
  }
}