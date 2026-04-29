part of '../database/app_database.dart';

@DriftAccessor(tables: [AppSettings])
class AppSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$AppSettingsDaoMixin {
  AppSettingsDao(super.db);

  Future<String?> readValue(String key) async {
    final row = await (select(
      appSettings,
    )..where((tbl) => tbl.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> writeValue({
    required String key,
    required String? value,
    required DateTime updatedAtUtc,
  }) async {
    await into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(
        key: key,
        value: Value(value),
        updatedAtUtc: updatedAtUtc,
      ),
    );
  }
}
