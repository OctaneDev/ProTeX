class Shortcut {
  final String name;
  final String shortCut;
  final String fullValue;
  final Category category;

  Shortcut({required this.name, required this.shortCut, required this.fullValue, required this.category});
}

enum Category {
  general,
  stem,
}