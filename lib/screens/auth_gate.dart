import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'auth_screen.dart';
import 'home_screen.dart';
import 'room_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) return const AuthScreen();

        return FutureBuilder(
          future: FirebaseDatabase.instance
              .ref('users/${user.uid}/currentRoom')
              .get(),
          builder: (context, roomSnap) {
            if (roomSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final roomCode = roomSnap.data?.value as String?;

            if (roomCode != null) {
              return RoomScreen(
                roomCode: roomCode,
                isHost: false,
              );
            }

            return const HomeScreen();
          },
        );
      },
    );
  }
}