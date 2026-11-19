import 'package:flutter/material.dart';

import '../models/task.dart';

/// Schermata di creazione di una nuova attività (S1).
///
/// Alla conferma restituisce la [Task] creata con `Navigator.pop`.
/// Se l'utente torna indietro senza confermare, il risultato è `null`.
class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({super.key});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  final _titleController = TextEditingController();
  bool _important = false;

  /// Diventa `true` dopo il primo tentativo di conferma: da quel momento
  /// l'errore viene mostrato (o nascosto) a ogni modifica del titolo.
  bool _submitted = false;

  bool get _titleIsEmpty => _titleController.text.trim().isEmpty;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _confirm() {
    setState(() => _submitted = true);

    // Variante "titolo mancante": errore mostrato, nessuna attività creata.
    if (_titleIsEmpty) return;

    Navigator.of(context).pop(
      Task(title: _titleController.text.trim(), important: _important),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuova attività')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Titolo *',
              hintText: 'Es. Comprare il latte',
              border: const OutlineInputBorder(),
              errorText: _submitted && _titleIsEmpty
                  ? 'Inserisci un titolo per l\'attività'
                  : null,
            ),
            // Ridisegna per far sparire l'errore appena il titolo è corretto.
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _confirm(),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Importante'),
            secondary: Icon(
              _important ? Icons.star : Icons.star_border,
              color: _important ? Colors.amber.shade800 : null,
            ),
            value: _important,
            onChanged: (value) => setState(() => _important = value),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _confirm,
            icon: const Icon(Icons.check),
            label: const Text('Aggiungi'),
          ),
        ],
      ),
    );
  }
}
