import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class LocalTasks extends Table {
  TextColumn get id => text()();
  TextColumn get pbId => text().nullable()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get categoryId => text().withDefault(const Constant('all'))();
  IntColumn get baseImportance => integer().withDefault(const Constant(1))();
  IntColumn get effectiveImportance => integer().withDefault(const Constant(1))();
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  BoolColumn get isOverdue => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get ignoredAt => dateTime().nullable()();
  DateTimeColumn get inProgressAt => dateTime().nullable()();
  TextColumn get attachmentPathsJson => text().withDefault(const Constant('[]'))();
  TextColumn get recurrenceRuleId => text().nullable()();
  TextColumn get calendarEventId => text().nullable()();
  TextColumn get emailRefJson => text().nullable()();
  TextColumn get subtasksJson => text().withDefault(const Constant('[]'))();
  TextColumn get givenById => text().nullable()();
  TextColumn get givenByName => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id, userId};
}

class LocalCategories extends Table {
  TextColumn get id => text()();
  TextColumn get pbId => text().nullable()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  IntColumn get colorValue => integer()();
  TextColumn get iconName => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id, userId};
}

class LocalRecurrenceRules extends Table {
  TextColumn get id => text()();
  TextColumn get pbId => text().nullable()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get type => text()();
  IntColumn get intervalValue => integer().withDefault(const Constant(3))();
  TextColumn get intervalUnit => text().withDefault(const Constant('days'))();
  BoolColumn get afterCompletion => boolean().withDefault(const Constant(true))();
  TextColumn get frequency => text().nullable()();
  TextColumn get daysOfWeekJson => text().withDefault(const Constant('[]'))();
  IntColumn get dayOfMonth => integer().nullable()();
  TextColumn get timeOfDay => text().withDefault(const Constant('18:00'))();
  IntColumn get baseImportance => integer().withDefault(const Constant(1))();
  TextColumn get categoryId => text().withDefault(const Constant('all'))();
  DateTimeColumn get lastMissedDueDate => dateTime().nullable()();
  DateTimeColumn get nextDueAt => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id, userId};
}

class LocalProfiles extends Table {
  TextColumn get userId => text()();
  TextColumn get pbId => text().nullable()();
  TextColumn get profileJson => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {userId};
}

class LocalExternalEvents extends Table {
  TextColumn get id => text()();
  TextColumn get pbId => text().nullable()();
  TextColumn get userId => text()();
  TextColumn get externalId => text()();
  TextColumn get source => text()();
  TextColumn get title => text()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime()();
  TextColumn get location => text().withDefault(const Constant(''))();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get meetingUrl => text().nullable()();
  TextColumn get attendeesJson => text().withDefault(const Constant('[]'))();
  BoolColumn get hasLinkedTask => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id, userId};
}

class LocalTaskSuggestions extends Table {
  TextColumn get id => text()();
  TextColumn get pbId => text().nullable()();
  TextColumn get userId => text()();
  TextColumn get emailId => text()();
  TextColumn get sender => text()();
  TextColumn get subject => text()();
  TextColumn get snippet => text()();
  DateTimeColumn get receivedAt => dateTime()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get categoryId => text().withDefault(const Constant('work'))();
  IntColumn get importance => integer().withDefault(const Constant(2))();
  DateTimeColumn get suggestedDueDate => dateTime().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id, userId};
}

class SyncOutbox extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get collectionName => text()();
  TextColumn get recordKey => text()();
  TextColumn get operation => text()(); // 'upsert' | 'delete'
  TextColumn get payloadJson => text()();
  DateTimeColumn get queuedAt => dateTime()();
}

@DriftDatabase(tables: [
  LocalTasks,
  LocalCategories,
  LocalRecurrenceRules,
  LocalProfiles,
  LocalExternalEvents,
  LocalTaskSuggestions,
  SyncOutbox,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(
          executor ??
              driftDatabase(
                name: 'tasker_local_db',
                web: DriftWebOptions(
                  sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                  driftWorker: Uri.parse('drift_worker.js'),
                ),
              ),
        );

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.addColumn(localTasks, localTasks.subtasksJson);
            await m.addColumn(localTasks, localTasks.givenById);
            await m.addColumn(localTasks, localTasks.givenByName);
          }
        },
      );
}
