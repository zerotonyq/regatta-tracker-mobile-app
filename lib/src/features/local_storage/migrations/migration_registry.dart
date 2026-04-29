class MigrationRegistry {
  const MigrationRegistry();

  List<String> get migrationIds => const <String>[
    '001_initial_offline_schema',
    '002_export_jobs_diagnostics_tag',
  ];
}
