import 'package:flutter/material.dart';

import '../models/task.dart';
import '../widgets/task_tile.dart';
import 'new_task_screen.dart';

/// Schermata principale: elenco delle attività (S2, S3, S4).
///
/// Lo stato dell'app (la lista delle attività) vive qui ed è condiviso con i
/// widget figli tramite parametri e callback.
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final List<Task> _tasks = [];

  int get _completedCount => _tasks.where((t) => t.completed).length;

  /// S1 – Aggiungere un'attività.
  Future<void> _addTask() async {
    final Task? newTask = await Navigator.of(context).push<Task>(
      MaterialPageRoute(builder: (_) => const NewTaskScreen()),
    );

    // Variante "rinuncia": l'utente è tornato indietro senza confermare.
    if (newTask == null || !mounted) return;

    setState(() => _tasks.add(newTask));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Attività "${newTask.title}" aggiunta')),
      );
  }

  /// S3 – Aggiornare lo stato di un'attività.
  void _toggleCompleted(Task task) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      _tasks[index] = task.copyWith(completed: !task.completed);
    });
  }

  /// S4 – Eliminare un'attività, previa conferma.
  Future<void> _deleteTask(Task task) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminare l\'attività?'),
        content: Text('"${task.title}" verrà eliminata definitivamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    // Variante "rinuncia": dialogo annullato o chiuso toccando fuori.
    if (confirmed != true) return;

    setState(() => _tasks.removeWhere((t) => t.id == task.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Le mie attività'),
        bottom: _tasks.isEmpty
            ? null
            : _ProgressHeader(completed: _completedCount, total: _tasks.length),
      ),
      body: _tasks.isEmpty
          ? const _EmptyState()
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 88),
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return TaskTile(
                  key: ValueKey(task.id),
                  task: task,
                  onToggle: () => _toggleCompleted(task),
                  onDelete: () => _deleteTask(task),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTask,
        icon: const Icon(Icons.add),
        label: const Text('Nuova attività'),
      ),
    );
  }
}

/// Conteggio delle attività completate sul totale, con barra di avanzamento.
class _ProgressHeader extends StatelessWidget implements PreferredSizeWidget {
  const _ProgressHeader({required this.completed, required this.total});

  final int completed;
  final int total;

  @override
  Size get preferredSize => const Size.fromHeight(44);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Completate: $completed su $total',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: completed / total,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

/// Variante di S2 – nessuna attività.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.checklist_rounded,
              size: 72,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text('Nessuna attività', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Tocca "Nuova attività" in basso per aggiungerne una.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
