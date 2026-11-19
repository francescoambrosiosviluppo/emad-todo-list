/// Un'attività della to-do list.
///
/// È immutabile: per modificarla se ne crea una copia con [copyWith].
class Task {
  Task({required this.title, this.important = false, this.completed = false})
      : id = _nextId++;

  Task._withId({
    required this.id,
    required this.title,
    required this.important,
    required this.completed,
  });

  static int _nextId = 0;

  /// Identificativo univoco, usato come chiave dei widget dell'elenco.
  final int id;

  /// Testo obbligatorio che descrive l'attività.
  final String title;

  /// `true` se l'attività è importante (per default no).
  final bool important;

  /// `true` se completata, `false` se ancora da fare (per default da fare).
  final bool completed;

  Task copyWith({String? title, bool? important, bool? completed}) {
    return Task._withId(
      id: id,
      title: title ?? this.title,
      important: important ?? this.important,
      completed: completed ?? this.completed,
    );
  }
}
