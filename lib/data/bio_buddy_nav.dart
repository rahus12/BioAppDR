import 'package:flutter/material.dart';

/// Shared Bio Buddy navigation data for floating panel and chat dropdown
class BioBuddyNavItem {
  final String route;
  final String labelEn;
  final String labelEs;
  final String descriptionEn;
  final String descriptionEs;
  final IconData icon;

  const BioBuddyNavItem({
    required this.route,
    required this.labelEn,
    required this.labelEs,
    required this.descriptionEn,
    required this.descriptionEs,
    required this.icon,
  });

  String label(bool isSpanish) => isSpanish ? labelEs : labelEn;
  String description(bool isSpanish) => isSpanish ? descriptionEs : descriptionEn;
}

class BioBuddyNavCategory {
  final String titleEn;
  final String titleEs;
  final MaterialColor color;
  final List<BioBuddyNavItem> items;

  const BioBuddyNavCategory({
    required this.titleEn,
    required this.titleEs,
    required this.color,
    required this.items,
  });

  String title(bool isSpanish) => isSpanish ? titleEs : titleEn;
}

/// Get nav item by route for labels (e.g. in chat navigation chips)
BioBuddyNavItem? getNavItemByRoute(String route) {
  for (final cat in bioBuddyNavCategories) {
    for (final item in cat.items) {
      if (item.route == route) return item;
    }
  }
  return null;
}

/// All Bio Buddy navigation categories and items
const List<BioBuddyNavCategory> bioBuddyNavCategories = [
  BioBuddyNavCategory(
    titleEn: '📚 Lessons',
    titleEs: '📚 Lecciones',
    color: Colors.blue,
    items: [
      BioBuddyNavItem(
        route: '/living_non_living_lesson',
        labelEn: 'Living & Non-Living',
        labelEs: 'Vivo y No Vivo',
        descriptionEn: 'Learn about living things!',
        descriptionEs: '¡Aprende sobre seres vivos!',
        icon: Icons.nature_people,
      ),
      BioBuddyNavItem(
        route: '/lesson',
        labelEn: 'Human Body Parts',
        labelEs: 'Partes del Cuerpo Humano',
        descriptionEn: 'Explore body organs',
        descriptionEs: 'Explora los órganos',
        icon: Icons.accessibility_new,
      ),
      BioBuddyNavItem(
        route: '/facelesson',
        labelEn: 'Face Parts',
        labelEs: 'Partes de la Cara',
        descriptionEn: 'Learn about the face',
        descriptionEs: 'Aprende sobre la cara',
        icon: Icons.face,
      ),
      BioBuddyNavItem(
        route: '/nutrition',
        labelEn: 'Nutrition & Digestion',
        labelEs: 'Nutrición y Digestión',
        descriptionEn: 'How food gives us energy',
        descriptionEs: 'Cómo la comida nos da energía',
        icon: Icons.restaurant,
      ),
    ],
  ),
  BioBuddyNavCategory(
    titleEn: '🎮 Games & Quizzes',
    titleEs: '🎮 Juegos y Cuestionarios',
    color: Colors.green,
    items: [
      BioBuddyNavItem(
        route: '/question',
        labelEn: 'Body Quiz',
        labelEs: 'Cuestionario del Cuerpo',
        descriptionEn: 'Test your knowledge!',
        descriptionEs: '¡Pon a prueba tu conocimiento!',
        icon: Icons.quiz,
      ),
      BioBuddyNavItem(
        route: '/dragdrop',
        labelEn: 'Drag & Drop',
        labelEs: 'Arrastrar y Soltar',
        descriptionEn: 'Match organs to functions',
        descriptionEs: 'Relaciona órganos con funciones',
        icon: Icons.drag_indicator,
      ),
      BioBuddyNavItem(
        route: '/wordscramble',
        labelEn: 'Word Scramble',
        labelEs: 'Revuelve Palabras',
        descriptionEn: 'Unscramble organ names',
        descriptionEs: 'Descifra nombres de órganos',
        icon: Icons.extension,
      ),
      BioBuddyNavItem(
        route: '/memorygame',
        labelEn: 'Memory Game',
        labelEs: 'Juego de Memoria',
        descriptionEn: 'Match the pairs!',
        descriptionEs: '¡Empareja las parejas!',
        icon: Icons.grid_view,
      ),
      BioBuddyNavItem(
        route: '/facequizgame',
        labelEn: 'Face Quiz',
        labelEs: 'Cuestionario de la Cara',
        descriptionEn: 'Name the face parts',
        descriptionEs: 'Nombra las partes de la cara',
        icon: Icons.face_retouching_natural,
      ),
      BioBuddyNavItem(
        route: '/bodypartsconnections',
        labelEn: 'Connections',
        labelEs: 'Conexiones',
        descriptionEn: 'Connect body parts',
        descriptionEs: 'Conecta partes del cuerpo',
        icon: Icons.link,
      ),
      BioBuddyNavItem(
        route: '/bodyassembly',
        labelEn: 'Body Assembly',
        labelEs: 'Ensamblar Cuerpo',
        descriptionEn: 'Build a body!',
        descriptionEs: '¡Construye un cuerpo!',
        icon: Icons.build,
      ),
    ],
  ),
  BioBuddyNavCategory(
    titleEn: '🎤 Interactive Learning',
    titleEs: '🎤 Aprendizaje Interactivo',
    color: Colors.purple,
    items: [
      BioBuddyNavItem(
        route: '/learningpage',
        labelEn: 'Body Learning (Speech)',
        labelEs: 'Cuerpo (Voz)',
        descriptionEn: 'Learn with your voice',
        descriptionEs: 'Aprende con tu voz',
        icon: Icons.record_voice_over,
      ),
      BioBuddyNavItem(
        route: '/facelearningpage',
        labelEn: 'Face Learning (Speech)',
        labelEs: 'Cara (Voz)',
        descriptionEn: 'Say face part names',
        descriptionEs: 'Di nombres de la cara',
        icon: Icons.mic,
      ),
      BioBuddyNavItem(
        route: '/voice_tutor',
        labelEn: 'AI Voice Tutor',
        labelEs: 'Tutor de Voz IA',
        descriptionEn: 'Your personal tutor',
        descriptionEs: 'Tu tutor personal',
        icon: Icons.smart_toy,
      ),
      BioBuddyNavItem(
        route: '/lesson_planner',
        labelEn: 'Planner',
        labelEs: 'Planificador',
        descriptionEn: 'Plan your lessons',
        descriptionEs: 'Planifica tus lecciones',
        icon: Icons.calendar_month,
      ),
      BioBuddyNavItem(
        route: '/evaluator',
        labelEn: 'Evaluator',
        labelEs: 'Evaluador',
        descriptionEn: 'Tutor quality',
        descriptionEs: 'Calidad del tutor',
        icon: Icons.analytics,
      ),
    ],
  ),
];
