// Search index model and helpers

class SearchItem {
  final String title;
  final String route;
  final List<String> keywords;
  final String type; // e.g., 'lesson', 'game'

  const SearchItem({
    required this.title,
    required this.route,
    this.keywords = const [],
    required this.type,
  });
}

/// Central index of searchable destinations.
/// Add new items here to make them discoverable via search and deep links.
const List<SearchItem> searchItems = [
  SearchItem(
    title: 'Human Body Quiz',
    route: '/question',
    keywords: ['quiz', 'mcq', 'body', 'organs', 'test'],
    type: 'game',
  ),
  SearchItem(
    title: 'Organ Word Scramble',
    route: '/wordscramble',
    keywords: ['word', 'scramble', 'anagram', 'organs'],
    type: 'game',
  ),
  SearchItem(
    title: 'Memory Game',
    route: '/memorygame',
    keywords: ['memory', 'cards', 'match', 'organs'],
    type: 'game',
  ),
  SearchItem(
    title: 'Drag drop Quiz',
    route: '/dragdrop',
    keywords: ['drag', 'drop', 'label', 'match'],
    type: 'game',
  ),
  SearchItem(
    title: 'Face Quiz Game',
    route: '/facequizgame',
    keywords: ['face', 'quiz', 'game'],
    type: 'game',
  ),
  SearchItem(
    title: 'Body Parts Connections Game',
    route: '/bodypartsconnections',
    keywords: ['connect', 'pairs', 'organs', 'relations'],
    type: 'game',
  ),
  SearchItem(
    title: 'Body Parts Assembly',
    route: '/bodyassembly',
    keywords: ['assembly', 'puzzle', 'drag'],
    type: 'game',
  ),
  SearchItem(
    title: 'Important parts of the Human Body',
    route: '/lesson',
    keywords: ['lesson', 'body', 'organs', 'learn'],
    type: 'lesson',
  ),
  SearchItem(
    title: 'Important parts of the Face',
    route: '/facelesson',
    keywords: ['lesson', 'face', 'learn'],
    type: 'lesson',
  ),
  SearchItem(
    title: 'Body learning - Speech recognition',
    route: '/learningpage',
    keywords: ['speech', 'voice', 'body', 'learn'],
    type: 'lesson',
  ),
  SearchItem(
    title: 'Face learning - Speech recognition',
    route: '/facelearningpage',
    keywords: ['speech', 'voice', 'face', 'learn'],
    type: 'lesson',
  ),
  SearchItem(
    title: 'Nutrition & Digestion',
    route: '/nutrition',
    keywords: ['food', 'nutrition', 'digestion', 'healthy', 'plate'],
    type: 'lesson',
  ),
];

List<SearchItem> filterSearchItems(String query, {String? type}) {
  final String q = query.trim().toLowerCase();
  Iterable<SearchItem> items = searchItems;
  if (type != null) {
    items = items.where((i) => i.type == type);
  }
  if (q.isEmpty) return items.toList(growable: false);
  return items.where((item) {
    final inTitle = item.title.toLowerCase().contains(q);
    final inKeywords = item.keywords.any((k) => k.toLowerCase().contains(q));
    return inTitle || inKeywords;
  }).toList(growable: false);
}


