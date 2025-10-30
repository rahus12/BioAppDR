import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class NutritionDigestionPage extends StatefulWidget {
  const NutritionDigestionPage({super.key});

  @override
  State<NutritionDigestionPage> createState() => _NutritionDigestionPageState();
}

class _NutritionDigestionPageState extends State<NutritionDigestionPage> {
  final FlutterTts _tts = FlutterTts();
  int _tabIndex = 0;

  final List<_JourneyStep> _journey = const [
    _JourneyStep(title: 'Mouth', emoji: '👄', description: 'Chew, chew! Saliva starts breaking down food.'),
    _JourneyStep(title: 'Esophagus', emoji: '🧩', description: 'A slide that gently pushes food to the stomach.'),
    _JourneyStep(title: 'Stomach', emoji: '🫙', description: 'Food gets mixed into a mush called chyme.'),
    _JourneyStep(title: 'Small Intestine', emoji: '🧵', description: 'Your body takes nutrients into the blood here.'),
    _JourneyStep(title: 'Liver & Pancreas', emoji: '🫀', description: 'They make juices that help digestion.'),
    _JourneyStep(title: 'Large Intestine', emoji: '🧱', description: 'Water returns to the body. Waste is formed.'),
  ];

  final List<_FunFact> _funFacts = const [
    _FunFact(
      text: 'Did you know? Your small intestine is about as long as a school bus!',
      asset: 'assets/Body.png',
    ),
    _FunFact(
      text: 'Your saliva starts digesting starch in the mouth.',
      asset: 'assets/mouth.png',
    ),
    _FunFact(
      text: 'Fiber helps keep your digestion happy and smooth.',
      asset: 'assets/Stomach.png',
    ),
    _FunFact(
      text: 'Water helps form soft stool in the large intestine.',
      asset: 'assets/Kidney.png',
    ),
    _FunFact(
      text: 'Vitamins and minerals are tiny helpers that your body needs daily.',
      asset: 'assets/Brain.png',
    ),
  ];

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    if (text.isNotEmpty) {
      await _tts.speak(text);
    }
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: _tabIndex,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nutrition & Digestion'),
          bottom: TabBar(
            onTap: (i) => setState(() => _tabIndex = i),
            tabs: const [
              Tab(text: 'Nutrients'),
              Tab(text: 'Journey'),
              Tab(text: 'Fun Facts'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.volume_up),
              onPressed: () {
                final text = switch (_tabIndex) {
                  0 => 'Learn nutrients: carbohydrates, proteins, fats, vitamins, minerals, fiber and water, with best sources.',
                  1 => 'Let\'s travel with the food: mouth, esophagus, stomach, intestines! Tap steps to hear more.',
                  _ => 'Fun facts about nutrition and digestion to make you a Digestive Detective!',
                };
                _speak(text);
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _NutrientsTab(onSpeak: _speak),
            _JourneyTab(steps: _journey, onSpeak: _speak),
            _FunFactsTab(facts: _funFacts, onSpeak: _speak),
          ],
        ),
      ),
    );
  }
}

// New UI models
class _JourneyStep {
  final String title;
  final String description;
  final String emoji;
  const _JourneyStep({required this.title, required this.description, required this.emoji});
}

class _PlateOption {
  final String group;
  final String emoji;
  const _PlateOption({required this.group, required this.emoji});
}

class _FunFact {
  final String text;
  final String asset; // path under assets/
  const _FunFact({required this.text, required this.asset});
}

// Journey Tab
class _JourneyTab extends StatefulWidget {
  final List<_JourneyStep> steps;
  final Future<void> Function(String) onSpeak;
  const _JourneyTab({required this.steps, required this.onSpeak});

  @override
  State<_JourneyTab> createState() => _JourneyTabState();
}

class _JourneyTabState extends State<_JourneyTab> {
  // Page content simplified to a single diagram

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: _SimpleDigestiveFlow(steps: widget.steps, onSpeak: widget.onSpeak),
    );
  }
}

// Simple tappable diagram of the digestive system with labeled pins
// (Diagram widget removed; using simple vertical flow now)

// (Old diagram pin widget removed)

// Simple vertical flow: step tiles with arrows between
class _SimpleDigestiveFlow extends StatelessWidget {
  final List<_JourneyStep> steps;
  final Future<void> Function(String) onSpeak;
  const _SimpleDigestiveFlow({required this.steps, required this.onSpeak});

  @override
  Widget build(BuildContext context) {
    const Map<String, String> stepAssets = {
      'Mouth': 'assets/mouth.png',
      'Esophagus': 'assets/Body.png',
      'Stomach': 'assets/Stomach.png',
      'Small Intestine': 'assets/Body.png',
      'Liver & Pancreas': 'assets/liver.jpeg',
      'Large Intestine': 'assets/Body.png',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: (stepAssets[steps[i].title] != null)
                      ? Image.asset(
                          stepAssets[steps[i].title]!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(steps[i].emoji, style: const TextStyle(fontSize: 24)),
                          ),
                        )
                      : Center(child: Text(steps[i].emoji, style: const TextStyle(fontSize: 24))),
                ),
              ),
              title: Text('${i + 1}. ${steps[i].title}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(steps[i].description),
              trailing: IconButton(
                icon: const Icon(Icons.volume_up),
                onPressed: () => onSpeak('${steps[i].title}. ${steps[i].description}'),
              ),
              onTap: () => onSpeak('${steps[i].title}. ${steps[i].description}'),
            ),
          ),
          if (i < steps.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_downward, color: Theme.of(context).colorScheme.primary),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

// Balanced Plate Tab
class _BalancedPlateTab extends StatefulWidget {
  final List<_PlateOption> options;
  final Future<void> Function(String) onSpeak;
  const _BalancedPlateTab({required this.options, required this.onSpeak});

  @override
  State<_BalancedPlateTab> createState() => _BalancedPlateTabState();
}

class _BalancedPlateTabState extends State<_BalancedPlateTab> {
  // Portion targets: 50% plants, 25% grains, 25% protein (+ dairy, water optional)
  double plants = 50;
  double grains = 25;
  double protein = 25;
  bool dairy = false;
  bool water = true;

  void _speakStatus() {
    final d = dairy ? 'with dairy' : 'without dairy';
    final w = water ? 'and water' : 'and no water';
    widget.onSpeak('Plate: $plants percent plants, $grains percent grains, $protein percent protein, $d $w.');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Build a Balanced Plate', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 1.6,
            child: LayoutBuilder(
              builder: (context, c) {
                return Row(
                  children: [
                    Expanded(
                      flex: (plants * 100).round(),
                      child: _PlateSlice(label: 'Plants', emoji: '🥦🍓', color: Colors.green.shade200),
                    ),
                    Expanded(
                      flex: (grains * 100).round(),
                      child: _PlateSlice(label: 'Grains', emoji: '🍚', color: Colors.orange.shade200),
                    ),
                    Expanded(
                      flex: (protein * 100).round(),
                      child: _PlateSlice(label: 'Protein', emoji: '🥚', color: Colors.blue.shade200),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _PlateSlider(label: 'Plants', value: plants, color: Colors.green, onChanged: (v) {
            final double rest = 100 - v;
            final double g = (rest * 0.5).clamp(0, 100 - v).toDouble();
            final double p = (rest - g).toDouble();
            setState(() { plants = v; grains = g; protein = p; });
          }),
          _PlateSlider(label: 'Grains', value: grains, color: Colors.orange, onChanged: (v) {
            final rest = 100 - plants;
            final p = (rest - v).clamp(0, rest);
            setState(() { grains = v; protein = p.toDouble(); });
          }),
          _PlateSlider(label: 'Protein', value: protein, color: Colors.blue, onChanged: (v) {
            final rest = 100 - plants;
            final g = (rest - v).clamp(0, rest);
            setState(() { protein = v; grains = g.toDouble(); });
          }),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Dairy 🥛'),
                selected: dairy,
                onSelected: (s) => setState(() => dairy = s),
              ),
              FilterChip(
                label: const Text('Water 💧'),
                selected: water,
                onSelected: (s) => setState(() => water = s),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(onPressed: _speakStatus, icon: const Icon(Icons.volume_up), label: const Text('Speak Plate')),
              const SizedBox(width: 8),
              Text('${plants.round()}% plants, ${grains.round()}% grains, ${protein.round()}% protein'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlateSlice extends StatelessWidget {
  final String label;
  final String emoji;
  final Color color;
  const _PlateSlice({required this.label, required this.emoji, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _PlateSlider extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final ValueChanged<double> onChanged;
  const _PlateSlider({required this.label, required this.value, required this.color, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 90, child: Text(label)),
        Expanded(
          child: Slider(
            value: value,
            min: 0,
            max: 100,
            divisions: 100,
            label: '${value.round()}%',
            activeColor: color,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

// Fun Facts Tab
class _FunFactsTab extends StatelessWidget {
  final List<_FunFact> facts;
  final Future<void> Function(String) onSpeak;
  const _FunFactsTab({required this.facts, required this.onSpeak});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: facts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final f = facts[i];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 56,
                height: 56,
                child: Image.asset(
                  f.asset,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: Text('Fun Fact ${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(f.text),
            trailing: IconButton(icon: const Icon(Icons.volume_up), onPressed: () => onSpeak(f.text)),
            onTap: () => onSpeak(f.text),
          ),
        );
      },
    );
  }
}

// (Food Types section removed at user's request)

// Nutrients Tab: macro and micro with sources
class _NutrientsTab extends StatelessWidget {
  final Future<void> Function(String) onSpeak;
  const _NutrientsTab({required this.onSpeak});

  @override
  Widget build(BuildContext context) {
    final items = <_NutrientCardData>[
      _NutrientCardData(
        title: 'Carbohydrates',
        emoji: '🍚🍌',
        role: 'Main energy for brain and body.',
        sources: const ['Rice, roti, oats', 'Fruits like banana, apple', 'Starchy veggies like potato'],
      ),
      _NutrientCardData(
        title: 'Protein',
        emoji: '🥚🫘',
        role: 'Builds muscles, enzymes and repairs tissues.',
        sources: const ['Eggs, chicken, fish', 'Dal, beans, tofu', 'Milk, curd, paneer'],
      ),
      _NutrientCardData(
        title: 'Fats',
        emoji: '🥑🥜',
        role: 'Energy reserve; helps absorb vitamins A, D, E, K.',
        sources: const ['Nuts, seeds, peanut butter', 'Ghee/healthy oils', 'Avocado, olives'],
      ),
      _NutrientCardData(
        title: 'Vitamins',
        emoji: '🍊🥕',
        role: 'Tiny helpers for immunity, eyes, skin and growth.',
        sources: const ['Vitamin C: citrus, amla', 'Vitamin A: carrots, spinach', 'Vitamin D: sunshine + dairy'],
      ),
      _NutrientCardData(
        title: 'Minerals',
        emoji: '🧂🥬',
        role: 'Build bones, carry oxygen, keep heart beating.',
        sources: const ['Calcium: milk, curd', 'Iron: spinach, beans', 'Potassium: banana'],
      ),
      _NutrientCardData(
        title: 'Fiber',
        emoji: '🌾🥦',
        role: 'Feeds gut bacteria and keeps poop smooth.',
        sources: const ['Whole grains', 'Fruits and vegetables', 'Beans and lentils'],
      ),
      _NutrientCardData(
        title: 'Water',
        emoji: '💧',
        role: 'Moves nutrients, cools body, helps digestion.',
        sources: const ['Plain water', 'Soups, juicy fruits', 'Milk contributes water too'],
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final n = items[i];
        final speakText = '${n.title}. ${n.role}. Sources include: ${n.sources.join(', ')}';
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Text(n.emoji, style: const TextStyle(fontSize: 28)),
            title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(n.role),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: n.sources.map((s) => Chip(label: Text(s))).toList(),
                )
              ],
            ),
            isThreeLine: true,
            trailing: IconButton(icon: const Icon(Icons.volume_up), onPressed: () => onSpeak(speakText)),
            onTap: () => onSpeak(speakText),
          ),
        );
      },
    );
  }
}

class _NutrientCardData {
  final String title;
  final String emoji;
  final String role;
  final List<String> sources;
  const _NutrientCardData({required this.title, required this.emoji, required this.role, required this.sources});
}

// Feed & Play tab implementation
class FoodItem {
  final String name;
  final String emoji;
  final int carbs; // grams
  final int protein; // grams
  final int fat; // grams
  final int sugar; // grams
  final int fiber; // grams
  final int vitamins; // 0-10
  final int waterMl; // milliliters
  const FoodItem({
    required this.name,
    required this.emoji,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.sugar,
    required this.fiber,
    required this.vitamins,
    required this.waterMl,
  });
}

class FeedAndPlayTab extends StatefulWidget {
  final Future<void> Function(String) onSpeak;
  const FeedAndPlayTab({super.key, required this.onSpeak});

  @override
  State<FeedAndPlayTab> createState() => _FeedAndPlayTabState();
}

class _FeedAndPlayTabState extends State<FeedAndPlayTab> {
  static const List<FoodItem> _foods = [
    FoodItem(name: 'Apple', emoji: '🍎', carbs: 25, protein: 0, fat: 0, sugar: 19, fiber: 4, vitamins: 7, waterMl: 120),
    FoodItem(name: 'Banana', emoji: '🍌', carbs: 27, protein: 1, fat: 0, sugar: 14, fiber: 3, vitamins: 6, waterMl: 100),
    FoodItem(name: 'Carrots', emoji: '🥕', carbs: 10, protein: 1, fat: 0, sugar: 5, fiber: 3, vitamins: 8, waterMl: 60),
    FoodItem(name: 'Bread', emoji: '🍞', carbs: 15, protein: 3, fat: 1, sugar: 2, fiber: 1, vitamins: 2, waterMl: 10),
    FoodItem(name: 'Rice', emoji: '🍚', carbs: 40, protein: 4, fat: 0, sugar: 0, fiber: 1, vitamins: 2, waterMl: 20),
    FoodItem(name: 'Egg', emoji: '🥚', carbs: 1, protein: 6, fat: 5, sugar: 0, fiber: 0, vitamins: 5, waterMl: 5),
    FoodItem(name: 'Chicken', emoji: '🍗', carbs: 0, protein: 20, fat: 5, sugar: 0, fiber: 0, vitamins: 4, waterMl: 10),
    FoodItem(name: 'Milk', emoji: '🥛', carbs: 12, protein: 8, fat: 5, sugar: 12, fiber: 0, vitamins: 6, waterMl: 150),
    FoodItem(name: 'Cheese', emoji: '🧀', carbs: 1, protein: 7, fat: 9, sugar: 1, fiber: 0, vitamins: 4, waterMl: 5),
    FoodItem(name: 'Candy', emoji: '🍬', carbs: 20, protein: 0, fat: 0, sugar: 20, fiber: 0, vitamins: 0, waterMl: 0),
    FoodItem(name: 'Soda', emoji: '🥤', carbs: 39, protein: 0, fat: 0, sugar: 39, fiber: 0, vitamins: 0, waterMl: 0),
    FoodItem(name: 'Water', emoji: '💧', carbs: 0, protein: 0, fat: 0, sugar: 0, fiber: 0, vitamins: 0, waterMl: 200),
  ];

  final List<FoodItem> _meal = [];
  bool _digesting = false;
  double _progress = 0.0;
  String _stage = 'Ready';
  double _energyKcal = 0.0;
  double _hydration = 0.0; // 0-100
  double _healthScore = 0.0; // 0-100

  void _addFood(FoodItem item) {
    if (_meal.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meal is full!')));
      return;
    }
    setState(() => _meal.add(item));
    widget.onSpeak('${item.name} added to your meal.');
  }

  void _clearMeal() {
    setState(() {
      _meal.clear();
      _energyKcal = 0;
      _hydration = 0;
      _healthScore = 0;
      _progress = 0;
      _stage = 'Ready';
    });
  }

  Map<String, int> _totals() {
    int carbs = 0, protein = 0, fat = 0, sugar = 0, fiber = 0, vitamins = 0, waterMl = 0;
    for (final f in _meal) {
      carbs += f.carbs;
      protein += f.protein;
      fat += f.fat;
      sugar += f.sugar;
      fiber += f.fiber;
      vitamins += f.vitamins;
      waterMl += f.waterMl;
    }
    return {
      'carbs': carbs,
      'protein': protein,
      'fat': fat,
      'sugar': sugar,
      'fiber': fiber,
      'vitamins': vitamins,
      'waterMl': waterMl,
    };
  }

  Future<void> _digestMeal() async {
    if (_meal.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add some foods first!')));
      return;
    }
    if (_digesting) return;
    setState(() {
      _digesting = true;
      _progress = 0;
      _stage = 'Mouth: Chew, chew!';
    });
    widget.onSpeak('Chewing starts digestion in the mouth.');
    await Future.delayed(const Duration(milliseconds: 900));
    setState(() {
      _progress = 0.25;
      _stage = 'Stomach: Mix and mash!';
    });
    widget.onSpeak('In the stomach, food mixes with strong juices.');
    await Future.delayed(const Duration(milliseconds: 900));
    setState(() {
      _progress = 0.55;
      _stage = 'Small intestine: Absorb nutrients!';
    });
    widget.onSpeak('In the small intestine, nutrients enter the blood.');
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() {
      _progress = 0.8;
      _stage = 'Large intestine: Take back water!';
    });
    widget.onSpeak('In the large intestine, water is absorbed.');
    await Future.delayed(const Duration(milliseconds: 900));

    final t = _totals();
    final energy = t['carbs']! * 4 + t['protein']! * 4 + t['fat']! * 9;
    final hydration = (t['waterMl']!.clamp(0, 600) / 6).toDouble(); // 0-100
    final vitaminsScore = (t['vitamins']!.clamp(0, 30) / 30) * 100;
    final fiberScore = (t['fiber']!.clamp(0, 15) / 15) * 100;
    final sugarPenalty = (t['sugar']!.clamp(0, 40) / 40) * 100;
    final baseHealth = (vitaminsScore * 0.4 + fiberScore * 0.3 + hydration * 0.3) - sugarPenalty * 0.4;
    final health = baseHealth.clamp(0, 100).toDouble();

    setState(() {
      _energyKcal = energy.toDouble();
      _hydration = hydration.clamp(0, 100).toDouble();
      _healthScore = health.toDouble();
      _progress = 1.0;
      _stage = 'Done!';
      _digesting = false;
    });

    final mood = _healthScore >= 70
        ? 'Fantastic! Your body feels strong and ready!'
        : (_healthScore >= 40
            ? 'Okay! Try adding more colors and water next time.'
            : 'Uh oh! Too much sugar. Add fruits, veggies, and water.');
    widget.onSpeak('Energy ${_energyKcal.round()} calories. Hydration ${_hydration.round()} percent. $mood');
  }

  @override
  Widget build(BuildContext context) {
    final totals = _totals();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Build Your Meal', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _meal
                          .asMap()
                          .entries
                          .map((e) => Chip(
                                label: Text('${e.value.emoji} ${e.value.name}'),
                                onDeleted: () => setState(() => _meal.removeAt(e.key)),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: _digesting ? null : _digestMeal,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Digest'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(onPressed: _digesting ? null : _clearMeal, child: const Text('Clear')),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatBox(title: 'Energy', value: '${_energyKcal.round()} kcal'),
              _StatBox(title: 'Hydration', value: '${_hydration.round()}%'),
              _StatBox(title: 'Health', value: '${_healthScore.round()}%'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(value: _progress),
              const SizedBox(height: 6),
              Text(_stage),
            ],
          ),
        ),
        const Divider(height: 20),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.0,
            ),
            itemCount: _foods.length,
            itemBuilder: (context, i) {
              final f = _foods[i];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _digesting ? null : () => _addFood(f),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(f.emoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 4),
                        Text(f.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MacroPill(label: 'Carbs', value: '${totals['carbs']}g'),
              _MacroPill(label: 'Protein', value: '${totals['protein']}g'),
              _MacroPill(label: 'Fat', value: '${totals['fat']}g'),
              _MacroPill(label: 'Sugar', value: '${totals['sugar']}g'),
              _MacroPill(label: 'Fiber', value: '${totals['fiber']}g'),
              _MacroPill(label: 'Vitamins', value: '${totals['vitamins']}'),
              _MacroPill(label: 'Water', value: '${totals['waterMl']}ml'),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String title;
  final String value;
  const _StatBox({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _MacroPill extends StatelessWidget {
  final String label;
  final String value;
  const _MacroPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label: $value'),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
    );
  }
}


