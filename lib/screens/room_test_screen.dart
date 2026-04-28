import 'package:flutter/material.dart';
import '../models/room_model.dart';
import '../services/room_service.dart';

class RoomTestScreen extends StatelessWidget {
  final RoomService _roomService = RoomService();

  RoomTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study Rooms')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _roomService.addTestRoom();
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<StudyRoom>>(
        stream: _roomService.streamRooms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final rooms = snapshot.data ?? [];

          if (rooms.isEmpty) {
            return const Center(child: Text('No rooms available'));
          }

          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];

              return ListTile(
                title: Text(room.name),
                subtitle: Text(
                  'Occupancy: ${room.currentOccupancy} / ${room.capacity}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.login),
                      onPressed: () async {
                        try {
                          await _roomService.joinRoom(room.id);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () async {
                        await _roomService.leaveRoom(room.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}