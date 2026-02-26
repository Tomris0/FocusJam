import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // TEK instance: her yerde bu kullanılacak
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    // Senin kullandığın web client id (serverClientId)
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
    // 1) Firebase çıkışı
    await _auth.signOut();

    // 2) Google hesabını cihazdan kopar -> tekrar girişte hesap seçtirir
    try {
      await _googleSignIn.disconnect();
    } catch (_) {
      // Bazı cihazlarda disconnect hata verebilir, fallback:
      await _googleSignIn.signOut();
    }
  }
}
