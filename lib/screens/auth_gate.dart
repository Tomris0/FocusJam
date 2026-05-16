import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'auth_screen.dart';
import 'home_screen.dart';
import 'room_screen.dart';
import 'timer_screen.dart';

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
              return FutureBuilder(
                future: FirebaseDatabase.instance.ref('rooms/$roomCode').get(),
                builder: (context, activeRoomSnap) {
                  if (activeRoomSnap.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final roomRaw = activeRoomSnap.data?.value;

                  if (roomRaw == null) {
                    FirebaseDatabase.instance
                        .ref('users/${user.uid}/currentRoom')
                        .remove();

                    return const HomeScreen();
                  }

                  final room = (roomRaw as Map).cast<String, dynamic>();
                  final status = (room['status'] ?? 'lobby') as String;
                  final sessionRaw = room['session'];

                  if (status == 'running' && sessionRaw != null) {
                    return TimerScreen(roomCode: roomCode);
                  }

                  return RoomScreen(
                    roomCode: roomCode,
                    isHost: false,
                  );
                },
              );
            }

            return const HomeScreen();
          },
        );
      },
    );
  }
}