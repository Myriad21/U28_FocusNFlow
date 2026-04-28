// Trajuan Smith
import 'package:flutter/material.dart';
import '../models/group_model.dart';
import '../services/group_service.dart';
import 'chat_test_screen.dart';

class GroupTestScreen extends StatelessWidget {
  final GroupService _groupService = GroupService();

  GroupTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study Groups')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _groupService.createGroup(
            'MAD Study Group ${DateTime.now().millisecondsSinceEpoch}',
          );
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<StudyGroup>>(
        stream: _groupService.streamUserGroups(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final groups = snapshot.data ?? [];

          if (groups.isEmpty) {
            return const Center(child: Text('No study groups found'));
          }

          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];

              return ListTile(
                title: Text(group.name),
                subtitle: Text('Members: ${group.members.length}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatTestScreen(groupId: group.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}