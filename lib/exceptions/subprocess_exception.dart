class SubprocessException implements Exception {
  final String? name;
  final Object? error;

  SubprocessException({this.name, this.error});
}