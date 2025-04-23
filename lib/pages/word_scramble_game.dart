import 'dart:math';
import 'dart:math' as math show sin, pi;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WordScrambleGameV2 extends StatefulWidget {
  const WordScrambleGameV2({super.key});
  @override
  State<WordScrambleGameV2> createState() => _WordScrambleGameV2State();
}

class _WordScrambleGameV2State extends State<WordScrambleGameV2>
    with SingleTickerProviderStateMixin {
  final List<Map<String, String>> _items = [
    {
      'en': 'HEART',
      'es': 'CORAZÓN',
      'hint_en': 'It pumps blood.',
      'hint_es': 'Bombea la sangre.',
      'img': 'assets/heart.jpeg'
    },
    {
      'en': 'LUNGS',
      'es': 'PULMONES',
      'hint_en': 'They help you breathe.',
      'hint_es': 'Te ayudan a respirar.',
      'img': 'assets/lungs.jpeg'
    },
    {
      'en': 'BRAIN',
      'es': 'CEREBRO',
      'hint_en': 'Body control centre.',
      'hint_es': 'Centro de control del cuerpo.',
      'img': 'assets/brain.jpg'
    },
    {
      'en': 'LIVER',
      'es': 'HÍGADO',
      'hint_en': 'Filters your blood.',
      'hint_es': 'Filtra tu sangre.',
      'img': 'assets/liver.jpeg'
    },
    {
      'en': 'STOMACH',
      'es': 'ESTÓMAGO',
      'hint_en': 'Digests food.',
      'hint_es': 'Digiere la comida.',
      'img': 'assets/stomach.jpeg'
    },
  ];

  int _index = 0;
  bool _spanish = false; // master translation toggle
  late List<String> _pool;
  final List<String> _typed = [];
  late final AnimationController _shake;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _reset();
  }

  void _reset() {
    _typed.clear();
    final word = _items[_index]['en'] ?? '';
    _pool = word.split('')..shuffle(Random());
  }

  void _tap(int i) {
    setState(() {
      _typed.add(_pool[i]);
      _pool[i] = '';
    });
    _verify();
  }

  void _verify() {
    final answer = _items[_index]['en'] ?? '';
    if (_typed.length < answer.length) return;

    final correct = _typed.join() == answer;
    _showSnack(correct);
    if (correct) {
      Future.delayed(const Duration(milliseconds: 600), _next);
    } else {
      _shake.forward(from: 0);
      HapticFeedback.vibrate();
      Future.delayed(const Duration(milliseconds: 600), () => setState(_reset));
    }
  }

  void _next() => setState(() {
    _index = (_index + 1) % _items.length;
    _reset();
  });

  void _shuffleUnused() => setState(() => _pool.shuffle(Random()));

  void _showSnack(bool good) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(good ? (_spanish ? '¡Correcto!' : 'Correct!') : (_spanish ? 'Inténtalo de nuevo' : 'Try again')),
      backgroundColor: good ? Colors.green : Colors.red,
      duration: const Duration(milliseconds: 600),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = _items[_index];
    final progress = (_index + 1) / _items.length;

    final wordEn = item['en'] ?? '';
    final wordEs = item['es'] ?? '';
    final hint = _spanish ? (item['hint_es'] ?? '') : (item['hint_en'] ?? '');
    final imagePath = item['img'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(_spanish ? 'Anagrama' : 'Word Scramble'),
        actions: [
          IconButton(
            tooltip: _spanish ? 'Traducir' : 'Translate',
            icon: const Icon(Icons.translate),
            onPressed: () => setState(() => _spanish = !_spanish),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Text('${_index + 1}/${_items.length}', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimary)),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: progress, color: theme.colorScheme.onPrimary),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: _spanish ? 'Barajar' : 'Shuffle',
        onPressed: _shuffleUnused,
        child: const Icon(Icons.shuffle),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              if (imagePath.isNotEmpty) Image.asset(imagePath, height: 160),
              const SizedBox(height: 12),
              Text('${_spanish ? 'Pista' : 'Hint'}: $hint', style: theme.textTheme.bodyLarge),
              const SizedBox(height: 6),
              Text(
                _spanish ? 'English: $wordEn' : 'Spanish: $wordEs',
                style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              Wrap(
                children: List.generate(wordEn.length, (i) {
                  final char = i < _typed.length ? _typed[i] : '_';
                  return AnimatedBuilder(
                    animation: _shake,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(math.sin(_shake.value * math.pi * 4) * 6, 0),
                      child: child,
                    ),
                    child: _slot(char, filled: i < _typed.length, theme: theme),
                  );
                }),
              ),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                children: List.generate(_pool.length, (i) {
                  final l = _pool[i];
                  return l.isEmpty
                      ? const SizedBox(width: 0)
                      : Padding(
                    padding: const EdgeInsets.all(4),
                    child: ElevatedButton(
                      onPressed: () => _tap(i),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        foregroundColor: theme.colorScheme.onPrimaryContainer,
                        padding: const EdgeInsets.all(16),
                      ),
                      child: Text(l, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _slot(String letter, {required bool filled, required ThemeData theme}) => Container(
    margin: const EdgeInsets.all(4),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: filled ? Colors.green.shade100 : Colors.grey.shade300,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(letter, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
  );

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }
}
