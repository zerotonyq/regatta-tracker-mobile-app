# Local Storage Decision

## Chosen Stack

- `drift` as the typed persistence layer
- `SQLite` as the storage engine
- `sqlite3_flutter_libs` for bundled native SQLite on mobile

## Why This Is the Right Long-Term Choice

- Tracking data is relational by nature: sessions, GPS points, IMU chunks, derived metrics, sync jobs, judge actions, export jobs, and settings all have stable foreign-key relationships.
- Offline-first behavior requires transactions, indexes, migrations, and predictable recovery after restart.
- IMU storage needs binary `BLOB` payloads instead of JSON documents. SQLite handles this efficiently and avoids the row explosion that would happen with one row per sample.
- Drift gives compile-time checked queries, generated models, and migration support without giving up raw SQL/SQLite control.
- SQLite is a conservative architectural choice for a production mobile client because it is battle-tested, inspectable, and easy to justify during review or defense.

## Performance Notes

- GPS points are indexed by `(session_id, timestamp_utc)` for append-heavy writes and time-ordered reads.
- IMU samples are stored as 1-second packed binary chunks instead of per-sample rows.
- WAL mode is enabled to improve write concurrency and reduce fsync pressure for background collection.
- `synchronous = NORMAL` and `temp_store = MEMORY` are used to balance durability and write throughput for mobile tracking workloads.

## What We Explicitly Avoided

- No JSON storage for IMU payloads.
- No per-sample IMU rows.
- No key-value or document database as the primary tracking store, because later sync/export/query needs would force expensive refactoring.
