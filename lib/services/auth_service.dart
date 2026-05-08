import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    serverClientId:
    '623015359847-9n9bup4gdpoanmi18o50u8qt1gack752.apps.googleusercontent.com',
  );

  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception('Google sign-in cancelled');
    }

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    final user = _auth.currentUser;

    if (user != null) {
      final currentRoomRef = _db.ref('users/${user.uid}/currentRoom');
      final currentRoomSnap = await currentRoomRef.get();

      final roomCode = currentRoomSnap.value as String?;

      if (roomCode != null && roomCode.isNotEmpty) {
        final roomRef = _db.ref('rooms/$roomCode');
        final membersRef = roomRef.child('members');

        await membersRef.child(user.uid).remove();

        final membersSnap = await membersRef.get();

        if (!membersSnap.exists || membersSnap.children.isEmpty) {
          await roomRef.remove();
        }
      }

      await currentRoomRef.remove();
    }

    await _auth.signOut();

    try {
      await _googleSignIn.disconnect();
    } catch (_) {
      await _googleSignIn.signOut();
    }
  }
}