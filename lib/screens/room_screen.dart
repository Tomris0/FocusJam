import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../services/room_service.dart';
import '../widgets/setting_row.dart';
import 'timer_screen.dart';

class RoomScreen extends StatefulWidget {
  final String roomCode;
  final bool isHost; // artık sadece ilk tahmin; gerçek host DB’den okunacak

  const RoomScreen({
    super.key,
    required this.roomCode,
    required this.isHost,
  });

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  String get _myUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: RoomService.instance.watchRoom(widget.roomCode),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final raw = snapshot.data?.snapshot.value;
        if (raw == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Room')),
            body: const Center(child: Text('Room not found / deleted')),
          );
        }

        final room = (raw as Map).cast<String, dynamic>();

        final hostUid = room['hostUid'] as String?;
        final bool amIHost = hostUid != null && _myUid.isNotEmpty && hostUid == _myUid;

        // Settings (DB’den oku -> lokal değişkenler)
        final settingsRaw = room['settings'];
        final settings = (settingsRaw is Map) ? settingsRaw.cast<String, dynamic>() : <String, dynamic>{};

        final int workMin = (settings['workMinutes'] ?? 25) as int;
        final int breakMin = (settings['breakMinutes'] ?? 5) as int;
        final int sets = (settings['sets'] ?? 4) as int;
        final bool includeBreaksInTotal = (settings['includeBreaksInTotal'] ?? false) as bool;

        // Members count
        final membersRaw = room['members'];
        final int memberCount = (membersRaw is Map) ? membersRaw.length : 0;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Room'),
            actions: [
              TextButton(
                onPressed: () async {
                  await RoomService.instance.removeSelfFromMember(widget.roomCode);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
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
                  amIHost ? 'Host: You 👑' : 'Host: (in room)',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text('Members: $memberCount / 32'),
                const SizedBox(height: 20),

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
                            Text(
                              amIHost ? 'Host can edit' : 'View only',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        SettingRow(
                          label: includeBreaksInTotal ? 'Total per set (min)' : 'Work (min)',
                          value: workMin,
                          enabled: amIHost,
                          onMinus: () async {
                            final newWork = (workMin > 5) ? workMin - 5 : workMin;

                            // total moddaysa break >= total olmasın
                            final newBreak = (includeBreaksInTotal && breakMin >= newWork)
                                ? ((newWork > 1) ? newWork - 1 : 1)
                                : breakMin;

                            await RoomService.instance.updateSettings(
                              code: widget.roomCode,
                              workMinutes: newWork,
                              breakMinutes: newBreak,
                              sets: sets,
                              includeBreaksInTotal: includeBreaksInTotal,
                            );
                          },
                          onPlus: () async {
                            final newWork = workMin + 5;
                            await RoomService.instance.updateSettings(
                              code: widget.roomCode,
                              workMinutes: newWork,
                              breakMinutes: breakMin,
                              sets: sets,
                              includeBreaksInTotal: includeBreaksInTotal,
                            );
                          },
                        ),

                        const SizedBox(height: 8),

                        SettingRow(
                          label: 'Break (min)',
                          value: breakMin,
                          enabled: amIHost,
                          onMinus: () async {
                            final newBreak = (breakMin > 1) ? breakMin - 1 : breakMin;
                            await RoomService.instance.updateSettings(
                              code: widget.roomCode,
                              workMinutes: workMin,
                              breakMinutes: newBreak,
                              sets: sets,
                              includeBreaksInTotal: includeBreaksInTotal,
                            );
                          },
                          onPlus: () async {
                            final newBreak = breakMin + 1;

                            // total moddaysa break >= total olmasın
                            if (includeBreaksInTotal && newBreak >= workMin) {
                              // izin verme (ya da otomatik düzelt)
                              await RoomService.instance.updateSettings(
                                code: widget.roomCode,
                                workMinutes: workMin,
                                breakMinutes: (workMin > 1) ? workMin - 1 : 1,
                                sets: sets,
                                includeBreaksInTotal: includeBreaksInTotal,
                              );
                              return;
                            }

                            await RoomService.instance.updateSettings(
                              code: widget.roomCode,
                              workMinutes: workMin,
                              breakMinutes: newBreak,
                              sets: sets,
                              includeBreaksInTotal: includeBreaksInTotal,
                            );
                          },
                        ),

                        const SizedBox(height: 8),

                        SettingRow(
                          label: 'Sets',
                          value: sets,
                          enabled: amIHost,
                          onMinus: () async {
                            final newSets = (sets > 1) ? sets - 1 : sets;
                            await RoomService.instance.updateSettings(
                              code: widget.roomCode,
                              workMinutes: workMin,
                              breakMinutes: breakMin,
                              sets: newSets,
                              includeBreaksInTotal: includeBreaksInTotal,
                            );
                          },
                          onPlus: () async {
                            final newSets = sets + 1;
                            await RoomService.instance.updateSettings(
                              code: widget.roomCode,
                              workMinutes: workMin,
                              breakMinutes: breakMin,
                              sets: newSets,
                              includeBreaksInTotal: includeBreaksInTotal,
                            );
                          },
                        ),

                        const SizedBox(height: 8),

                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Include breaks in total time?'),
                          subtitle: const Text('If ON, total time includes breaks.'),
                          value: includeBreaksInTotal,
                          onChanged: amIHost
                              ? (v) async {
                            // ON yapılınca break >= total ise break’i düzelt
                            var nextBreak = breakMin;
                            if (v && nextBreak >= workMin) {
                              nextBreak = (workMin > 1) ? workMin - 1 : 1;
                            }

                            await RoomService.instance.updateSettings(
                              code: widget.roomCode,
                              workMinutes: workMin,
                              breakMinutes: nextBreak,
                              sets: sets,
                              includeBreaksInTotal: v,
                            );
                          }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                FilledButton(
                  onPressed: amIHost
                      ? () async {
                    await RoomService.instance.startSession(code: widget.roomCode);

                    if (!context.mounted) return;
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
      },
    );
  }
}