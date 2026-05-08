import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../services/room_service.dart';
import '../widgets/setting_row.dart';
import 'timer_screen.dart';
import 'home_screen.dart';

class RoomScreen extends StatefulWidget {
  final String roomCode;
  final bool isHost;

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
  bool _movedToTimer = false;

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
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await RoomService.instance.clearMyCurrentRoom();

            if (!context.mounted) return;

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
            );
          });

          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final room = (raw as Map).cast<String, dynamic>();

        final hostUid = room['hostUid'] as String?;
        final bool amIHost =
            hostUid != null && _myUid.isNotEmpty && hostUid == _myUid;

        final status = (room['status'] ?? 'lobby') as String;
        final sessionRaw = room['session'];

        if (status == 'running' && sessionRaw != null && !_movedToTimer) {
          _movedToTimer = true;

          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!mounted) return;

            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TimerScreen(roomCode: widget.roomCode),
              ),
            );

            if (mounted) {
              _movedToTimer = false;
            }
          });
        }

        final settingsRaw = room['settings'];
        final settings = (settingsRaw is Map)
            ? settingsRaw.cast<String, dynamic>()
            : <String, dynamic>{};

        final int workMin = (settings['workMinutes'] as num? ?? 25).toInt();
        final int breakMin = (settings['breakMinutes'] as num? ?? 5).toInt();
        final int sets = (settings['sets'] as num? ?? 4).toInt();
        final bool includeBreaksInTotal =
        (settings['includeBreaksInTotal'] ?? false) as bool;

        final membersRaw = room['members'];
        final int memberCount = (membersRaw is Map) ? membersRaw.length : 0;

        final Map<String, dynamic> membersMap =
        (membersRaw is Map) ? membersRaw.cast<String, dynamic>() : {};

        final memberEntries = membersMap.entries.toList()
          ..sort((a, b) {
            final aJoined =
            (((a.value as Map)['joinedAt']) as num? ?? 0).toInt();
            final bJoined =
            (((b.value as Map)['joinedAt']) as num? ?? 0).toInt();
            return aJoined.compareTo(bJoined);
          });

        return Scaffold(
          appBar: AppBar(
            title: const Text('Room'),
            actions: [
              TextButton(
                onPressed: () async {
                  await RoomService.instance.removeSelfFromMember(
                    widget.roomCode,
                  );
                  await RoomService.instance.clearMyCurrentRoom();

                  if (!context.mounted) return;

                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                  );
                },
                child: const Text('Leave'),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    children: [
                      const Text(
                        'Room Code',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      SelectableText(
                        widget.roomCode,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        amIHost ? 'Host: You 👑' : 'Host: (in room)',
                        style: const TextStyle(fontSize: 16),
                      ),

                      const SizedBox(height: 8),

                      Text('Members: $memberCount / 32'),

                      const SizedBox(height: 12),

                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Members',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 8),

                              if (memberEntries.isEmpty)
                                const Text('No members yet')
                              else
                                ...memberEntries.map((entry) {
                                  final uid = entry.key;
                                  final member = (entry.value as Map)
                                      .cast<String, dynamic>();

                                  final displayName =
                                  (member['displayName'] ?? 'User')
                                      .toString();

                                  final isMe = uid == _myUid;
                                  final isHostMember = uid == hostUid;

                                  final subtitleParts = <String>[
                                    if (isMe) 'You',
                                    if (isHostMember) 'Host 👑',
                                  ];

                                  return ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    leading: CircleAvatar(
                                      child: Text(
                                        displayName.isNotEmpty
                                            ? displayName[0].toUpperCase()
                                            : '?',
                                      ),
                                    ),
                                    title: Text(
                                      displayName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      subtitleParts.isEmpty
                                          ? 'Member'
                                          : subtitleParts.join(' • '),
                                    ),
                                  );
                                }),
                            ],
                          ),
                        ),
                      ),

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
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
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
                                label: includeBreaksInTotal
                                    ? 'Total per set (min)'
                                    : 'Work (min)',
                                value: workMin,
                                enabled: amIHost,
                                onMinus: () async {
                                  final newWork =
                                  (workMin > 5) ? workMin - 5 : workMin;

                                  final newBreak =
                                  (includeBreaksInTotal &&
                                      breakMin >= newWork)
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
                                  final newBreak = (breakMin > 1)
                                      ? breakMin - 1
                                      : breakMin;

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

                                  if (includeBreaksInTotal &&
                                      newBreak >= workMin) {
                                    await RoomService.instance.updateSettings(
                                      code: widget.roomCode,
                                      workMinutes: workMin,
                                      breakMinutes:
                                      (workMin > 1) ? workMin - 1 : 1,
                                      sets: sets,
                                      includeBreaksInTotal:
                                      includeBreaksInTotal,
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
                                title: const Text(
                                  'Include breaks in total time?',
                                ),
                                subtitle: const Text(
                                  'If ON, total time includes breaks.',
                                ),
                                value: includeBreaksInTotal,
                                onChanged: amIHost
                                    ? (v) async {
                                  var nextBreak = breakMin;

                                  if (v && nextBreak >= workMin) {
                                    nextBreak =
                                    (workMin > 1) ? workMin - 1 : 1;
                                  }

                                  await RoomService.instance
                                      .updateSettings(
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

                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    MediaQuery.of(context).padding.bottom + 12,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: amIHost
                          ? () async {
                        await RoomService.instance.startSession(
                          code: widget.roomCode,
                        );
                      }
                          : null,
                      child: const Text('Start Session (host only)'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}