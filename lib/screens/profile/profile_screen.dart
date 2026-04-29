import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/section_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _uploading = false;
  String? _lastUploadUrl;

  Future<void> _uploadResource() async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      allowMultiple: false,
    );

    if (!mounted) return;

    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;

    if (file.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not read selected file.')),
      );
      return;
    }

    setState(() => _uploading = true);

    try {
      final url = await StorageService().uploadStudyResource(
        fileName: file.name,
        bytes: file.bytes!,
      );

      if (!mounted) return;

      setState(() => _lastUploadUrl = url);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Study resource uploaded.')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      if (mounted) {
        setState(() => _uploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Account', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(user?.email ?? 'Guest User'),
                  subtitle: Text('UID: ${user?.uid ?? 'Not signed in'}'),
                ),
              ],
            ),
          ),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Study Preferences',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                const SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: true,
                  onChanged: null,
                  title: Text('Study session reminders'),
                  subtitle: Text('FCM token is stored after login.'),
                ),
                const SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: true,
                  onChanged: null,
                  title: Text('Group schedule updates'),
                  subtitle: Text('Used for future group notifications.'),
                ),
              ],
            ),
          ),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shared Study Resources',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Upload optional study resources to Firebase Storage.',
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: _uploading ? null : _uploadResource,
                  icon: const Icon(Icons.upload_file),
                  label: Text(_uploading ? 'Uploading...' : 'Upload Resource'),
                ),
                if (_lastUploadUrl != null) ...[
                  const SizedBox(height: 12),
                  SelectableText(
                    'Last uploaded URL:\n$_lastUploadUrl',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => AuthService().signOut(),
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
