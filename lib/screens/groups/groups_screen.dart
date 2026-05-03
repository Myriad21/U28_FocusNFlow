import 'package:flutter/material.dart';

import '../../models/group_model.dart';
import '../../services/auth_service.dart';
import '../../services/group_service.dart';
import '../../widgets/empty_state.dart';
import 'group_chat_screen.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  Future<void> _showCreateDialog(BuildContext context) async {
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Create Study Group'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Group name',
              hintText: 'Example: MAD Final Prep',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final groupName = controller.text.trim();
                Navigator.of(dialogContext).pop(groupName);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.dispose();
    });

    if (name == null || name.isEmpty) return;

    await GroupService().createGroup(name);
  }

  @override
  Widget build(BuildContext context) {
    final groupService = GroupService();
    final currentUserId = AuthService().currentUserId;

    return Scaffold(
      appBar: AppBar(title: const Text('Study Groups')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
      body: StreamBuilder<List<StudyGroup>>(
        stream: groupService.streamAllGroups(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final groups = snapshot.data ?? [];

          if (groups.isEmpty) {
            return const EmptyState(
              icon: Icons.groups_outlined,
              title: 'No groups yet',
              subtitle: 'Create a study group for your course or exam prep.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              final isMember = group.members.contains(currentUserId);

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(group.name.substring(0, 1).toUpperCase()),
                  ),
                  title: Text(group.name),
                  subtitle: Text('${group.members.length} member(s)'),
                  trailing: isMember
    ? const Icon(Icons.chevron_right)
    : SizedBox(
        width: 80,
        child: FilledButton(
          onPressed: () async {
            await groupService.joinGroup(group.id);
          },
          child: const Text('Join'),
        ),
      ),
                  onTap: isMember
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GroupChatScreen(group: group),
                            ),
                          );
                        }
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
