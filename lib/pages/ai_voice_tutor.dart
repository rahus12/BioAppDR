import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bioappdr/pages/search_index.dart';

/// Lesson Planner & Task Manager (replaces AI Voice Tutor)
/// - Bilingual (English/Spanish)
/// - Uses app theme
/// - Kid-friendly UI with GIFs and subtle animations
/// - Persists data via SharedPreferences
class AiVoiceTutorPage extends StatefulWidget {
  const AiVoiceTutorPage({super.key});

  @override
  State<AiVoiceTutorPage> createState() => _LessonPlannerPageState();
}

class _LessonPlannerPageState extends State<AiVoiceTutorPage> {
  bool _isSpanish = false;
  bool _loaded = false;
  List<Map<String, dynamic>> _lessons = [];
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final lessonsStr = prefs.getString('lesson_plans') ?? '[]';
    final tasksStr = prefs.getString('planner_tasks') ?? '[]';
    setState(() {
      _lessons = List<Map<String, dynamic>>.from(jsonDecode(lessonsStr));
      _tasks = List<Map<String, dynamic>>.from(jsonDecode(tasksStr));
      _loaded = true;
    });
  }

  Future<void> _saveLessons() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lesson_plans', jsonEncode(_lessons));
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('planner_tasks', jsonEncode(_tasks));
  }

  void _toggleLanguage() => setState(() => _isSpanish = !_isSpanish);

  String _formatDT(String? iso) {
    if (iso == null) return _isSpanish ? 'Sin horario' : 'No schedule';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '-';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}  $h:$m';
  }

  Future<void> _addLessonDialog() async {
    String gifPath = 'assets/PlantGrowing.gif';
    DateTime? date;
    TimeOfDay? time;
    String repeat = 'none';
    String filterType = 'all'; // 'all' | 'lesson' | 'game'
    int? selectedIndex;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: StatefulBuilder(builder: (ctx, setModal) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/Robot.gif', height: 48),
                      const SizedBox(width: 8),
                      Text(
                        _isSpanish ? 'Nueva lección' : 'New Lesson',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Filter chips for type
                  Wrap(spacing: 8, children: [
                    ChoiceChip(
                      label: Text(_isSpanish ? 'Todos' : 'All'),
                      selected: filterType == 'all',
                      onSelected: (_) => setModal(() => filterType = 'all'),
                    ),
                    ChoiceChip(
                      label: Text(_isSpanish ? 'Lecciones' : 'Lessons'),
                      selected: filterType == 'lesson',
                      onSelected: (_) => setModal(() => filterType = 'lesson'),
                    ),
                    ChoiceChip(
                      label: Text(_isSpanish ? 'Juegos' : 'Games'),
                      selected: filterType == 'game',
                      onSelected: (_) => setModal(() => filterType = 'game'),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  // Touch-only selection from existing pages
                  Builder(builder: (ctx) {
                    final items = searchItems.where((e) => filterType == 'all' ? true : e.type == filterType).toList();
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final item = items[i];
                        final isSelected = selectedIndex == i;
                        return GestureDetector(
                          onTap: () => setModal(() => selectedIndex = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: isSelected ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surface,
                              border: Border.all(
                                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(item.type == 'game' ? Icons.videogame_asset : Icons.school,
                                    color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : null),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final p in [
                        'assets/PlantGrowing.gif',
                        'assets/monkey.gif',
                        'assets/bones.gif',
                        'assets/brain.gif',
                        'assets/Heart.gif',
                        'assets/tv.gif',
                      ])
                        GestureDetector(
                          onTap: () => setModal(() => gifPath = p),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: gifPath == p
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            child: Image.asset(p, height: 50),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text(_isSpanish ? 'Elegir fecha' : 'Pick date'),
                          onPressed: () async {
                            final d = await showDatePicker(
                              context: ctx,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2023),
                              lastDate: DateTime(2030),
                            );
                            if (d != null) setModal(() => date = d);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.schedule),
                          label: Text(_isSpanish ? 'Elegir hora' : 'Pick time'),
                          onPressed: () async {
                            final t = await showTimePicker(
                              context: ctx,
                              initialTime: TimeOfDay.now(),
                            );
                            if (t != null) setModal(() => time = t);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: repeat,
                    decoration: InputDecoration(
                      labelText: _isSpanish ? 'Repetir' : 'Repeat',
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      ('none', _isSpanish ? 'No repetir' : 'Do not repeat'),
                      ('daily', _isSpanish ? 'Diario' : 'Daily'),
                      ('weekly', _isSpanish ? 'Semanal' : 'Weekly'),
                    ].map((e) => DropdownMenuItem(value: e.$1, child: Text(e.$2))).toList(),
                    onChanged: (v) => setModal(() => repeat = v ?? 'none'),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle),
                      label: Text(_isSpanish ? 'Guardar' : 'Save'),
                      onPressed: () {
                        // Must choose an item
                        final items = searchItems.where((e) => filterType == 'all' ? true : e.type == filterType).toList();
                        if (selectedIndex == null || selectedIndex! < 0 || selectedIndex! >= items.length) return;
                        final chosen = items[selectedIndex!];
                        final dt = (date != null && time != null)
                            ? DateTime(date!.year, date!.month, date!.day, time!.hour, time!.minute)
                            : null;
                        setState(() {
                          _lessons.add({
                            'id': DateTime.now().millisecondsSinceEpoch,
                            'title': chosen.title,
                            'route': chosen.route,
                            'type': chosen.type,
                            'gif': gifPath,
                            'datetime': dt?.toIso8601String(),
                            'repeat': repeat,
                          });
                        });
                        _saveLessons();
                        Navigator.pop(ctx);
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Future<void> _addTaskDialog() async {
    DateTime? date;
    TimeOfDay? time;
    String iconPath = 'assets/trophy.png';
    String filterType = 'all';
    int? selectedIndex;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          Image.asset('assets/monkey.gif', height: 40),
          const SizedBox(width: 8),
          Text(_isSpanish ? 'Nueva tarea' : 'New Task'),
        ]),
        content: StatefulBuilder(builder: (ctx, setModal) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Filter chips
              Wrap(spacing: 8, children: [
                ChoiceChip(
                  label: Text(_isSpanish ? 'Todos' : 'All'),
                  selected: filterType == 'all',
                  onSelected: (_) => setModal(() => filterType = 'all'),
                ),
                ChoiceChip(
                  label: Text(_isSpanish ? 'Lecciones' : 'Lessons'),
                  selected: filterType == 'lesson',
                  onSelected: (_) => setModal(() => filterType = 'lesson'),
                ),
                ChoiceChip(
                  label: Text(_isSpanish ? 'Juegos' : 'Games'),
                  selected: filterType == 'game',
                  onSelected: (_) => setModal(() => filterType = 'game'),
                ),
              ]),
              const SizedBox(height: 8),
              // Selection grid
              Builder(builder: (ctx) {
                final items = searchItems.where((e) => filterType == 'all' ? true : e.type == filterType).toList();
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final item = items[i];
                    final isSelected = selectedIndex == i;
                    return GestureDetector(
                      onTap: () => setModal(() => selectedIndex = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surface,
                          border: Border.all(
                            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(item.type == 'game' ? Icons.videogame_asset : Icons.school,
                                color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : null),
                            const SizedBox(width: 8),
                            Expanded(child: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: [
                for (final p in ['assets/trophy.png', 'assets/Robot.gif', 'assets/Heart.gif'])
                  GestureDetector(
                    onTap: () => setModal(() => iconPath = p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: iconPath == p
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      child: Image.asset(p, height: 40),
                    ),
                  ),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_isSpanish ? 'Elegir fecha' : 'Pick date'),
                    onPressed: () async {
                      final d = await showDatePicker(
                        context: ctx,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2023),
                        lastDate: DateTime(2030),
                      );
                      if (d != null) setModal(() => date = d);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.schedule),
                    label: Text(_isSpanish ? 'Elegir hora' : 'Pick time'),
                    onPressed: () async {
                      final t = await showTimePicker(
                        context: ctx,
                        initialTime: TimeOfDay.now(),
                      );
                      if (t != null) setModal(() => time = t);
                    },
                  ),
                ),
              ]),
            ],
          );
        }),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_isSpanish ? 'Cancelar' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final items = searchItems.where((e) => filterType == 'all' ? true : e.type == filterType).toList();
              if (selectedIndex == null || selectedIndex! < 0 || selectedIndex! >= items.length) return;
              final chosen = items[selectedIndex!];
              final dt = (date != null && time != null)
                  ? DateTime(date!.year, date!.month, date!.day, time!.hour, time!.minute)
                  : null;
              setState(() {
                _tasks.add({
                  'id': DateTime.now().millisecondsSinceEpoch,
                  'title': (chosen.type == 'game')
                      ? (_isSpanish ? 'Jugar: ' : 'Play: ') + chosen.title
                      : (_isSpanish ? 'Estudiar: ' : 'Study: ') + chosen.title,
                  'route': chosen.route,
                  'type': chosen.type,
                  'icon': iconPath,
                  'datetime': dt?.toIso8601String(),
                  'done': false,
                });
              });
              _saveTasks();
              Navigator.pop(ctx);
            },
            child: Text(_isSpanish ? 'Guardar' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _deleteLesson(int id) {
    setState(() => _lessons.removeWhere((e) => e['id'] == id));
    _saveLessons();
  }

  void _toggleTaskDone(int id) {
    setState(() {
      final idx = _tasks.indexWhere((e) => e['id'] == id);
      if (idx != -1) _tasks[idx]['done'] = !(_tasks[idx]['done'] as bool);
    });
    _saveTasks();
  }

  void _deleteTask(int id) {
    setState(() => _tasks.removeWhere((e) => e['id'] == id));
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSpanish ? 'Planificador y Tareas' : 'Lesson Planner & Tasks'),
        actions: [
          IconButton(
            tooltip: _isSpanish ? 'Cambiar idioma' : 'Toggle language',
            icon: const Icon(Icons.translate),
            onPressed: _toggleLanguage,
          ),
        ],
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero banner
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cs.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isSpanish ? '¡Planifica, aprende y gana!' : 'Plan, Learn & Earn!',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _isSpanish
                                      ? 'Crea lecciones divertidas y tareas. ¡Usa gifs para hacerlo genial!'
                                      : 'Create fun lessons and tasks. Use gifs to make it awesome!',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          Image.asset('assets/PlantGrowing.gif', height: 80),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Lessons Section
                    Row(
                      children: [
                        Image.asset('assets/brain.gif', height: 28),
                        const SizedBox(width: 8),
                        Text(
                          _isSpanish ? 'Mis lecciones' : 'My Lessons',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: _addLessonDialog,
                          icon: const Icon(Icons.add),
                          label: Text(_isSpanish ? 'Añadir' : 'Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_lessons.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(_isSpanish ? 'No hay lecciones aún.' : 'No lessons yet.'),
                        ),
                      )
                    else
                      ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _lessons.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (ctx, i) {
                          final l = _lessons[i];
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: cs.surface,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: (l['gif'] != null)
                                  ? Image.asset(l['gif'], height: 44)
                                  : const Icon(Icons.school),
                              title: Text(l['title'] ?? ''),
                              subtitle: Text('${(l['type'] ?? 'lesson') == 'game' ? (_isSpanish ? 'Juego' : 'Game') : (_isSpanish ? 'Lección' : 'Lesson')}\n${_formatDT(l['datetime'])}'),
                              isThreeLine: true,
                              trailing: Wrap(spacing: 8, children: [
                                IconButton(
                                  icon: const Icon(Icons.play_arrow),
                                  tooltip: _isSpanish ? 'Abrir' : 'Open',
                                  onPressed: () {
                                    final route = l['route'] as String?;
                                    if (route != null) Navigator.pushNamed(context, route);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_forever),
                                  tooltip: _isSpanish ? 'Eliminar' : 'Delete',
                                  onPressed: () => _deleteLesson(l['id'] as int),
                                ),
                              ]),
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 16),

                    // Tasks Section
                    Row(
                      children: [
                        Image.asset('assets/Robot.gif', height: 28),
                        const SizedBox(width: 8),
                        Text(
                          _isSpanish ? 'Mis tareas' : 'My Tasks',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: _addTaskDialog,
                          icon: const Icon(Icons.add_task),
                          label: Text(_isSpanish ? 'Añadir' : 'Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_tasks.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(_isSpanish ? 'No hay tareas aún.' : 'No tasks yet.'),
                        ),
                      )
                    else
                      ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _tasks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (ctx, i) {
                          final t = _tasks[i];
                          final done = t['done'] == true;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: done ? cs.primaryContainer : cs.surface,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: (t['icon'] != null)
                                  ? Image.asset(t['icon'], height: 40)
                                  : const Icon(Icons.task_alt),
                              title: Text(t['title'] ?? ''),
                              subtitle: Text(_formatDT(t['datetime'])),
                              trailing: Wrap(
                                spacing: 8,
                                children: [
                                  IconButton(
                                    icon: Icon(done ? Icons.check_circle : Icons.radio_button_unchecked),
                                    tooltip: done
                                        ? (_isSpanish ? 'Completado' : 'Completed')
                                        : (_isSpanish ? 'Marcar hecho' : 'Mark done'),
                                    onPressed: () => _toggleTaskDone(t['id'] as int),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.play_arrow),
                                    tooltip: _isSpanish ? 'Abrir' : 'Open',
                                    onPressed: () {
                                      final route = t['route'] as String?;
                                      if (route != null) Navigator.pushNamed(context, route);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_forever),
                                    tooltip: _isSpanish ? 'Eliminar' : 'Delete',
                                    onPressed: () => _deleteTask(t['id'] as int),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 24),
                    Center(child: Image.asset('assets/trophy.png', height: 64)),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        _isSpanish ? '¡Sigue así!' : 'Keep it up!',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addLessonDialog,
        icon: const Icon(Icons.add),
        label: Text(_isSpanish ? 'Nueva lección' : 'New Lesson'),
      ),
    );
  }
}