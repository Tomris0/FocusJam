import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'room_screen.dart';
import '../services/auth_service.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _openJoinSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;

        return Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Join a room',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Join code',
                  hintText: 'e.g. AB12CD',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  final code = _codeController.text.trim().toUpperCase();
                  if (code.length != 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code must be 6 characters.')),
                    );
                    return;
                  }

                  Navigator.pop(context);

                  Navigator.push(
                    this.context,
                    MaterialPageRoute(
                      builder: (_) => RoomScreen(roomCode: code, isHost: false),
                    ),
                  );
                },
                child: const Text('Join'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }

  String _generateJoinCode({int length = 6}) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random.secure();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  void _createRoom() {
    final code = _generateJoinCode();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Room created'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Share this code with your friends:'),
            const SizedBox(height: 12),
            SelectableText(
              code,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: code));
              if (!mounted) return;
              ScaffoldMessenger.of(this.context).showSnackBar(
                const SnackBar(content: Text('Code copied to clipboard')),
              );
            },
            child: const Text('Copy'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.push(
                this.context,
                MaterialPageRoute(
                  builder: (_) => RoomScreen(roomCode: code, isHost: true),
                ),
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FocusJam'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              await AuthService.instance.signOut();

            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Study together. Stay in sync.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _createRoom,
                child: const Text('Create Room'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _openJoinSheet,
                child: const Text('Join with Code'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}