class TeXException implements Exception {
  /// Internal error name
  final String? name;
  /// The error from the TeX compiler process if available
  final String? error;

  /// Thrown when the TeX compiler fails
  TeXException({this.name, this.error});

  @override
  String toString() => {"name": name, "error": error}.toString();
}