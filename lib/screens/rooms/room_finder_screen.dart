import 'package:flutter/material.dart';

import '../../models/room_model.dart';
import '../../services/auth_service.dart';
import '../../services/room_service.dart';
import '../../widgets/empty_state.dart';

class RoomFinderScreen extends StatelessWidget {
  const RoomFinderScreen({super.key});

  Future<void> _handleRoomAction({
    required BuildContext context,
    required StudyRoom room,
    required bool isMember,
  }) async {
    try {
      if (isMember) {
        await RoomService().leaveRoom(room.id);
      } else {
        await RoomService().joinRoom(room.id);
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isMember ? 'Left ${room.name}' : 'Joined ${room.name}'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomService = RoomService();
    final userId = AuthService().currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Finder'),
        actions: [
          IconButton(
            tooltip: 'Add demo room',
            onPressed: () => roomService.addTestRoom(),
            icon: const Icon(Icons.add_business),
          ),
        ],
      ),
      body: StreamBuilder<List<StudyRoom>>(
        stream: roomService.streamRooms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final rooms = snapshot.data ?? [];

          if (rooms.isEmpty) {
            return const EmptyState(
              icon: Icons.meeting_room_outlined,
              title: 'No rooms available',
              subtitle: 'Use the add button to create a demo room.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              final isMember = room.members.contains(userId);
              final availableSeats = room.capacity - room.currentOccupancy;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          child: Icon(
                            room.isAvailable ? Icons.event_seat : Icons.block,
                          ),
                        ),
                        title: Text(room.name),
                        subtitle: Text(
                          '${room.currentOccupancy}/${room.capacity} occupied • $availableSeats seat(s) open',
                        ),
                        trailing: Chip(
                          label: Text(room.isAvailable ? 'Open' : 'Full'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: room.capacity == 0
                            ? 0
                            : room.currentOccupancy / room.capacity,
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: isMember
                            ? OutlinedButton.icon(
                                onPressed: () => _handleRoomAction(
                                  context: context,
                                  room: room,
                                  isMember: true,
                                ),
                                icon: const Icon(Icons.logout),
                                label: const Text('Leave Room'),
                              )
                            : FilledButton.icon(
                                onPressed: room.isAvailable
                                    ? () => _handleRoomAction(
                                        context: context,
                                        room: room,
                                        isMember: false,
                                      )
                                    : null,
                                icon: const Icon(Icons.login),
                                label: const Text('Join Room'),
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
