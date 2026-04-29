import 'package:flutter/material.dart';

import '../../models/task_model.dart';
import '../../services/task_service.dart';

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
      appBar: AppBar(title: const Text('Add Coursework Task')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Task title',
              hintText: 'Example: Finish UML diagram',
              prefixIcon: Icon(Icons.assignment_outlined),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _courseController,
            decoration: const InputDecoration(
              labelText: 'Course',
              hintText: 'Example: Mobile App Development',
              prefixIcon: Icon(Icons.school_outlined),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Deadline'),
              subtitle: Text(formattedDeadline),
              trailing: const Icon(Icons.edit_calendar),
              onTap: _pickDeadline,
            ),
          ),
          const SizedBox(height: 14),
          Text('Estimated effort: ${_estimatedEffort.round()} hour(s)'),
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
          const SizedBox(height: 8),
          Text('Course weight: ${_courseWeight.round()} / 10'),
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
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _saving ? null : _saveTask,
            icon: const Icon(Icons.save),
            label: Text(_saving ? 'Saving...' : 'Save Task'),
          ),
        ],
      ),
    );
  }
}
