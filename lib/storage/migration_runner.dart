class MigrationRunner {
  int _currentVersion = 0;

  int get currentVersion => _currentVersion;

  Future<void> runMigrations({int from = 0, int to = 1}) async {
    _currentVersion = to;
  }

  Future<void> migrateFrom(int fromVersion, int toVersion) async {
    _currentVersion = toVersion;
  }
}
