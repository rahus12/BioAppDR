import 'package:flutter/material.dart';
import 'package:bioappdr/pages/search_index.dart';

class SearchPage extends StatefulWidget {
  final String initialQuery;
  final String initialType; // 'all' | 'lesson' | 'game'
  const SearchPage({super.key, this.initialQuery = '', this.initialType = 'all'});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _controller;
  String _query = '';
  String _type = 'all';

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery;
    _type = widget.initialType;
    _controller = TextEditingController(text: _query);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? filterType = _type == 'all' ? null : _type;
    final List<SearchItem> results = filterSearchItems(_query, type: filterType);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Search lessons or games…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _query = '';
                            _controller.clear();
                          });
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => setState(() => _query = value),
              textInputAction: TextInputAction.search,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _type == 'all',
                  onSelected: (v) => setState(() => _type = 'all'),
                ),
                ChoiceChip(
                  label: const Text('Lessons'),
                  selected: _type == 'lesson',
                  onSelected: (v) => setState(() => _type = 'lesson'),
                ),
                ChoiceChip(
                  label: const Text('Games'),
                  selected: _type == 'game',
                  onSelected: (v) => setState(() => _type = 'game'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: results.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = results[index];
                return ListTile(
                  title: Text(item.title),
                  subtitle: Text(item.type == 'lesson' ? 'Lesson' : 'Game'),
                  leading: const Icon(Icons.arrow_outward),
                  onTap: () {
                    Navigator.pushNamed(context, item.route);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


