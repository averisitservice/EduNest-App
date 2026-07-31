import 'package:flutter/material.dart';

class SubjectIconService {
  static const IconData defaultIcon = Icons.book_rounded;

  static const Map<String, IconData> _icons = {
    'mathematics': Icons.calculate_rounded,
    'science': Icons.science_rounded,
    'english': Icons.menu_book_rounded,
    'hindi': Icons.translate_rounded,
    'social studies': Icons.groups_rounded,
    'computer science': Icons.computer_rounded,
    'physics': Icons.bolt_rounded,
    'chemistry': Icons.biotech_rounded,
    'biology': Icons.eco_rounded,
    'history': Icons.account_balance_rounded,
    'geography': Icons.public_rounded,
    'physical education': Icons.sports_soccer_rounded,
    'social science': Icons.groups_rounded,
    'gujarati': Icons.language_rounded,
    'environmental studies': Icons.park_rounded,
    'sanskrit': Icons.auto_stories_rounded,
    'drawing': Icons.brush_rounded,
    'moral science': Icons.favorite_rounded,
    'civics': Icons.gavel_rounded,
    'economics': Icons.trending_up_rounded,
    'physics (adv)': Icons.bolt_rounded,
    'chemistry (adv)': Icons.biotech_rounded,
    'mathematics (adv)': Icons.calculate_rounded,
    'biology (adv)': Icons.eco_rounded,
    'computer science (adv)': Icons.computer_rounded,
    'accountancy': Icons.account_balance_wallet_rounded,
    'business studies': Icons.business_center_rounded,
    'economics (adv)': Icons.trending_up_rounded,
    'statistics': Icons.bar_chart_rounded,
    'mathematics (com)': Icons.calculate_rounded,
    'history (adv)': Icons.account_balance_rounded,
    'geography (adv)': Icons.public_rounded,
    'civics (adv)': Icons.gavel_rounded,
    'psychology': Icons.psychology_rounded,
    'sociology': Icons.people_alt_rounded,
    'philosophy': Icons.lightbulb_rounded,
    'fine arts': Icons.palette_rounded,
    'music': Icons.music_note_rounded,
    'gujarati (adv)': Icons.language_rounded,
    'english (adv)': Icons.menu_book_rounded,
    'hindi (adv)': Icons.translate_rounded,
  };

  static IconData iconFor(String? subjectName) {
    if (subjectName == null || subjectName.trim().isEmpty) {
      return defaultIcon;
    }
    return _icons[subjectName.trim().toLowerCase()] ?? defaultIcon;
  }
}
