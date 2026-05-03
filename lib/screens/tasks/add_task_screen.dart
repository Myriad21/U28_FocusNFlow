import 'package:flutter/material.dart';

import '../../models/task_model.dart';
import '../../services/task_service.dart';
import '../../widgets/section_card.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TaskService _taskService = TaskService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();

  DateTime _deadline = DateTime.now().add(const Duration(days: 3));
  double _estimatedEffort = 3;
  double _courseWeight = 5;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selected != null) {
      setState(() => _deadline = selected);
    }
  }

  Future<void> _saveTask() async {
    final title = _titleController.text.trim();
    final course = _courseController.text.trim();

    if (title.isEmpty || course.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter task title and course.')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final task = Task(
        id: '',
        userId: '',
        title: title,
        course: course,
        deadline: _deadline,
        estimatedEffort: _estimatedEffort.round(),
        courseWeight: _courseWeight.round(),
      );

      await _taskService.addTask(task);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Task saved successfully.')));

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save task: $e')));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDeadline =
        '${_deadline.month}/${_deadline.day}/${_deadline.year}';

    return Scaffold(
      appBar: AppBar(title: const Text('Add Task')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.assignment_add, color: Colors.white, size: 36),
                SizedBox(height: 16),
                Text(
                  'Create a focused study task',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Deadline, effort, and course weight help generate a smarter weekly plan.',
                  style: TextStyle(color: Colors.white, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SectionCard(
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task title',
                    hintText: 'Finish project demo script',
                    prefixIcon: Icon(Icons.edit_note),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _courseController,
                  decoration: const InputDecoration(
                    labelText: 'Course',
                    hintText: 'Mobile App Development',
                    prefixIcon: Icon(Icons.school_outlined),
                  ),
                ),
                const SizedBox(height: 14),
                InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: _pickDeadline,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFFE0E7FF),
                          child: Icon(Icons.event, color: Color(0xFF4F46E5)),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Deadline',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                            Text(formattedDeadline),
                          ],
                        ),
                        const Spacer(),
                        const Icon(Icons.edit_calendar),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SliderHeader(
                  title: 'Estimated Effort',
                  value: '${_estimatedEffort.round()} hr',
                  icon: Icons.timer_outlined,
                ),
                Slider(
                  min: 1,
                  max: 10,
                  divisions: 9,
                  value: _estimatedEffort,
                  label: _estimatedEffort.round().toString(),
                  onChanged: (value) {
                    setState(() => _estimatedEffort = value);
                  },
                ),
                const SizedBox(height: 12),
                _SliderHeader(
                  title: 'Course Weight',
                  value: '${_courseWeight.round()}/10',
                  icon: Icons.trending_up,
                ),
                Slider(
                  min: 1,
                  max: 10,
                  divisions: 9,
                  value: _courseWeight,
                  label: _courseWeight.round().toString(),
                  onChanged: (value) {
                    setState(() => _courseWeight = value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _saving ? null : _saveTask,
            icon: const Icon(Icons.save),
            label: Text(_saving ? 'Saving Task...' : 'Save Task'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SliderHeader extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SliderHeader({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4F46E5)),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFE0E7FF),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF4F46E5),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}
