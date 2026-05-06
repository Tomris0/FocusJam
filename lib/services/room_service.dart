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
    final bool includeBreaksInTotal = (settings['includeBreaksInTotal'] ??
        false) as bool;

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

  Future<void> addSelfAsMember(String code) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    await roomRef(code).child('members/${user.uid}').set({
      'displayName': user.displayName ?? user.email ?? 'User',
      'photoUrl': user.photoURL,
      'joinedAt': ServerValue.timestamp,
      'lastSeenAt': ServerValue.timestamp,
    });
  }

  Future<void> removeSelfFromMember(String code) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final membersRef = roomRef(code).child('members');

    await membersRef.child(user.uid).remove();

    final membersSnap = await membersRef.get();

    if (!membersSnap.exists || membersSnap.children.isEmpty) {
      await roomRef(code).remove();
    }
  }

  Future<void> advanceSession({required String code}) async {
    final snap = await roomRef(code).get();
    if (!snap.exists) throw Exception('Room not found');

    final data = (snap.value as Map).cast<String, dynamic>();
    if (data['hostUid'] != uid) throw Exception('Only host can advance');

    final settings = (data['settings'] as Map).cast<String, dynamic>();
    final sessionRaw = data['session'];

    if (sessionRaw == null) return;

    final session = (sessionRaw as Map).cast<String, dynamic>();

    final int workMinutes = (settings['workMinutes'] ?? 25) as int;
    final int breakMinutes = (settings['breakMinutes'] ?? 5) as int;
    final int sets = (settings['sets'] ?? 4) as int;
    final bool includeBreaksInTotal =
    (settings['includeBreaksInTotal'] ?? false) as bool;

    final String phase = (session['phase'] ?? 'focus') as String;
    final int setIndex = (session['setIndex'] ?? 1) as int;

    int focusSecNormal = workMinutes * 60;
    int breakSec = breakMinutes * 60;
    int focusSecTotalMode = (workMinutes * 60) - breakSec;
    if (focusSecTotalMode < 0) focusSecTotalMode = 0;

    if (includeBreaksInTotal) {
      if (phase == 'focus') {
        if (breakSec <= 0) {
          if (setIndex < sets) {
            await roomRef(code).update({
              'status': 'running',
              'session': {
                'phase': 'focus',
                'setIndex': setIndex + 1,
                'setsTotal': sets,
                'startAt': ServerValue.timestamp,
                'phaseDurationSec': focusSecTotalMode,
                'isPaused': false,
                'remainingSec': null,
              }
            });
          } else {
            await endSession(code: code);
          }
          return;
        }

        await roomRef(code).update({
          'status': 'running',
          'session': {
            'phase': 'break',
            'setIndex': setIndex,
            'setsTotal': sets,
            'startAt': ServerValue.timestamp,
            'phaseDurationSec': breakSec,
            'isPaused': false,
            'remainingSec': null,
          }
        });
        return;
      }

      // break -> next focus or end
      if (setIndex < sets) {
        await roomRef(code).update({
          'status': 'running',
          'session': {
            'phase': 'focus',
            'setIndex': setIndex + 1,
            'setsTotal': sets,
            'startAt': ServerValue.timestamp,
            'phaseDurationSec': focusSecTotalMode,
            'isPaused': false,
            'remainingSec': null,
          }
        });
      } else {
        await endSession(code: code);
      }
      return;
    }

    // Normal mode: focus -> break -> next focus
    if (phase == 'focus') {
      if (breakSec <= 0) {
        if (setIndex < sets) {
          await roomRef(code).update({
            'status': 'running',
            'session': {
              'phase': 'focus',
              'setIndex': setIndex + 1,
              'setsTotal': sets,
              'startAt': ServerValue.timestamp,
              'phaseDurationSec': focusSecNormal,
              'isPaused': false,
              'remainingSec': null,
            }
          });
        } else {
          await endSession(code: code);
        }
        return;
      }

      await roomRef(code).update({
        'status': 'running',
        'session': {
          'phase': 'break',
          'setIndex': setIndex,
          'setsTotal': sets,
          'startAt': ServerValue.timestamp,
          'phaseDurationSec': breakSec,
          'isPaused': false,
          'remainingSec': null,
        }
      });
      return;
    }

    // break -> next focus or end
    if (setIndex < sets) {
      await roomRef(code).update({
        'status': 'running',
        'session': {
          'phase': 'focus',
          'setIndex': setIndex + 1,
          'setsTotal': sets,
          'startAt': ServerValue.timestamp,
          'phaseDurationSec': focusSecNormal,
          'isPaused': false,
          'remainingSec': null,
        }
      });
    } else {
      await endSession(code: code);
    }
  }

  Future<void> endSession({required String code}) async {
    final snap = await roomRef(code).get();
    if (!snap.exists) throw Exception('Room not found');

    final data = (snap.value as Map).cast<String, dynamic>();
    if (data['hostUid'] != uid) throw Exception('Only host can end');

    await roomRef(code).update({
      'status': 'ended',
      'session': null,
    });
  }

  Future<void> pauseSession({
    required String code,
    required int remainingSec,
  }) async {
    final snap = await roomRef(code).get();
    if (!snap.exists) throw Exception('Room not found');

    final data = (snap.value as Map).cast<String, dynamic>();
    if (data['hostUid'] != uid) throw Exception('Only host can pause');

    final sessionRaw = data['session'];
    if (sessionRaw == null) throw Exception('No active session');

    final session = (sessionRaw as Map).cast<String, dynamic>();

    await roomRef(code).update({
      'status': 'paused',
      'session': {
        ...session,
        'isPaused': true,
        'remainingSec': remainingSec,
      }
    });
  }

  Future<void> resumeSession({required String code}) async {
    final snap = await roomRef(code).get();
    if (!snap.exists) throw Exception('Room not found');

    final data = (snap.value as Map).cast<String, dynamic>();
    if (data['hostUid'] != uid) throw Exception('Only host can resume');

    final sessionRaw = data['session'];
    if (sessionRaw == null) throw Exception('No active session');

    final session = (sessionRaw as Map).cast<String, dynamic>();
    final remainingSec = (session['remainingSec'] ?? 0) as int;

    await roomRef(code).update({
      'status': 'running',
      'session': {
        ...session,
        'startAt': ServerValue.timestamp,
        'phaseDurationSec': remainingSec,
        'isPaused': false,
        'remainingSec': null,
      }
    });
  }

  Future<void> setMyCurrentRoom(String code) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await FirebaseDatabase.instance
        .ref('users/${user.uid}/currentRoom')
        .set(code);
  }

  Future<void> clearMyCurrentRoom() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await FirebaseDatabase.instance
        .ref('users/${user.uid}/currentRoom')
        .remove();
  }


}