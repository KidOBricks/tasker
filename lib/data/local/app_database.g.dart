// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalTasksTable extends LocalTasks
    with TableInfo<$LocalTasksTable, LocalTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pbIdMeta = const VerificationMeta('pbId');
  @override
  late final GeneratedColumn<String> pbId = GeneratedColumn<String>(
    'pb_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('all'),
  );
  static const VerificationMeta _baseImportanceMeta = const VerificationMeta(
    'baseImportance',
  );
  @override
  late final GeneratedColumn<int> baseImportance = GeneratedColumn<int>(
    'base_importance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _effectiveImportanceMeta =
      const VerificationMeta('effectiveImportance');
  @override
  late final GeneratedColumn<int> effectiveImportance = GeneratedColumn<int>(
    'effective_importance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _isOverdueMeta = const VerificationMeta(
    'isOverdue',
  );
  @override
  late final GeneratedColumn<bool> isOverdue = GeneratedColumn<bool>(
    'is_overdue',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_overdue" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ignoredAtMeta = const VerificationMeta(
    'ignoredAt',
  );
  @override
  late final GeneratedColumn<DateTime> ignoredAt = GeneratedColumn<DateTime>(
    'ignored_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inProgressAtMeta = const VerificationMeta(
    'inProgressAt',
  );
  @override
  late final GeneratedColumn<DateTime> inProgressAt = GeneratedColumn<DateTime>(
    'in_progress_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attachmentPathsJsonMeta =
      const VerificationMeta('attachmentPathsJson');
  @override
  late final GeneratedColumn<String> attachmentPathsJson =
      GeneratedColumn<String>(
        'attachment_paths_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _recurrenceRuleIdMeta = const VerificationMeta(
    'recurrenceRuleId',
  );
  @override
  late final GeneratedColumn<String> recurrenceRuleId = GeneratedColumn<String>(
    'recurrence_rule_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _calendarEventIdMeta = const VerificationMeta(
    'calendarEventId',
  );
  @override
  late final GeneratedColumn<String> calendarEventId = GeneratedColumn<String>(
    'calendar_event_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailRefJsonMeta = const VerificationMeta(
    'emailRefJson',
  );
  @override
  late final GeneratedColumn<String> emailRefJson = GeneratedColumn<String>(
    'email_ref_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subtasksJsonMeta = const VerificationMeta(
    'subtasksJson',
  );
  @override
  late final GeneratedColumn<String> subtasksJson = GeneratedColumn<String>(
    'subtasks_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _givenByIdMeta = const VerificationMeta(
    'givenById',
  );
  @override
  late final GeneratedColumn<String> givenById = GeneratedColumn<String>(
    'given_by_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _givenByNameMeta = const VerificationMeta(
    'givenByName',
  );
  @override
  late final GeneratedColumn<String> givenByName = GeneratedColumn<String>(
    'given_by_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pbId,
    userId,
    title,
    description,
    categoryId,
    baseImportance,
    effectiveImportance,
    dueDate,
    status,
    isOverdue,
    createdAt,
    completedAt,
    ignoredAt,
    inProgressAt,
    attachmentPathsJson,
    recurrenceRuleId,
    calendarEventId,
    emailRefJson,
    subtasksJson,
    givenById,
    givenByName,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalTask> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('pb_id')) {
      context.handle(
        _pbIdMeta,
        pbId.isAcceptableOrUnknown(data['pb_id']!, _pbIdMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('base_importance')) {
      context.handle(
        _baseImportanceMeta,
        baseImportance.isAcceptableOrUnknown(
          data['base_importance']!,
          _baseImportanceMeta,
        ),
      );
    }
    if (data.containsKey('effective_importance')) {
      context.handle(
        _effectiveImportanceMeta,
        effectiveImportance.isAcceptableOrUnknown(
          data['effective_importance']!,
          _effectiveImportanceMeta,
        ),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('is_overdue')) {
      context.handle(
        _isOverdueMeta,
        isOverdue.isAcceptableOrUnknown(data['is_overdue']!, _isOverdueMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('ignored_at')) {
      context.handle(
        _ignoredAtMeta,
        ignoredAt.isAcceptableOrUnknown(data['ignored_at']!, _ignoredAtMeta),
      );
    }
    if (data.containsKey('in_progress_at')) {
      context.handle(
        _inProgressAtMeta,
        inProgressAt.isAcceptableOrUnknown(
          data['in_progress_at']!,
          _inProgressAtMeta,
        ),
      );
    }
    if (data.containsKey('attachment_paths_json')) {
      context.handle(
        _attachmentPathsJsonMeta,
        attachmentPathsJson.isAcceptableOrUnknown(
          data['attachment_paths_json']!,
          _attachmentPathsJsonMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_rule_id')) {
      context.handle(
        _recurrenceRuleIdMeta,
        recurrenceRuleId.isAcceptableOrUnknown(
          data['recurrence_rule_id']!,
          _recurrenceRuleIdMeta,
        ),
      );
    }
    if (data.containsKey('calendar_event_id')) {
      context.handle(
        _calendarEventIdMeta,
        calendarEventId.isAcceptableOrUnknown(
          data['calendar_event_id']!,
          _calendarEventIdMeta,
        ),
      );
    }
    if (data.containsKey('email_ref_json')) {
      context.handle(
        _emailRefJsonMeta,
        emailRefJson.isAcceptableOrUnknown(
          data['email_ref_json']!,
          _emailRefJsonMeta,
        ),
      );
    }
    if (data.containsKey('subtasks_json')) {
      context.handle(
        _subtasksJsonMeta,
        subtasksJson.isAcceptableOrUnknown(
          data['subtasks_json']!,
          _subtasksJsonMeta,
        ),
      );
    }
    if (data.containsKey('given_by_id')) {
      context.handle(
        _givenByIdMeta,
        givenById.isAcceptableOrUnknown(data['given_by_id']!, _givenByIdMeta),
      );
    }
    if (data.containsKey('given_by_name')) {
      context.handle(
        _givenByNameMeta,
        givenByName.isAcceptableOrUnknown(
          data['given_by_name']!,
          _givenByNameMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id, userId};
  @override
  LocalTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTask(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      pbId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pb_id'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      baseImportance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_importance'],
      )!,
      effectiveImportance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}effective_importance'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      isOverdue: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_overdue'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      ignoredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ignored_at'],
      ),
      inProgressAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}in_progress_at'],
      ),
      attachmentPathsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attachment_paths_json'],
      )!,
      recurrenceRuleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_rule_id'],
      ),
      calendarEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calendar_event_id'],
      ),
      emailRefJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email_ref_json'],
      ),
      subtasksJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtasks_json'],
      )!,
      givenById: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}given_by_id'],
      ),
      givenByName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}given_by_name'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $LocalTasksTable createAlias(String alias) {
    return $LocalTasksTable(attachedDatabase, alias);
  }
}

class LocalTask extends DataClass implements Insertable<LocalTask> {
  final String id;
  final String? pbId;
  final String userId;
  final String title;
  final String? description;
  final String categoryId;
  final int baseImportance;
  final int effectiveImportance;
  final DateTime? dueDate;
  final String status;
  final bool isOverdue;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? ignoredAt;
  final DateTime? inProgressAt;
  final String attachmentPathsJson;
  final String? recurrenceRuleId;
  final String? calendarEventId;
  final String? emailRefJson;
  final String subtasksJson;
  final String? givenById;
  final String? givenByName;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const LocalTask({
    required this.id,
    this.pbId,
    required this.userId,
    required this.title,
    this.description,
    required this.categoryId,
    required this.baseImportance,
    required this.effectiveImportance,
    this.dueDate,
    required this.status,
    required this.isOverdue,
    required this.createdAt,
    this.completedAt,
    this.ignoredAt,
    this.inProgressAt,
    required this.attachmentPathsJson,
    this.recurrenceRuleId,
    this.calendarEventId,
    this.emailRefJson,
    required this.subtasksJson,
    this.givenById,
    this.givenByName,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || pbId != null) {
      map['pb_id'] = Variable<String>(pbId);
    }
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['category_id'] = Variable<String>(categoryId);
    map['base_importance'] = Variable<int>(baseImportance);
    map['effective_importance'] = Variable<int>(effectiveImportance);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['status'] = Variable<String>(status);
    map['is_overdue'] = Variable<bool>(isOverdue);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || ignoredAt != null) {
      map['ignored_at'] = Variable<DateTime>(ignoredAt);
    }
    if (!nullToAbsent || inProgressAt != null) {
      map['in_progress_at'] = Variable<DateTime>(inProgressAt);
    }
    map['attachment_paths_json'] = Variable<String>(attachmentPathsJson);
    if (!nullToAbsent || recurrenceRuleId != null) {
      map['recurrence_rule_id'] = Variable<String>(recurrenceRuleId);
    }
    if (!nullToAbsent || calendarEventId != null) {
      map['calendar_event_id'] = Variable<String>(calendarEventId);
    }
    if (!nullToAbsent || emailRefJson != null) {
      map['email_ref_json'] = Variable<String>(emailRefJson);
    }
    map['subtasks_json'] = Variable<String>(subtasksJson);
    if (!nullToAbsent || givenById != null) {
      map['given_by_id'] = Variable<String>(givenById);
    }
    if (!nullToAbsent || givenByName != null) {
      map['given_by_name'] = Variable<String>(givenByName);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  LocalTasksCompanion toCompanion(bool nullToAbsent) {
    return LocalTasksCompanion(
      id: Value(id),
      pbId: pbId == null && nullToAbsent ? const Value.absent() : Value(pbId),
      userId: Value(userId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      categoryId: Value(categoryId),
      baseImportance: Value(baseImportance),
      effectiveImportance: Value(effectiveImportance),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      status: Value(status),
      isOverdue: Value(isOverdue),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      ignoredAt: ignoredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(ignoredAt),
      inProgressAt: inProgressAt == null && nullToAbsent
          ? const Value.absent()
          : Value(inProgressAt),
      attachmentPathsJson: Value(attachmentPathsJson),
      recurrenceRuleId: recurrenceRuleId == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceRuleId),
      calendarEventId: calendarEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(calendarEventId),
      emailRefJson: emailRefJson == null && nullToAbsent
          ? const Value.absent()
          : Value(emailRefJson),
      subtasksJson: Value(subtasksJson),
      givenById: givenById == null && nullToAbsent
          ? const Value.absent()
          : Value(givenById),
      givenByName: givenByName == null && nullToAbsent
          ? const Value.absent()
          : Value(givenByName),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory LocalTask.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTask(
      id: serializer.fromJson<String>(json['id']),
      pbId: serializer.fromJson<String?>(json['pbId']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      baseImportance: serializer.fromJson<int>(json['baseImportance']),
      effectiveImportance: serializer.fromJson<int>(
        json['effectiveImportance'],
      ),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      status: serializer.fromJson<String>(json['status']),
      isOverdue: serializer.fromJson<bool>(json['isOverdue']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      ignoredAt: serializer.fromJson<DateTime?>(json['ignoredAt']),
      inProgressAt: serializer.fromJson<DateTime?>(json['inProgressAt']),
      attachmentPathsJson: serializer.fromJson<String>(
        json['attachmentPathsJson'],
      ),
      recurrenceRuleId: serializer.fromJson<String?>(json['recurrenceRuleId']),
      calendarEventId: serializer.fromJson<String?>(json['calendarEventId']),
      emailRefJson: serializer.fromJson<String?>(json['emailRefJson']),
      subtasksJson: serializer.fromJson<String>(json['subtasksJson']),
      givenById: serializer.fromJson<String?>(json['givenById']),
      givenByName: serializer.fromJson<String?>(json['givenByName']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'pbId': serializer.toJson<String?>(pbId),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'categoryId': serializer.toJson<String>(categoryId),
      'baseImportance': serializer.toJson<int>(baseImportance),
      'effectiveImportance': serializer.toJson<int>(effectiveImportance),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'status': serializer.toJson<String>(status),
      'isOverdue': serializer.toJson<bool>(isOverdue),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'ignoredAt': serializer.toJson<DateTime?>(ignoredAt),
      'inProgressAt': serializer.toJson<DateTime?>(inProgressAt),
      'attachmentPathsJson': serializer.toJson<String>(attachmentPathsJson),
      'recurrenceRuleId': serializer.toJson<String?>(recurrenceRuleId),
      'calendarEventId': serializer.toJson<String?>(calendarEventId),
      'emailRefJson': serializer.toJson<String?>(emailRefJson),
      'subtasksJson': serializer.toJson<String>(subtasksJson),
      'givenById': serializer.toJson<String?>(givenById),
      'givenByName': serializer.toJson<String?>(givenByName),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  LocalTask copyWith({
    String? id,
    Value<String?> pbId = const Value.absent(),
    String? userId,
    String? title,
    Value<String?> description = const Value.absent(),
    String? categoryId,
    int? baseImportance,
    int? effectiveImportance,
    Value<DateTime?> dueDate = const Value.absent(),
    String? status,
    bool? isOverdue,
    DateTime? createdAt,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<DateTime?> ignoredAt = const Value.absent(),
    Value<DateTime?> inProgressAt = const Value.absent(),
    String? attachmentPathsJson,
    Value<String?> recurrenceRuleId = const Value.absent(),
    Value<String?> calendarEventId = const Value.absent(),
    Value<String?> emailRefJson = const Value.absent(),
    String? subtasksJson,
    Value<String?> givenById = const Value.absent(),
    Value<String?> givenByName = const Value.absent(),
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => LocalTask(
    id: id ?? this.id,
    pbId: pbId.present ? pbId.value : this.pbId,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    categoryId: categoryId ?? this.categoryId,
    baseImportance: baseImportance ?? this.baseImportance,
    effectiveImportance: effectiveImportance ?? this.effectiveImportance,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    status: status ?? this.status,
    isOverdue: isOverdue ?? this.isOverdue,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    ignoredAt: ignoredAt.present ? ignoredAt.value : this.ignoredAt,
    inProgressAt: inProgressAt.present ? inProgressAt.value : this.inProgressAt,
    attachmentPathsJson: attachmentPathsJson ?? this.attachmentPathsJson,
    recurrenceRuleId: recurrenceRuleId.present
        ? recurrenceRuleId.value
        : this.recurrenceRuleId,
    calendarEventId: calendarEventId.present
        ? calendarEventId.value
        : this.calendarEventId,
    emailRefJson: emailRefJson.present ? emailRefJson.value : this.emailRefJson,
    subtasksJson: subtasksJson ?? this.subtasksJson,
    givenById: givenById.present ? givenById.value : this.givenById,
    givenByName: givenByName.present ? givenByName.value : this.givenByName,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  LocalTask copyWithCompanion(LocalTasksCompanion data) {
    return LocalTask(
      id: data.id.present ? data.id.value : this.id,
      pbId: data.pbId.present ? data.pbId.value : this.pbId,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      baseImportance: data.baseImportance.present
          ? data.baseImportance.value
          : this.baseImportance,
      effectiveImportance: data.effectiveImportance.present
          ? data.effectiveImportance.value
          : this.effectiveImportance,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      status: data.status.present ? data.status.value : this.status,
      isOverdue: data.isOverdue.present ? data.isOverdue.value : this.isOverdue,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      ignoredAt: data.ignoredAt.present ? data.ignoredAt.value : this.ignoredAt,
      inProgressAt: data.inProgressAt.present
          ? data.inProgressAt.value
          : this.inProgressAt,
      attachmentPathsJson: data.attachmentPathsJson.present
          ? data.attachmentPathsJson.value
          : this.attachmentPathsJson,
      recurrenceRuleId: data.recurrenceRuleId.present
          ? data.recurrenceRuleId.value
          : this.recurrenceRuleId,
      calendarEventId: data.calendarEventId.present
          ? data.calendarEventId.value
          : this.calendarEventId,
      emailRefJson: data.emailRefJson.present
          ? data.emailRefJson.value
          : this.emailRefJson,
      subtasksJson: data.subtasksJson.present
          ? data.subtasksJson.value
          : this.subtasksJson,
      givenById: data.givenById.present ? data.givenById.value : this.givenById,
      givenByName: data.givenByName.present
          ? data.givenByName.value
          : this.givenByName,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTask(')
          ..write('id: $id, ')
          ..write('pbId: $pbId, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('categoryId: $categoryId, ')
          ..write('baseImportance: $baseImportance, ')
          ..write('effectiveImportance: $effectiveImportance, ')
          ..write('dueDate: $dueDate, ')
          ..write('status: $status, ')
          ..write('isOverdue: $isOverdue, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('ignoredAt: $ignoredAt, ')
          ..write('inProgressAt: $inProgressAt, ')
          ..write('attachmentPathsJson: $attachmentPathsJson, ')
          ..write('recurrenceRuleId: $recurrenceRuleId, ')
          ..write('calendarEventId: $calendarEventId, ')
          ..write('emailRefJson: $emailRefJson, ')
          ..write('subtasksJson: $subtasksJson, ')
          ..write('givenById: $givenById, ')
          ..write('givenByName: $givenByName, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    pbId,
    userId,
    title,
    description,
    categoryId,
    baseImportance,
    effectiveImportance,
    dueDate,
    status,
    isOverdue,
    createdAt,
    completedAt,
    ignoredAt,
    inProgressAt,
    attachmentPathsJson,
    recurrenceRuleId,
    calendarEventId,
    emailRefJson,
    subtasksJson,
    givenById,
    givenByName,
    updatedAt,
    deletedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTask &&
          other.id == this.id &&
          other.pbId == this.pbId &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.description == this.description &&
          other.categoryId == this.categoryId &&
          other.baseImportance == this.baseImportance &&
          other.effectiveImportance == this.effectiveImportance &&
          other.dueDate == this.dueDate &&
          other.status == this.status &&
          other.isOverdue == this.isOverdue &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt &&
          other.ignoredAt == this.ignoredAt &&
          other.inProgressAt == this.inProgressAt &&
          other.attachmentPathsJson == this.attachmentPathsJson &&
          other.recurrenceRuleId == this.recurrenceRuleId &&
          other.calendarEventId == this.calendarEventId &&
          other.emailRefJson == this.emailRefJson &&
          other.subtasksJson == this.subtasksJson &&
          other.givenById == this.givenById &&
          other.givenByName == this.givenByName &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class LocalTasksCompanion extends UpdateCompanion<LocalTask> {
  final Value<String> id;
  final Value<String?> pbId;
  final Value<String> userId;
  final Value<String> title;
  final Value<String?> description;
  final Value<String> categoryId;
  final Value<int> baseImportance;
  final Value<int> effectiveImportance;
  final Value<DateTime?> dueDate;
  final Value<String> status;
  final Value<bool> isOverdue;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  final Value<DateTime?> ignoredAt;
  final Value<DateTime?> inProgressAt;
  final Value<String> attachmentPathsJson;
  final Value<String?> recurrenceRuleId;
  final Value<String?> calendarEventId;
  final Value<String?> emailRefJson;
  final Value<String> subtasksJson;
  final Value<String?> givenById;
  final Value<String?> givenByName;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const LocalTasksCompanion({
    this.id = const Value.absent(),
    this.pbId = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.baseImportance = const Value.absent(),
    this.effectiveImportance = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.status = const Value.absent(),
    this.isOverdue = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.ignoredAt = const Value.absent(),
    this.inProgressAt = const Value.absent(),
    this.attachmentPathsJson = const Value.absent(),
    this.recurrenceRuleId = const Value.absent(),
    this.calendarEventId = const Value.absent(),
    this.emailRefJson = const Value.absent(),
    this.subtasksJson = const Value.absent(),
    this.givenById = const Value.absent(),
    this.givenByName = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalTasksCompanion.insert({
    required String id,
    this.pbId = const Value.absent(),
    required String userId,
    required String title,
    this.description = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.baseImportance = const Value.absent(),
    this.effectiveImportance = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.status = const Value.absent(),
    this.isOverdue = const Value.absent(),
    required DateTime createdAt,
    this.completedAt = const Value.absent(),
    this.ignoredAt = const Value.absent(),
    this.inProgressAt = const Value.absent(),
    this.attachmentPathsJson = const Value.absent(),
    this.recurrenceRuleId = const Value.absent(),
    this.calendarEventId = const Value.absent(),
    this.emailRefJson = const Value.absent(),
    this.subtasksJson = const Value.absent(),
    this.givenById = const Value.absent(),
    this.givenByName = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalTask> custom({
    Expression<String>? id,
    Expression<String>? pbId,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? categoryId,
    Expression<int>? baseImportance,
    Expression<int>? effectiveImportance,
    Expression<DateTime>? dueDate,
    Expression<String>? status,
    Expression<bool>? isOverdue,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? ignoredAt,
    Expression<DateTime>? inProgressAt,
    Expression<String>? attachmentPathsJson,
    Expression<String>? recurrenceRuleId,
    Expression<String>? calendarEventId,
    Expression<String>? emailRefJson,
    Expression<String>? subtasksJson,
    Expression<String>? givenById,
    Expression<String>? givenByName,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pbId != null) 'pb_id': pbId,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (categoryId != null) 'category_id': categoryId,
      if (baseImportance != null) 'base_importance': baseImportance,
      if (effectiveImportance != null)
        'effective_importance': effectiveImportance,
      if (dueDate != null) 'due_date': dueDate,
      if (status != null) 'status': status,
      if (isOverdue != null) 'is_overdue': isOverdue,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (ignoredAt != null) 'ignored_at': ignoredAt,
      if (inProgressAt != null) 'in_progress_at': inProgressAt,
      if (attachmentPathsJson != null)
        'attachment_paths_json': attachmentPathsJson,
      if (recurrenceRuleId != null) 'recurrence_rule_id': recurrenceRuleId,
      if (calendarEventId != null) 'calendar_event_id': calendarEventId,
      if (emailRefJson != null) 'email_ref_json': emailRefJson,
      if (subtasksJson != null) 'subtasks_json': subtasksJson,
      if (givenById != null) 'given_by_id': givenById,
      if (givenByName != null) 'given_by_name': givenByName,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalTasksCompanion copyWith({
    Value<String>? id,
    Value<String?>? pbId,
    Value<String>? userId,
    Value<String>? title,
    Value<String?>? description,
    Value<String>? categoryId,
    Value<int>? baseImportance,
    Value<int>? effectiveImportance,
    Value<DateTime?>? dueDate,
    Value<String>? status,
    Value<bool>? isOverdue,
    Value<DateTime>? createdAt,
    Value<DateTime?>? completedAt,
    Value<DateTime?>? ignoredAt,
    Value<DateTime?>? inProgressAt,
    Value<String>? attachmentPathsJson,
    Value<String?>? recurrenceRuleId,
    Value<String?>? calendarEventId,
    Value<String?>? emailRefJson,
    Value<String>? subtasksJson,
    Value<String?>? givenById,
    Value<String?>? givenByName,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return LocalTasksCompanion(
      id: id ?? this.id,
      pbId: pbId ?? this.pbId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      baseImportance: baseImportance ?? this.baseImportance,
      effectiveImportance: effectiveImportance ?? this.effectiveImportance,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      isOverdue: isOverdue ?? this.isOverdue,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      ignoredAt: ignoredAt ?? this.ignoredAt,
      inProgressAt: inProgressAt ?? this.inProgressAt,
      attachmentPathsJson: attachmentPathsJson ?? this.attachmentPathsJson,
      recurrenceRuleId: recurrenceRuleId ?? this.recurrenceRuleId,
      calendarEventId: calendarEventId ?? this.calendarEventId,
      emailRefJson: emailRefJson ?? this.emailRefJson,
      subtasksJson: subtasksJson ?? this.subtasksJson,
      givenById: givenById ?? this.givenById,
      givenByName: givenByName ?? this.givenByName,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (pbId.present) {
      map['pb_id'] = Variable<String>(pbId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (baseImportance.present) {
      map['base_importance'] = Variable<int>(baseImportance.value);
    }
    if (effectiveImportance.present) {
      map['effective_importance'] = Variable<int>(effectiveImportance.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (isOverdue.present) {
      map['is_overdue'] = Variable<bool>(isOverdue.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (ignoredAt.present) {
      map['ignored_at'] = Variable<DateTime>(ignoredAt.value);
    }
    if (inProgressAt.present) {
      map['in_progress_at'] = Variable<DateTime>(inProgressAt.value);
    }
    if (attachmentPathsJson.present) {
      map['attachment_paths_json'] = Variable<String>(
        attachmentPathsJson.value,
      );
    }
    if (recurrenceRuleId.present) {
      map['recurrence_rule_id'] = Variable<String>(recurrenceRuleId.value);
    }
    if (calendarEventId.present) {
      map['calendar_event_id'] = Variable<String>(calendarEventId.value);
    }
    if (emailRefJson.present) {
      map['email_ref_json'] = Variable<String>(emailRefJson.value);
    }
    if (subtasksJson.present) {
      map['subtasks_json'] = Variable<String>(subtasksJson.value);
    }
    if (givenById.present) {
      map['given_by_id'] = Variable<String>(givenById.value);
    }
    if (givenByName.present) {
      map['given_by_name'] = Variable<String>(givenByName.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalTasksCompanion(')
          ..write('id: $id, ')
          ..write('pbId: $pbId, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('categoryId: $categoryId, ')
          ..write('baseImportance: $baseImportance, ')
          ..write('effectiveImportance: $effectiveImportance, ')
          ..write('dueDate: $dueDate, ')
          ..write('status: $status, ')
          ..write('isOverdue: $isOverdue, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('ignoredAt: $ignoredAt, ')
          ..write('inProgressAt: $inProgressAt, ')
          ..write('attachmentPathsJson: $attachmentPathsJson, ')
          ..write('recurrenceRuleId: $recurrenceRuleId, ')
          ..write('calendarEventId: $calendarEventId, ')
          ..write('emailRefJson: $emailRefJson, ')
          ..write('subtasksJson: $subtasksJson, ')
          ..write('givenById: $givenById, ')
          ..write('givenByName: $givenByName, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalCategoriesTable extends LocalCategories
    with TableInfo<$LocalCategoriesTable, LocalCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pbIdMeta = const VerificationMeta('pbId');
  @override
  late final GeneratedColumn<String> pbId = GeneratedColumn<String>(
    'pb_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconNameMeta = const VerificationMeta(
    'iconName',
  );
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
    'icon_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pbId,
    userId,
    name,
    colorValue,
    iconName,
    sortOrder,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('pb_id')) {
      context.handle(
        _pbIdMeta,
        pbId.isAcceptableOrUnknown(data['pb_id']!, _pbIdMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('icon_name')) {
      context.handle(
        _iconNameMeta,
        iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta),
      );
    } else if (isInserting) {
      context.missing(_iconNameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id, userId};
  @override
  LocalCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      pbId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pb_id'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      )!,
      iconName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $LocalCategoriesTable createAlias(String alias) {
    return $LocalCategoriesTable(attachedDatabase, alias);
  }
}

class LocalCategory extends DataClass implements Insertable<LocalCategory> {
  final String id;
  final String? pbId;
  final String userId;
  final String name;
  final int colorValue;
  final String iconName;
  final int sortOrder;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const LocalCategory({
    required this.id,
    this.pbId,
    required this.userId,
    required this.name,
    required this.colorValue,
    required this.iconName,
    required this.sortOrder,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || pbId != null) {
      map['pb_id'] = Variable<String>(pbId);
    }
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['color_value'] = Variable<int>(colorValue);
    map['icon_name'] = Variable<String>(iconName);
    map['sort_order'] = Variable<int>(sortOrder);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  LocalCategoriesCompanion toCompanion(bool nullToAbsent) {
    return LocalCategoriesCompanion(
      id: Value(id),
      pbId: pbId == null && nullToAbsent ? const Value.absent() : Value(pbId),
      userId: Value(userId),
      name: Value(name),
      colorValue: Value(colorValue),
      iconName: Value(iconName),
      sortOrder: Value(sortOrder),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory LocalCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCategory(
      id: serializer.fromJson<String>(json['id']),
      pbId: serializer.fromJson<String?>(json['pbId']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      iconName: serializer.fromJson<String>(json['iconName']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'pbId': serializer.toJson<String?>(pbId),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'colorValue': serializer.toJson<int>(colorValue),
      'iconName': serializer.toJson<String>(iconName),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  LocalCategory copyWith({
    String? id,
    Value<String?> pbId = const Value.absent(),
    String? userId,
    String? name,
    int? colorValue,
    String? iconName,
    int? sortOrder,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => LocalCategory(
    id: id ?? this.id,
    pbId: pbId.present ? pbId.value : this.pbId,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    colorValue: colorValue ?? this.colorValue,
    iconName: iconName ?? this.iconName,
    sortOrder: sortOrder ?? this.sortOrder,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  LocalCategory copyWithCompanion(LocalCategoriesCompanion data) {
    return LocalCategory(
      id: data.id.present ? data.id.value : this.id,
      pbId: data.pbId.present ? data.pbId.value : this.pbId,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCategory(')
          ..write('id: $id, ')
          ..write('pbId: $pbId, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('colorValue: $colorValue, ')
          ..write('iconName: $iconName, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pbId,
    userId,
    name,
    colorValue,
    iconName,
    sortOrder,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCategory &&
          other.id == this.id &&
          other.pbId == this.pbId &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.colorValue == this.colorValue &&
          other.iconName == this.iconName &&
          other.sortOrder == this.sortOrder &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class LocalCategoriesCompanion extends UpdateCompanion<LocalCategory> {
  final Value<String> id;
  final Value<String?> pbId;
  final Value<String> userId;
  final Value<String> name;
  final Value<int> colorValue;
  final Value<String> iconName;
  final Value<int> sortOrder;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const LocalCategoriesCompanion({
    this.id = const Value.absent(),
    this.pbId = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.iconName = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalCategoriesCompanion.insert({
    required String id,
    this.pbId = const Value.absent(),
    required String userId,
    required String name,
    required int colorValue,
    required String iconName,
    this.sortOrder = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       name = Value(name),
       colorValue = Value(colorValue),
       iconName = Value(iconName),
       updatedAt = Value(updatedAt);
  static Insertable<LocalCategory> custom({
    Expression<String>? id,
    Expression<String>? pbId,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<int>? colorValue,
    Expression<String>? iconName,
    Expression<int>? sortOrder,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pbId != null) 'pb_id': pbId,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (colorValue != null) 'color_value': colorValue,
      if (iconName != null) 'icon_name': iconName,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalCategoriesCompanion copyWith({
    Value<String>? id,
    Value<String?>? pbId,
    Value<String>? userId,
    Value<String>? name,
    Value<int>? colorValue,
    Value<String>? iconName,
    Value<int>? sortOrder,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return LocalCategoriesCompanion(
      id: id ?? this.id,
      pbId: pbId ?? this.pbId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      iconName: iconName ?? this.iconName,
      sortOrder: sortOrder ?? this.sortOrder,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (pbId.present) {
      map['pb_id'] = Variable<String>(pbId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('pbId: $pbId, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('colorValue: $colorValue, ')
          ..write('iconName: $iconName, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalRecurrenceRulesTable extends LocalRecurrenceRules
    with TableInfo<$LocalRecurrenceRulesTable, LocalRecurrenceRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalRecurrenceRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pbIdMeta = const VerificationMeta('pbId');
  @override
  late final GeneratedColumn<String> pbId = GeneratedColumn<String>(
    'pb_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intervalValueMeta = const VerificationMeta(
    'intervalValue',
  );
  @override
  late final GeneratedColumn<int> intervalValue = GeneratedColumn<int>(
    'interval_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _intervalUnitMeta = const VerificationMeta(
    'intervalUnit',
  );
  @override
  late final GeneratedColumn<String> intervalUnit = GeneratedColumn<String>(
    'interval_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('days'),
  );
  static const VerificationMeta _afterCompletionMeta = const VerificationMeta(
    'afterCompletion',
  );
  @override
  late final GeneratedColumn<bool> afterCompletion = GeneratedColumn<bool>(
    'after_completion',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("after_completion" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _daysOfWeekJsonMeta = const VerificationMeta(
    'daysOfWeekJson',
  );
  @override
  late final GeneratedColumn<String> daysOfWeekJson = GeneratedColumn<String>(
    'days_of_week_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _dayOfMonthMeta = const VerificationMeta(
    'dayOfMonth',
  );
  @override
  late final GeneratedColumn<int> dayOfMonth = GeneratedColumn<int>(
    'day_of_month',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeOfDayMeta = const VerificationMeta(
    'timeOfDay',
  );
  @override
  late final GeneratedColumn<String> timeOfDay = GeneratedColumn<String>(
    'time_of_day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('18:00'),
  );
  static const VerificationMeta _baseImportanceMeta = const VerificationMeta(
    'baseImportance',
  );
  @override
  late final GeneratedColumn<int> baseImportance = GeneratedColumn<int>(
    'base_importance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('all'),
  );
  static const VerificationMeta _lastMissedDueDateMeta = const VerificationMeta(
    'lastMissedDueDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastMissedDueDate =
      GeneratedColumn<DateTime>(
        'last_missed_due_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _nextDueAtMeta = const VerificationMeta(
    'nextDueAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextDueAt = GeneratedColumn<DateTime>(
    'next_due_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pbId,
    userId,
    title,
    description,
    type,
    intervalValue,
    intervalUnit,
    afterCompletion,
    frequency,
    daysOfWeekJson,
    dayOfMonth,
    timeOfDay,
    baseImportance,
    categoryId,
    lastMissedDueDate,
    nextDueAt,
    isActive,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_recurrence_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalRecurrenceRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('pb_id')) {
      context.handle(
        _pbIdMeta,
        pbId.isAcceptableOrUnknown(data['pb_id']!, _pbIdMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('interval_value')) {
      context.handle(
        _intervalValueMeta,
        intervalValue.isAcceptableOrUnknown(
          data['interval_value']!,
          _intervalValueMeta,
        ),
      );
    }
    if (data.containsKey('interval_unit')) {
      context.handle(
        _intervalUnitMeta,
        intervalUnit.isAcceptableOrUnknown(
          data['interval_unit']!,
          _intervalUnitMeta,
        ),
      );
    }
    if (data.containsKey('after_completion')) {
      context.handle(
        _afterCompletionMeta,
        afterCompletion.isAcceptableOrUnknown(
          data['after_completion']!,
          _afterCompletionMeta,
        ),
      );
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    }
    if (data.containsKey('days_of_week_json')) {
      context.handle(
        _daysOfWeekJsonMeta,
        daysOfWeekJson.isAcceptableOrUnknown(
          data['days_of_week_json']!,
          _daysOfWeekJsonMeta,
        ),
      );
    }
    if (data.containsKey('day_of_month')) {
      context.handle(
        _dayOfMonthMeta,
        dayOfMonth.isAcceptableOrUnknown(
          data['day_of_month']!,
          _dayOfMonthMeta,
        ),
      );
    }
    if (data.containsKey('time_of_day')) {
      context.handle(
        _timeOfDayMeta,
        timeOfDay.isAcceptableOrUnknown(data['time_of_day']!, _timeOfDayMeta),
      );
    }
    if (data.containsKey('base_importance')) {
      context.handle(
        _baseImportanceMeta,
        baseImportance.isAcceptableOrUnknown(
          data['base_importance']!,
          _baseImportanceMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('last_missed_due_date')) {
      context.handle(
        _lastMissedDueDateMeta,
        lastMissedDueDate.isAcceptableOrUnknown(
          data['last_missed_due_date']!,
          _lastMissedDueDateMeta,
        ),
      );
    }
    if (data.containsKey('next_due_at')) {
      context.handle(
        _nextDueAtMeta,
        nextDueAt.isAcceptableOrUnknown(data['next_due_at']!, _nextDueAtMeta),
      );
    } else if (isInserting) {
      context.missing(_nextDueAtMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id, userId};
  @override
  LocalRecurrenceRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalRecurrenceRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      pbId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pb_id'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      intervalValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_value'],
      )!,
      intervalUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}interval_unit'],
      )!,
      afterCompletion: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}after_completion'],
      )!,
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      ),
      daysOfWeekJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}days_of_week_json'],
      )!,
      dayOfMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_of_month'],
      ),
      timeOfDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_of_day'],
      )!,
      baseImportance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_importance'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      lastMissedDueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_missed_due_date'],
      ),
      nextDueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_due_at'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $LocalRecurrenceRulesTable createAlias(String alias) {
    return $LocalRecurrenceRulesTable(attachedDatabase, alias);
  }
}

class LocalRecurrenceRule extends DataClass
    implements Insertable<LocalRecurrenceRule> {
  final String id;
  final String? pbId;
  final String userId;
  final String title;
  final String? description;
  final String type;
  final int intervalValue;
  final String intervalUnit;
  final bool afterCompletion;
  final String? frequency;
  final String daysOfWeekJson;
  final int? dayOfMonth;
  final String timeOfDay;
  final int baseImportance;
  final String categoryId;
  final DateTime? lastMissedDueDate;
  final DateTime nextDueAt;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const LocalRecurrenceRule({
    required this.id,
    this.pbId,
    required this.userId,
    required this.title,
    this.description,
    required this.type,
    required this.intervalValue,
    required this.intervalUnit,
    required this.afterCompletion,
    this.frequency,
    required this.daysOfWeekJson,
    this.dayOfMonth,
    required this.timeOfDay,
    required this.baseImportance,
    required this.categoryId,
    this.lastMissedDueDate,
    required this.nextDueAt,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || pbId != null) {
      map['pb_id'] = Variable<String>(pbId);
    }
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['type'] = Variable<String>(type);
    map['interval_value'] = Variable<int>(intervalValue);
    map['interval_unit'] = Variable<String>(intervalUnit);
    map['after_completion'] = Variable<bool>(afterCompletion);
    if (!nullToAbsent || frequency != null) {
      map['frequency'] = Variable<String>(frequency);
    }
    map['days_of_week_json'] = Variable<String>(daysOfWeekJson);
    if (!nullToAbsent || dayOfMonth != null) {
      map['day_of_month'] = Variable<int>(dayOfMonth);
    }
    map['time_of_day'] = Variable<String>(timeOfDay);
    map['base_importance'] = Variable<int>(baseImportance);
    map['category_id'] = Variable<String>(categoryId);
    if (!nullToAbsent || lastMissedDueDate != null) {
      map['last_missed_due_date'] = Variable<DateTime>(lastMissedDueDate);
    }
    map['next_due_at'] = Variable<DateTime>(nextDueAt);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  LocalRecurrenceRulesCompanion toCompanion(bool nullToAbsent) {
    return LocalRecurrenceRulesCompanion(
      id: Value(id),
      pbId: pbId == null && nullToAbsent ? const Value.absent() : Value(pbId),
      userId: Value(userId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      type: Value(type),
      intervalValue: Value(intervalValue),
      intervalUnit: Value(intervalUnit),
      afterCompletion: Value(afterCompletion),
      frequency: frequency == null && nullToAbsent
          ? const Value.absent()
          : Value(frequency),
      daysOfWeekJson: Value(daysOfWeekJson),
      dayOfMonth: dayOfMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(dayOfMonth),
      timeOfDay: Value(timeOfDay),
      baseImportance: Value(baseImportance),
      categoryId: Value(categoryId),
      lastMissedDueDate: lastMissedDueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMissedDueDate),
      nextDueAt: Value(nextDueAt),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory LocalRecurrenceRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalRecurrenceRule(
      id: serializer.fromJson<String>(json['id']),
      pbId: serializer.fromJson<String?>(json['pbId']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      type: serializer.fromJson<String>(json['type']),
      intervalValue: serializer.fromJson<int>(json['intervalValue']),
      intervalUnit: serializer.fromJson<String>(json['intervalUnit']),
      afterCompletion: serializer.fromJson<bool>(json['afterCompletion']),
      frequency: serializer.fromJson<String?>(json['frequency']),
      daysOfWeekJson: serializer.fromJson<String>(json['daysOfWeekJson']),
      dayOfMonth: serializer.fromJson<int?>(json['dayOfMonth']),
      timeOfDay: serializer.fromJson<String>(json['timeOfDay']),
      baseImportance: serializer.fromJson<int>(json['baseImportance']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      lastMissedDueDate: serializer.fromJson<DateTime?>(
        json['lastMissedDueDate'],
      ),
      nextDueAt: serializer.fromJson<DateTime>(json['nextDueAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'pbId': serializer.toJson<String?>(pbId),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'type': serializer.toJson<String>(type),
      'intervalValue': serializer.toJson<int>(intervalValue),
      'intervalUnit': serializer.toJson<String>(intervalUnit),
      'afterCompletion': serializer.toJson<bool>(afterCompletion),
      'frequency': serializer.toJson<String?>(frequency),
      'daysOfWeekJson': serializer.toJson<String>(daysOfWeekJson),
      'dayOfMonth': serializer.toJson<int?>(dayOfMonth),
      'timeOfDay': serializer.toJson<String>(timeOfDay),
      'baseImportance': serializer.toJson<int>(baseImportance),
      'categoryId': serializer.toJson<String>(categoryId),
      'lastMissedDueDate': serializer.toJson<DateTime?>(lastMissedDueDate),
      'nextDueAt': serializer.toJson<DateTime>(nextDueAt),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  LocalRecurrenceRule copyWith({
    String? id,
    Value<String?> pbId = const Value.absent(),
    String? userId,
    String? title,
    Value<String?> description = const Value.absent(),
    String? type,
    int? intervalValue,
    String? intervalUnit,
    bool? afterCompletion,
    Value<String?> frequency = const Value.absent(),
    String? daysOfWeekJson,
    Value<int?> dayOfMonth = const Value.absent(),
    String? timeOfDay,
    int? baseImportance,
    String? categoryId,
    Value<DateTime?> lastMissedDueDate = const Value.absent(),
    DateTime? nextDueAt,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => LocalRecurrenceRule(
    id: id ?? this.id,
    pbId: pbId.present ? pbId.value : this.pbId,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    type: type ?? this.type,
    intervalValue: intervalValue ?? this.intervalValue,
    intervalUnit: intervalUnit ?? this.intervalUnit,
    afterCompletion: afterCompletion ?? this.afterCompletion,
    frequency: frequency.present ? frequency.value : this.frequency,
    daysOfWeekJson: daysOfWeekJson ?? this.daysOfWeekJson,
    dayOfMonth: dayOfMonth.present ? dayOfMonth.value : this.dayOfMonth,
    timeOfDay: timeOfDay ?? this.timeOfDay,
    baseImportance: baseImportance ?? this.baseImportance,
    categoryId: categoryId ?? this.categoryId,
    lastMissedDueDate: lastMissedDueDate.present
        ? lastMissedDueDate.value
        : this.lastMissedDueDate,
    nextDueAt: nextDueAt ?? this.nextDueAt,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  LocalRecurrenceRule copyWithCompanion(LocalRecurrenceRulesCompanion data) {
    return LocalRecurrenceRule(
      id: data.id.present ? data.id.value : this.id,
      pbId: data.pbId.present ? data.pbId.value : this.pbId,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      type: data.type.present ? data.type.value : this.type,
      intervalValue: data.intervalValue.present
          ? data.intervalValue.value
          : this.intervalValue,
      intervalUnit: data.intervalUnit.present
          ? data.intervalUnit.value
          : this.intervalUnit,
      afterCompletion: data.afterCompletion.present
          ? data.afterCompletion.value
          : this.afterCompletion,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      daysOfWeekJson: data.daysOfWeekJson.present
          ? data.daysOfWeekJson.value
          : this.daysOfWeekJson,
      dayOfMonth: data.dayOfMonth.present
          ? data.dayOfMonth.value
          : this.dayOfMonth,
      timeOfDay: data.timeOfDay.present ? data.timeOfDay.value : this.timeOfDay,
      baseImportance: data.baseImportance.present
          ? data.baseImportance.value
          : this.baseImportance,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      lastMissedDueDate: data.lastMissedDueDate.present
          ? data.lastMissedDueDate.value
          : this.lastMissedDueDate,
      nextDueAt: data.nextDueAt.present ? data.nextDueAt.value : this.nextDueAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalRecurrenceRule(')
          ..write('id: $id, ')
          ..write('pbId: $pbId, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('intervalValue: $intervalValue, ')
          ..write('intervalUnit: $intervalUnit, ')
          ..write('afterCompletion: $afterCompletion, ')
          ..write('frequency: $frequency, ')
          ..write('daysOfWeekJson: $daysOfWeekJson, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('timeOfDay: $timeOfDay, ')
          ..write('baseImportance: $baseImportance, ')
          ..write('categoryId: $categoryId, ')
          ..write('lastMissedDueDate: $lastMissedDueDate, ')
          ..write('nextDueAt: $nextDueAt, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    pbId,
    userId,
    title,
    description,
    type,
    intervalValue,
    intervalUnit,
    afterCompletion,
    frequency,
    daysOfWeekJson,
    dayOfMonth,
    timeOfDay,
    baseImportance,
    categoryId,
    lastMissedDueDate,
    nextDueAt,
    isActive,
    createdAt,
    updatedAt,
    deletedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalRecurrenceRule &&
          other.id == this.id &&
          other.pbId == this.pbId &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.description == this.description &&
          other.type == this.type &&
          other.intervalValue == this.intervalValue &&
          other.intervalUnit == this.intervalUnit &&
          other.afterCompletion == this.afterCompletion &&
          other.frequency == this.frequency &&
          other.daysOfWeekJson == this.daysOfWeekJson &&
          other.dayOfMonth == this.dayOfMonth &&
          other.timeOfDay == this.timeOfDay &&
          other.baseImportance == this.baseImportance &&
          other.categoryId == this.categoryId &&
          other.lastMissedDueDate == this.lastMissedDueDate &&
          other.nextDueAt == this.nextDueAt &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class LocalRecurrenceRulesCompanion
    extends UpdateCompanion<LocalRecurrenceRule> {
  final Value<String> id;
  final Value<String?> pbId;
  final Value<String> userId;
  final Value<String> title;
  final Value<String?> description;
  final Value<String> type;
  final Value<int> intervalValue;
  final Value<String> intervalUnit;
  final Value<bool> afterCompletion;
  final Value<String?> frequency;
  final Value<String> daysOfWeekJson;
  final Value<int?> dayOfMonth;
  final Value<String> timeOfDay;
  final Value<int> baseImportance;
  final Value<String> categoryId;
  final Value<DateTime?> lastMissedDueDate;
  final Value<DateTime> nextDueAt;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const LocalRecurrenceRulesCompanion({
    this.id = const Value.absent(),
    this.pbId = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.type = const Value.absent(),
    this.intervalValue = const Value.absent(),
    this.intervalUnit = const Value.absent(),
    this.afterCompletion = const Value.absent(),
    this.frequency = const Value.absent(),
    this.daysOfWeekJson = const Value.absent(),
    this.dayOfMonth = const Value.absent(),
    this.timeOfDay = const Value.absent(),
    this.baseImportance = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.lastMissedDueDate = const Value.absent(),
    this.nextDueAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalRecurrenceRulesCompanion.insert({
    required String id,
    this.pbId = const Value.absent(),
    required String userId,
    required String title,
    this.description = const Value.absent(),
    required String type,
    this.intervalValue = const Value.absent(),
    this.intervalUnit = const Value.absent(),
    this.afterCompletion = const Value.absent(),
    this.frequency = const Value.absent(),
    this.daysOfWeekJson = const Value.absent(),
    this.dayOfMonth = const Value.absent(),
    this.timeOfDay = const Value.absent(),
    this.baseImportance = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.lastMissedDueDate = const Value.absent(),
    required DateTime nextDueAt,
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       title = Value(title),
       type = Value(type),
       nextDueAt = Value(nextDueAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalRecurrenceRule> custom({
    Expression<String>? id,
    Expression<String>? pbId,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? type,
    Expression<int>? intervalValue,
    Expression<String>? intervalUnit,
    Expression<bool>? afterCompletion,
    Expression<String>? frequency,
    Expression<String>? daysOfWeekJson,
    Expression<int>? dayOfMonth,
    Expression<String>? timeOfDay,
    Expression<int>? baseImportance,
    Expression<String>? categoryId,
    Expression<DateTime>? lastMissedDueDate,
    Expression<DateTime>? nextDueAt,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pbId != null) 'pb_id': pbId,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (type != null) 'type': type,
      if (intervalValue != null) 'interval_value': intervalValue,
      if (intervalUnit != null) 'interval_unit': intervalUnit,
      if (afterCompletion != null) 'after_completion': afterCompletion,
      if (frequency != null) 'frequency': frequency,
      if (daysOfWeekJson != null) 'days_of_week_json': daysOfWeekJson,
      if (dayOfMonth != null) 'day_of_month': dayOfMonth,
      if (timeOfDay != null) 'time_of_day': timeOfDay,
      if (baseImportance != null) 'base_importance': baseImportance,
      if (categoryId != null) 'category_id': categoryId,
      if (lastMissedDueDate != null) 'last_missed_due_date': lastMissedDueDate,
      if (nextDueAt != null) 'next_due_at': nextDueAt,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalRecurrenceRulesCompanion copyWith({
    Value<String>? id,
    Value<String?>? pbId,
    Value<String>? userId,
    Value<String>? title,
    Value<String?>? description,
    Value<String>? type,
    Value<int>? intervalValue,
    Value<String>? intervalUnit,
    Value<bool>? afterCompletion,
    Value<String?>? frequency,
    Value<String>? daysOfWeekJson,
    Value<int?>? dayOfMonth,
    Value<String>? timeOfDay,
    Value<int>? baseImportance,
    Value<String>? categoryId,
    Value<DateTime?>? lastMissedDueDate,
    Value<DateTime>? nextDueAt,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return LocalRecurrenceRulesCompanion(
      id: id ?? this.id,
      pbId: pbId ?? this.pbId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      intervalValue: intervalValue ?? this.intervalValue,
      intervalUnit: intervalUnit ?? this.intervalUnit,
      afterCompletion: afterCompletion ?? this.afterCompletion,
      frequency: frequency ?? this.frequency,
      daysOfWeekJson: daysOfWeekJson ?? this.daysOfWeekJson,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      baseImportance: baseImportance ?? this.baseImportance,
      categoryId: categoryId ?? this.categoryId,
      lastMissedDueDate: lastMissedDueDate ?? this.lastMissedDueDate,
      nextDueAt: nextDueAt ?? this.nextDueAt,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (pbId.present) {
      map['pb_id'] = Variable<String>(pbId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (intervalValue.present) {
      map['interval_value'] = Variable<int>(intervalValue.value);
    }
    if (intervalUnit.present) {
      map['interval_unit'] = Variable<String>(intervalUnit.value);
    }
    if (afterCompletion.present) {
      map['after_completion'] = Variable<bool>(afterCompletion.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (daysOfWeekJson.present) {
      map['days_of_week_json'] = Variable<String>(daysOfWeekJson.value);
    }
    if (dayOfMonth.present) {
      map['day_of_month'] = Variable<int>(dayOfMonth.value);
    }
    if (timeOfDay.present) {
      map['time_of_day'] = Variable<String>(timeOfDay.value);
    }
    if (baseImportance.present) {
      map['base_importance'] = Variable<int>(baseImportance.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (lastMissedDueDate.present) {
      map['last_missed_due_date'] = Variable<DateTime>(lastMissedDueDate.value);
    }
    if (nextDueAt.present) {
      map['next_due_at'] = Variable<DateTime>(nextDueAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalRecurrenceRulesCompanion(')
          ..write('id: $id, ')
          ..write('pbId: $pbId, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('intervalValue: $intervalValue, ')
          ..write('intervalUnit: $intervalUnit, ')
          ..write('afterCompletion: $afterCompletion, ')
          ..write('frequency: $frequency, ')
          ..write('daysOfWeekJson: $daysOfWeekJson, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('timeOfDay: $timeOfDay, ')
          ..write('baseImportance: $baseImportance, ')
          ..write('categoryId: $categoryId, ')
          ..write('lastMissedDueDate: $lastMissedDueDate, ')
          ..write('nextDueAt: $nextDueAt, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalProfilesTable extends LocalProfiles
    with TableInfo<$LocalProfilesTable, LocalProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pbIdMeta = const VerificationMeta('pbId');
  @override
  late final GeneratedColumn<String> pbId = GeneratedColumn<String>(
    'pb_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _profileJsonMeta = const VerificationMeta(
    'profileJson',
  );
  @override
  late final GeneratedColumn<String> profileJson = GeneratedColumn<String>(
    'profile_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [userId, pbId, profileJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('pb_id')) {
      context.handle(
        _pbIdMeta,
        pbId.isAcceptableOrUnknown(data['pb_id']!, _pbIdMeta),
      );
    }
    if (data.containsKey('profile_json')) {
      context.handle(
        _profileJsonMeta,
        profileJson.isAcceptableOrUnknown(
          data['profile_json']!,
          _profileJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_profileJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  LocalProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalProfile(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      pbId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pb_id'],
      ),
      profileJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalProfilesTable createAlias(String alias) {
    return $LocalProfilesTable(attachedDatabase, alias);
  }
}

class LocalProfile extends DataClass implements Insertable<LocalProfile> {
  final String userId;
  final String? pbId;
  final String profileJson;
  final DateTime updatedAt;
  const LocalProfile({
    required this.userId,
    this.pbId,
    required this.profileJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || pbId != null) {
      map['pb_id'] = Variable<String>(pbId);
    }
    map['profile_json'] = Variable<String>(profileJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalProfilesCompanion toCompanion(bool nullToAbsent) {
    return LocalProfilesCompanion(
      userId: Value(userId),
      pbId: pbId == null && nullToAbsent ? const Value.absent() : Value(pbId),
      profileJson: Value(profileJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalProfile(
      userId: serializer.fromJson<String>(json['userId']),
      pbId: serializer.fromJson<String?>(json['pbId']),
      profileJson: serializer.fromJson<String>(json['profileJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'pbId': serializer.toJson<String?>(pbId),
      'profileJson': serializer.toJson<String>(profileJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalProfile copyWith({
    String? userId,
    Value<String?> pbId = const Value.absent(),
    String? profileJson,
    DateTime? updatedAt,
  }) => LocalProfile(
    userId: userId ?? this.userId,
    pbId: pbId.present ? pbId.value : this.pbId,
    profileJson: profileJson ?? this.profileJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalProfile copyWithCompanion(LocalProfilesCompanion data) {
    return LocalProfile(
      userId: data.userId.present ? data.userId.value : this.userId,
      pbId: data.pbId.present ? data.pbId.value : this.pbId,
      profileJson: data.profileJson.present
          ? data.profileJson.value
          : this.profileJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalProfile(')
          ..write('userId: $userId, ')
          ..write('pbId: $pbId, ')
          ..write('profileJson: $profileJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, pbId, profileJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalProfile &&
          other.userId == this.userId &&
          other.pbId == this.pbId &&
          other.profileJson == this.profileJson &&
          other.updatedAt == this.updatedAt);
}

class LocalProfilesCompanion extends UpdateCompanion<LocalProfile> {
  final Value<String> userId;
  final Value<String?> pbId;
  final Value<String> profileJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalProfilesCompanion({
    this.userId = const Value.absent(),
    this.pbId = const Value.absent(),
    this.profileJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalProfilesCompanion.insert({
    required String userId,
    this.pbId = const Value.absent(),
    required String profileJson,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       profileJson = Value(profileJson),
       updatedAt = Value(updatedAt);
  static Insertable<LocalProfile> custom({
    Expression<String>? userId,
    Expression<String>? pbId,
    Expression<String>? profileJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (pbId != null) 'pb_id': pbId,
      if (profileJson != null) 'profile_json': profileJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalProfilesCompanion copyWith({
    Value<String>? userId,
    Value<String?>? pbId,
    Value<String>? profileJson,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalProfilesCompanion(
      userId: userId ?? this.userId,
      pbId: pbId ?? this.pbId,
      profileJson: profileJson ?? this.profileJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (pbId.present) {
      map['pb_id'] = Variable<String>(pbId.value);
    }
    if (profileJson.present) {
      map['profile_json'] = Variable<String>(profileJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalProfilesCompanion(')
          ..write('userId: $userId, ')
          ..write('pbId: $pbId, ')
          ..write('profileJson: $profileJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalExternalEventsTable extends LocalExternalEvents
    with TableInfo<$LocalExternalEventsTable, LocalExternalEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalExternalEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pbIdMeta = const VerificationMeta('pbId');
  @override
  late final GeneratedColumn<String> pbId = GeneratedColumn<String>(
    'pb_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _externalIdMeta = const VerificationMeta(
    'externalId',
  );
  @override
  late final GeneratedColumn<String> externalId = GeneratedColumn<String>(
    'external_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
    'end_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _meetingUrlMeta = const VerificationMeta(
    'meetingUrl',
  );
  @override
  late final GeneratedColumn<String> meetingUrl = GeneratedColumn<String>(
    'meeting_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attendeesJsonMeta = const VerificationMeta(
    'attendeesJson',
  );
  @override
  late final GeneratedColumn<String> attendeesJson = GeneratedColumn<String>(
    'attendees_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _hasLinkedTaskMeta = const VerificationMeta(
    'hasLinkedTask',
  );
  @override
  late final GeneratedColumn<bool> hasLinkedTask = GeneratedColumn<bool>(
    'has_linked_task',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_linked_task" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pbId,
    userId,
    externalId,
    source,
    title,
    startTime,
    endTime,
    location,
    description,
    meetingUrl,
    attendeesJson,
    hasLinkedTask,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_external_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalExternalEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('pb_id')) {
      context.handle(
        _pbIdMeta,
        pbId.isAcceptableOrUnknown(data['pb_id']!, _pbIdMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('external_id')) {
      context.handle(
        _externalIdMeta,
        externalId.isAcceptableOrUnknown(data['external_id']!, _externalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_externalIdMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('meeting_url')) {
      context.handle(
        _meetingUrlMeta,
        meetingUrl.isAcceptableOrUnknown(data['meeting_url']!, _meetingUrlMeta),
      );
    }
    if (data.containsKey('attendees_json')) {
      context.handle(
        _attendeesJsonMeta,
        attendeesJson.isAcceptableOrUnknown(
          data['attendees_json']!,
          _attendeesJsonMeta,
        ),
      );
    }
    if (data.containsKey('has_linked_task')) {
      context.handle(
        _hasLinkedTaskMeta,
        hasLinkedTask.isAcceptableOrUnknown(
          data['has_linked_task']!,
          _hasLinkedTaskMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id, userId};
  @override
  LocalExternalEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalExternalEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      pbId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pb_id'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      externalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_time'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      meetingUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meeting_url'],
      ),
      attendeesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attendees_json'],
      )!,
      hasLinkedTask: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_linked_task'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalExternalEventsTable createAlias(String alias) {
    return $LocalExternalEventsTable(attachedDatabase, alias);
  }
}

class LocalExternalEvent extends DataClass
    implements Insertable<LocalExternalEvent> {
  final String id;
  final String? pbId;
  final String userId;
  final String externalId;
  final String source;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String description;
  final String? meetingUrl;
  final String attendeesJson;
  final bool hasLinkedTask;
  final DateTime updatedAt;
  const LocalExternalEvent({
    required this.id,
    this.pbId,
    required this.userId,
    required this.externalId,
    required this.source,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.description,
    this.meetingUrl,
    required this.attendeesJson,
    required this.hasLinkedTask,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || pbId != null) {
      map['pb_id'] = Variable<String>(pbId);
    }
    map['user_id'] = Variable<String>(userId);
    map['external_id'] = Variable<String>(externalId);
    map['source'] = Variable<String>(source);
    map['title'] = Variable<String>(title);
    map['start_time'] = Variable<DateTime>(startTime);
    map['end_time'] = Variable<DateTime>(endTime);
    map['location'] = Variable<String>(location);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || meetingUrl != null) {
      map['meeting_url'] = Variable<String>(meetingUrl);
    }
    map['attendees_json'] = Variable<String>(attendeesJson);
    map['has_linked_task'] = Variable<bool>(hasLinkedTask);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalExternalEventsCompanion toCompanion(bool nullToAbsent) {
    return LocalExternalEventsCompanion(
      id: Value(id),
      pbId: pbId == null && nullToAbsent ? const Value.absent() : Value(pbId),
      userId: Value(userId),
      externalId: Value(externalId),
      source: Value(source),
      title: Value(title),
      startTime: Value(startTime),
      endTime: Value(endTime),
      location: Value(location),
      description: Value(description),
      meetingUrl: meetingUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(meetingUrl),
      attendeesJson: Value(attendeesJson),
      hasLinkedTask: Value(hasLinkedTask),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalExternalEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalExternalEvent(
      id: serializer.fromJson<String>(json['id']),
      pbId: serializer.fromJson<String?>(json['pbId']),
      userId: serializer.fromJson<String>(json['userId']),
      externalId: serializer.fromJson<String>(json['externalId']),
      source: serializer.fromJson<String>(json['source']),
      title: serializer.fromJson<String>(json['title']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime>(json['endTime']),
      location: serializer.fromJson<String>(json['location']),
      description: serializer.fromJson<String>(json['description']),
      meetingUrl: serializer.fromJson<String?>(json['meetingUrl']),
      attendeesJson: serializer.fromJson<String>(json['attendeesJson']),
      hasLinkedTask: serializer.fromJson<bool>(json['hasLinkedTask']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'pbId': serializer.toJson<String?>(pbId),
      'userId': serializer.toJson<String>(userId),
      'externalId': serializer.toJson<String>(externalId),
      'source': serializer.toJson<String>(source),
      'title': serializer.toJson<String>(title),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime>(endTime),
      'location': serializer.toJson<String>(location),
      'description': serializer.toJson<String>(description),
      'meetingUrl': serializer.toJson<String?>(meetingUrl),
      'attendeesJson': serializer.toJson<String>(attendeesJson),
      'hasLinkedTask': serializer.toJson<bool>(hasLinkedTask),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalExternalEvent copyWith({
    String? id,
    Value<String?> pbId = const Value.absent(),
    String? userId,
    String? externalId,
    String? source,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? description,
    Value<String?> meetingUrl = const Value.absent(),
    String? attendeesJson,
    bool? hasLinkedTask,
    DateTime? updatedAt,
  }) => LocalExternalEvent(
    id: id ?? this.id,
    pbId: pbId.present ? pbId.value : this.pbId,
    userId: userId ?? this.userId,
    externalId: externalId ?? this.externalId,
    source: source ?? this.source,
    title: title ?? this.title,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    location: location ?? this.location,
    description: description ?? this.description,
    meetingUrl: meetingUrl.present ? meetingUrl.value : this.meetingUrl,
    attendeesJson: attendeesJson ?? this.attendeesJson,
    hasLinkedTask: hasLinkedTask ?? this.hasLinkedTask,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalExternalEvent copyWithCompanion(LocalExternalEventsCompanion data) {
    return LocalExternalEvent(
      id: data.id.present ? data.id.value : this.id,
      pbId: data.pbId.present ? data.pbId.value : this.pbId,
      userId: data.userId.present ? data.userId.value : this.userId,
      externalId: data.externalId.present
          ? data.externalId.value
          : this.externalId,
      source: data.source.present ? data.source.value : this.source,
      title: data.title.present ? data.title.value : this.title,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      location: data.location.present ? data.location.value : this.location,
      description: data.description.present
          ? data.description.value
          : this.description,
      meetingUrl: data.meetingUrl.present
          ? data.meetingUrl.value
          : this.meetingUrl,
      attendeesJson: data.attendeesJson.present
          ? data.attendeesJson.value
          : this.attendeesJson,
      hasLinkedTask: data.hasLinkedTask.present
          ? data.hasLinkedTask.value
          : this.hasLinkedTask,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalExternalEvent(')
          ..write('id: $id, ')
          ..write('pbId: $pbId, ')
          ..write('userId: $userId, ')
          ..write('externalId: $externalId, ')
          ..write('source: $source, ')
          ..write('title: $title, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('location: $location, ')
          ..write('description: $description, ')
          ..write('meetingUrl: $meetingUrl, ')
          ..write('attendeesJson: $attendeesJson, ')
          ..write('hasLinkedTask: $hasLinkedTask, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pbId,
    userId,
    externalId,
    source,
    title,
    startTime,
    endTime,
    location,
    description,
    meetingUrl,
    attendeesJson,
    hasLinkedTask,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalExternalEvent &&
          other.id == this.id &&
          other.pbId == this.pbId &&
          other.userId == this.userId &&
          other.externalId == this.externalId &&
          other.source == this.source &&
          other.title == this.title &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.location == this.location &&
          other.description == this.description &&
          other.meetingUrl == this.meetingUrl &&
          other.attendeesJson == this.attendeesJson &&
          other.hasLinkedTask == this.hasLinkedTask &&
          other.updatedAt == this.updatedAt);
}

class LocalExternalEventsCompanion extends UpdateCompanion<LocalExternalEvent> {
  final Value<String> id;
  final Value<String?> pbId;
  final Value<String> userId;
  final Value<String> externalId;
  final Value<String> source;
  final Value<String> title;
  final Value<DateTime> startTime;
  final Value<DateTime> endTime;
  final Value<String> location;
  final Value<String> description;
  final Value<String?> meetingUrl;
  final Value<String> attendeesJson;
  final Value<bool> hasLinkedTask;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalExternalEventsCompanion({
    this.id = const Value.absent(),
    this.pbId = const Value.absent(),
    this.userId = const Value.absent(),
    this.externalId = const Value.absent(),
    this.source = const Value.absent(),
    this.title = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.location = const Value.absent(),
    this.description = const Value.absent(),
    this.meetingUrl = const Value.absent(),
    this.attendeesJson = const Value.absent(),
    this.hasLinkedTask = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalExternalEventsCompanion.insert({
    required String id,
    this.pbId = const Value.absent(),
    required String userId,
    required String externalId,
    required String source,
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    this.location = const Value.absent(),
    this.description = const Value.absent(),
    this.meetingUrl = const Value.absent(),
    this.attendeesJson = const Value.absent(),
    this.hasLinkedTask = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       externalId = Value(externalId),
       source = Value(source),
       title = Value(title),
       startTime = Value(startTime),
       endTime = Value(endTime),
       updatedAt = Value(updatedAt);
  static Insertable<LocalExternalEvent> custom({
    Expression<String>? id,
    Expression<String>? pbId,
    Expression<String>? userId,
    Expression<String>? externalId,
    Expression<String>? source,
    Expression<String>? title,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<String>? location,
    Expression<String>? description,
    Expression<String>? meetingUrl,
    Expression<String>? attendeesJson,
    Expression<bool>? hasLinkedTask,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pbId != null) 'pb_id': pbId,
      if (userId != null) 'user_id': userId,
      if (externalId != null) 'external_id': externalId,
      if (source != null) 'source': source,
      if (title != null) 'title': title,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (location != null) 'location': location,
      if (description != null) 'description': description,
      if (meetingUrl != null) 'meeting_url': meetingUrl,
      if (attendeesJson != null) 'attendees_json': attendeesJson,
      if (hasLinkedTask != null) 'has_linked_task': hasLinkedTask,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalExternalEventsCompanion copyWith({
    Value<String>? id,
    Value<String?>? pbId,
    Value<String>? userId,
    Value<String>? externalId,
    Value<String>? source,
    Value<String>? title,
    Value<DateTime>? startTime,
    Value<DateTime>? endTime,
    Value<String>? location,
    Value<String>? description,
    Value<String?>? meetingUrl,
    Value<String>? attendeesJson,
    Value<bool>? hasLinkedTask,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalExternalEventsCompanion(
      id: id ?? this.id,
      pbId: pbId ?? this.pbId,
      userId: userId ?? this.userId,
      externalId: externalId ?? this.externalId,
      source: source ?? this.source,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      description: description ?? this.description,
      meetingUrl: meetingUrl ?? this.meetingUrl,
      attendeesJson: attendeesJson ?? this.attendeesJson,
      hasLinkedTask: hasLinkedTask ?? this.hasLinkedTask,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (pbId.present) {
      map['pb_id'] = Variable<String>(pbId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (externalId.present) {
      map['external_id'] = Variable<String>(externalId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (meetingUrl.present) {
      map['meeting_url'] = Variable<String>(meetingUrl.value);
    }
    if (attendeesJson.present) {
      map['attendees_json'] = Variable<String>(attendeesJson.value);
    }
    if (hasLinkedTask.present) {
      map['has_linked_task'] = Variable<bool>(hasLinkedTask.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalExternalEventsCompanion(')
          ..write('id: $id, ')
          ..write('pbId: $pbId, ')
          ..write('userId: $userId, ')
          ..write('externalId: $externalId, ')
          ..write('source: $source, ')
          ..write('title: $title, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('location: $location, ')
          ..write('description: $description, ')
          ..write('meetingUrl: $meetingUrl, ')
          ..write('attendeesJson: $attendeesJson, ')
          ..write('hasLinkedTask: $hasLinkedTask, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalTaskSuggestionsTable extends LocalTaskSuggestions
    with TableInfo<$LocalTaskSuggestionsTable, LocalTaskSuggestion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalTaskSuggestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pbIdMeta = const VerificationMeta('pbId');
  @override
  late final GeneratedColumn<String> pbId = GeneratedColumn<String>(
    'pb_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailIdMeta = const VerificationMeta(
    'emailId',
  );
  @override
  late final GeneratedColumn<String> emailId = GeneratedColumn<String>(
    'email_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderMeta = const VerificationMeta('sender');
  @override
  late final GeneratedColumn<String> sender = GeneratedColumn<String>(
    'sender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectMeta = const VerificationMeta(
    'subject',
  );
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
    'subject',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _snippetMeta = const VerificationMeta(
    'snippet',
  );
  @override
  late final GeneratedColumn<String> snippet = GeneratedColumn<String>(
    'snippet',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
    'received_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('work'),
  );
  static const VerificationMeta _importanceMeta = const VerificationMeta(
    'importance',
  );
  @override
  late final GeneratedColumn<int> importance = GeneratedColumn<int>(
    'importance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _suggestedDueDateMeta = const VerificationMeta(
    'suggestedDueDate',
  );
  @override
  late final GeneratedColumn<DateTime> suggestedDueDate =
      GeneratedColumn<DateTime>(
        'suggested_due_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pbId,
    userId,
    emailId,
    sender,
    subject,
    snippet,
    receivedAt,
    title,
    description,
    categoryId,
    importance,
    suggestedDueDate,
    status,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_task_suggestions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalTaskSuggestion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('pb_id')) {
      context.handle(
        _pbIdMeta,
        pbId.isAcceptableOrUnknown(data['pb_id']!, _pbIdMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('email_id')) {
      context.handle(
        _emailIdMeta,
        emailId.isAcceptableOrUnknown(data['email_id']!, _emailIdMeta),
      );
    } else if (isInserting) {
      context.missing(_emailIdMeta);
    }
    if (data.containsKey('sender')) {
      context.handle(
        _senderMeta,
        sender.isAcceptableOrUnknown(data['sender']!, _senderMeta),
      );
    } else if (isInserting) {
      context.missing(_senderMeta);
    }
    if (data.containsKey('subject')) {
      context.handle(
        _subjectMeta,
        subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectMeta);
    }
    if (data.containsKey('snippet')) {
      context.handle(
        _snippetMeta,
        snippet.isAcceptableOrUnknown(data['snippet']!, _snippetMeta),
      );
    } else if (isInserting) {
      context.missing(_snippetMeta);
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('importance')) {
      context.handle(
        _importanceMeta,
        importance.isAcceptableOrUnknown(data['importance']!, _importanceMeta),
      );
    }
    if (data.containsKey('suggested_due_date')) {
      context.handle(
        _suggestedDueDateMeta,
        suggestedDueDate.isAcceptableOrUnknown(
          data['suggested_due_date']!,
          _suggestedDueDateMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id, userId};
  @override
  LocalTaskSuggestion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTaskSuggestion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      pbId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pb_id'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      emailId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email_id'],
      )!,
      sender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender'],
      )!,
      subject: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject'],
      )!,
      snippet: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snippet'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      importance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}importance'],
      )!,
      suggestedDueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}suggested_due_date'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalTaskSuggestionsTable createAlias(String alias) {
    return $LocalTaskSuggestionsTable(attachedDatabase, alias);
  }
}

class LocalTaskSuggestion extends DataClass
    implements Insertable<LocalTaskSuggestion> {
  final String id;
  final String? pbId;
  final String userId;
  final String emailId;
  final String sender;
  final String subject;
  final String snippet;
  final DateTime receivedAt;
  final String title;
  final String description;
  final String categoryId;
  final int importance;
  final DateTime? suggestedDueDate;
  final String status;
  final DateTime updatedAt;
  const LocalTaskSuggestion({
    required this.id,
    this.pbId,
    required this.userId,
    required this.emailId,
    required this.sender,
    required this.subject,
    required this.snippet,
    required this.receivedAt,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.importance,
    this.suggestedDueDate,
    required this.status,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || pbId != null) {
      map['pb_id'] = Variable<String>(pbId);
    }
    map['user_id'] = Variable<String>(userId);
    map['email_id'] = Variable<String>(emailId);
    map['sender'] = Variable<String>(sender);
    map['subject'] = Variable<String>(subject);
    map['snippet'] = Variable<String>(snippet);
    map['received_at'] = Variable<DateTime>(receivedAt);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['category_id'] = Variable<String>(categoryId);
    map['importance'] = Variable<int>(importance);
    if (!nullToAbsent || suggestedDueDate != null) {
      map['suggested_due_date'] = Variable<DateTime>(suggestedDueDate);
    }
    map['status'] = Variable<String>(status);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalTaskSuggestionsCompanion toCompanion(bool nullToAbsent) {
    return LocalTaskSuggestionsCompanion(
      id: Value(id),
      pbId: pbId == null && nullToAbsent ? const Value.absent() : Value(pbId),
      userId: Value(userId),
      emailId: Value(emailId),
      sender: Value(sender),
      subject: Value(subject),
      snippet: Value(snippet),
      receivedAt: Value(receivedAt),
      title: Value(title),
      description: Value(description),
      categoryId: Value(categoryId),
      importance: Value(importance),
      suggestedDueDate: suggestedDueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(suggestedDueDate),
      status: Value(status),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalTaskSuggestion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTaskSuggestion(
      id: serializer.fromJson<String>(json['id']),
      pbId: serializer.fromJson<String?>(json['pbId']),
      userId: serializer.fromJson<String>(json['userId']),
      emailId: serializer.fromJson<String>(json['emailId']),
      sender: serializer.fromJson<String>(json['sender']),
      subject: serializer.fromJson<String>(json['subject']),
      snippet: serializer.fromJson<String>(json['snippet']),
      receivedAt: serializer.fromJson<DateTime>(json['receivedAt']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      importance: serializer.fromJson<int>(json['importance']),
      suggestedDueDate: serializer.fromJson<DateTime?>(
        json['suggestedDueDate'],
      ),
      status: serializer.fromJson<String>(json['status']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'pbId': serializer.toJson<String?>(pbId),
      'userId': serializer.toJson<String>(userId),
      'emailId': serializer.toJson<String>(emailId),
      'sender': serializer.toJson<String>(sender),
      'subject': serializer.toJson<String>(subject),
      'snippet': serializer.toJson<String>(snippet),
      'receivedAt': serializer.toJson<DateTime>(receivedAt),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'categoryId': serializer.toJson<String>(categoryId),
      'importance': serializer.toJson<int>(importance),
      'suggestedDueDate': serializer.toJson<DateTime?>(suggestedDueDate),
      'status': serializer.toJson<String>(status),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalTaskSuggestion copyWith({
    String? id,
    Value<String?> pbId = const Value.absent(),
    String? userId,
    String? emailId,
    String? sender,
    String? subject,
    String? snippet,
    DateTime? receivedAt,
    String? title,
    String? description,
    String? categoryId,
    int? importance,
    Value<DateTime?> suggestedDueDate = const Value.absent(),
    String? status,
    DateTime? updatedAt,
  }) => LocalTaskSuggestion(
    id: id ?? this.id,
    pbId: pbId.present ? pbId.value : this.pbId,
    userId: userId ?? this.userId,
    emailId: emailId ?? this.emailId,
    sender: sender ?? this.sender,
    subject: subject ?? this.subject,
    snippet: snippet ?? this.snippet,
    receivedAt: receivedAt ?? this.receivedAt,
    title: title ?? this.title,
    description: description ?? this.description,
    categoryId: categoryId ?? this.categoryId,
    importance: importance ?? this.importance,
    suggestedDueDate: suggestedDueDate.present
        ? suggestedDueDate.value
        : this.suggestedDueDate,
    status: status ?? this.status,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalTaskSuggestion copyWithCompanion(LocalTaskSuggestionsCompanion data) {
    return LocalTaskSuggestion(
      id: data.id.present ? data.id.value : this.id,
      pbId: data.pbId.present ? data.pbId.value : this.pbId,
      userId: data.userId.present ? data.userId.value : this.userId,
      emailId: data.emailId.present ? data.emailId.value : this.emailId,
      sender: data.sender.present ? data.sender.value : this.sender,
      subject: data.subject.present ? data.subject.value : this.subject,
      snippet: data.snippet.present ? data.snippet.value : this.snippet,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      importance: data.importance.present
          ? data.importance.value
          : this.importance,
      suggestedDueDate: data.suggestedDueDate.present
          ? data.suggestedDueDate.value
          : this.suggestedDueDate,
      status: data.status.present ? data.status.value : this.status,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTaskSuggestion(')
          ..write('id: $id, ')
          ..write('pbId: $pbId, ')
          ..write('userId: $userId, ')
          ..write('emailId: $emailId, ')
          ..write('sender: $sender, ')
          ..write('subject: $subject, ')
          ..write('snippet: $snippet, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('categoryId: $categoryId, ')
          ..write('importance: $importance, ')
          ..write('suggestedDueDate: $suggestedDueDate, ')
          ..write('status: $status, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pbId,
    userId,
    emailId,
    sender,
    subject,
    snippet,
    receivedAt,
    title,
    description,
    categoryId,
    importance,
    suggestedDueDate,
    status,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTaskSuggestion &&
          other.id == this.id &&
          other.pbId == this.pbId &&
          other.userId == this.userId &&
          other.emailId == this.emailId &&
          other.sender == this.sender &&
          other.subject == this.subject &&
          other.snippet == this.snippet &&
          other.receivedAt == this.receivedAt &&
          other.title == this.title &&
          other.description == this.description &&
          other.categoryId == this.categoryId &&
          other.importance == this.importance &&
          other.suggestedDueDate == this.suggestedDueDate &&
          other.status == this.status &&
          other.updatedAt == this.updatedAt);
}

class LocalTaskSuggestionsCompanion
    extends UpdateCompanion<LocalTaskSuggestion> {
  final Value<String> id;
  final Value<String?> pbId;
  final Value<String> userId;
  final Value<String> emailId;
  final Value<String> sender;
  final Value<String> subject;
  final Value<String> snippet;
  final Value<DateTime> receivedAt;
  final Value<String> title;
  final Value<String> description;
  final Value<String> categoryId;
  final Value<int> importance;
  final Value<DateTime?> suggestedDueDate;
  final Value<String> status;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalTaskSuggestionsCompanion({
    this.id = const Value.absent(),
    this.pbId = const Value.absent(),
    this.userId = const Value.absent(),
    this.emailId = const Value.absent(),
    this.sender = const Value.absent(),
    this.subject = const Value.absent(),
    this.snippet = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.importance = const Value.absent(),
    this.suggestedDueDate = const Value.absent(),
    this.status = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalTaskSuggestionsCompanion.insert({
    required String id,
    this.pbId = const Value.absent(),
    required String userId,
    required String emailId,
    required String sender,
    required String subject,
    required String snippet,
    required DateTime receivedAt,
    required String title,
    required String description,
    this.categoryId = const Value.absent(),
    this.importance = const Value.absent(),
    this.suggestedDueDate = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       emailId = Value(emailId),
       sender = Value(sender),
       subject = Value(subject),
       snippet = Value(snippet),
       receivedAt = Value(receivedAt),
       title = Value(title),
       description = Value(description),
       updatedAt = Value(updatedAt);
  static Insertable<LocalTaskSuggestion> custom({
    Expression<String>? id,
    Expression<String>? pbId,
    Expression<String>? userId,
    Expression<String>? emailId,
    Expression<String>? sender,
    Expression<String>? subject,
    Expression<String>? snippet,
    Expression<DateTime>? receivedAt,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? categoryId,
    Expression<int>? importance,
    Expression<DateTime>? suggestedDueDate,
    Expression<String>? status,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pbId != null) 'pb_id': pbId,
      if (userId != null) 'user_id': userId,
      if (emailId != null) 'email_id': emailId,
      if (sender != null) 'sender': sender,
      if (subject != null) 'subject': subject,
      if (snippet != null) 'snippet': snippet,
      if (receivedAt != null) 'received_at': receivedAt,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (categoryId != null) 'category_id': categoryId,
      if (importance != null) 'importance': importance,
      if (suggestedDueDate != null) 'suggested_due_date': suggestedDueDate,
      if (status != null) 'status': status,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalTaskSuggestionsCompanion copyWith({
    Value<String>? id,
    Value<String?>? pbId,
    Value<String>? userId,
    Value<String>? emailId,
    Value<String>? sender,
    Value<String>? subject,
    Value<String>? snippet,
    Value<DateTime>? receivedAt,
    Value<String>? title,
    Value<String>? description,
    Value<String>? categoryId,
    Value<int>? importance,
    Value<DateTime?>? suggestedDueDate,
    Value<String>? status,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalTaskSuggestionsCompanion(
      id: id ?? this.id,
      pbId: pbId ?? this.pbId,
      userId: userId ?? this.userId,
      emailId: emailId ?? this.emailId,
      sender: sender ?? this.sender,
      subject: subject ?? this.subject,
      snippet: snippet ?? this.snippet,
      receivedAt: receivedAt ?? this.receivedAt,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      importance: importance ?? this.importance,
      suggestedDueDate: suggestedDueDate ?? this.suggestedDueDate,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (pbId.present) {
      map['pb_id'] = Variable<String>(pbId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (emailId.present) {
      map['email_id'] = Variable<String>(emailId.value);
    }
    if (sender.present) {
      map['sender'] = Variable<String>(sender.value);
    }
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (snippet.present) {
      map['snippet'] = Variable<String>(snippet.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (importance.present) {
      map['importance'] = Variable<int>(importance.value);
    }
    if (suggestedDueDate.present) {
      map['suggested_due_date'] = Variable<DateTime>(suggestedDueDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalTaskSuggestionsCompanion(')
          ..write('id: $id, ')
          ..write('pbId: $pbId, ')
          ..write('userId: $userId, ')
          ..write('emailId: $emailId, ')
          ..write('sender: $sender, ')
          ..write('subject: $subject, ')
          ..write('snippet: $snippet, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('categoryId: $categoryId, ')
          ..write('importance: $importance, ')
          ..write('suggestedDueDate: $suggestedDueDate, ')
          ..write('status: $status, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxTable extends SyncOutbox
    with TableInfo<$SyncOutboxTable, SyncOutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _collectionNameMeta = const VerificationMeta(
    'collectionName',
  );
  @override
  late final GeneratedColumn<String> collectionName = GeneratedColumn<String>(
    'collection_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordKeyMeta = const VerificationMeta(
    'recordKey',
  );
  @override
  late final GeneratedColumn<String> recordKey = GeneratedColumn<String>(
    'record_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _queuedAtMeta = const VerificationMeta(
    'queuedAt',
  );
  @override
  late final GeneratedColumn<DateTime> queuedAt = GeneratedColumn<DateTime>(
    'queued_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    collectionName,
    recordKey,
    operation,
    payloadJson,
    queuedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('collection_name')) {
      context.handle(
        _collectionNameMeta,
        collectionName.isAcceptableOrUnknown(
          data['collection_name']!,
          _collectionNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectionNameMeta);
    }
    if (data.containsKey('record_key')) {
      context.handle(
        _recordKeyMeta,
        recordKey.isAcceptableOrUnknown(data['record_key']!, _recordKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_recordKeyMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('queued_at')) {
      context.handle(
        _queuedAtMeta,
        queuedAt.isAcceptableOrUnknown(data['queued_at']!, _queuedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_queuedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncOutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      collectionName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_name'],
      )!,
      recordKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_key'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      queuedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}queued_at'],
      )!,
    );
  }

  @override
  $SyncOutboxTable createAlias(String alias) {
    return $SyncOutboxTable(attachedDatabase, alias);
  }
}

class SyncOutboxData extends DataClass implements Insertable<SyncOutboxData> {
  final int id;
  final String userId;
  final String collectionName;
  final String recordKey;
  final String operation;
  final String payloadJson;
  final DateTime queuedAt;
  const SyncOutboxData({
    required this.id,
    required this.userId,
    required this.collectionName,
    required this.recordKey,
    required this.operation,
    required this.payloadJson,
    required this.queuedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['collection_name'] = Variable<String>(collectionName);
    map['record_key'] = Variable<String>(recordKey);
    map['operation'] = Variable<String>(operation);
    map['payload_json'] = Variable<String>(payloadJson);
    map['queued_at'] = Variable<DateTime>(queuedAt);
    return map;
  }

  SyncOutboxCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxCompanion(
      id: Value(id),
      userId: Value(userId),
      collectionName: Value(collectionName),
      recordKey: Value(recordKey),
      operation: Value(operation),
      payloadJson: Value(payloadJson),
      queuedAt: Value(queuedAt),
    );
  }

  factory SyncOutboxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxData(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      collectionName: serializer.fromJson<String>(json['collectionName']),
      recordKey: serializer.fromJson<String>(json['recordKey']),
      operation: serializer.fromJson<String>(json['operation']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      queuedAt: serializer.fromJson<DateTime>(json['queuedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'collectionName': serializer.toJson<String>(collectionName),
      'recordKey': serializer.toJson<String>(recordKey),
      'operation': serializer.toJson<String>(operation),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'queuedAt': serializer.toJson<DateTime>(queuedAt),
    };
  }

  SyncOutboxData copyWith({
    int? id,
    String? userId,
    String? collectionName,
    String? recordKey,
    String? operation,
    String? payloadJson,
    DateTime? queuedAt,
  }) => SyncOutboxData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    collectionName: collectionName ?? this.collectionName,
    recordKey: recordKey ?? this.recordKey,
    operation: operation ?? this.operation,
    payloadJson: payloadJson ?? this.payloadJson,
    queuedAt: queuedAt ?? this.queuedAt,
  );
  SyncOutboxData copyWithCompanion(SyncOutboxCompanion data) {
    return SyncOutboxData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      collectionName: data.collectionName.present
          ? data.collectionName.value
          : this.collectionName,
      recordKey: data.recordKey.present ? data.recordKey.value : this.recordKey,
      operation: data.operation.present ? data.operation.value : this.operation,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      queuedAt: data.queuedAt.present ? data.queuedAt.value : this.queuedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('collectionName: $collectionName, ')
          ..write('recordKey: $recordKey, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('queuedAt: $queuedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    collectionName,
    recordKey,
    operation,
    payloadJson,
    queuedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.collectionName == this.collectionName &&
          other.recordKey == this.recordKey &&
          other.operation == this.operation &&
          other.payloadJson == this.payloadJson &&
          other.queuedAt == this.queuedAt);
}

class SyncOutboxCompanion extends UpdateCompanion<SyncOutboxData> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> collectionName;
  final Value<String> recordKey;
  final Value<String> operation;
  final Value<String> payloadJson;
  final Value<DateTime> queuedAt;
  const SyncOutboxCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.collectionName = const Value.absent(),
    this.recordKey = const Value.absent(),
    this.operation = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.queuedAt = const Value.absent(),
  });
  SyncOutboxCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required String collectionName,
    required String recordKey,
    required String operation,
    required String payloadJson,
    required DateTime queuedAt,
  }) : userId = Value(userId),
       collectionName = Value(collectionName),
       recordKey = Value(recordKey),
       operation = Value(operation),
       payloadJson = Value(payloadJson),
       queuedAt = Value(queuedAt);
  static Insertable<SyncOutboxData> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? collectionName,
    Expression<String>? recordKey,
    Expression<String>? operation,
    Expression<String>? payloadJson,
    Expression<DateTime>? queuedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (collectionName != null) 'collection_name': collectionName,
      if (recordKey != null) 'record_key': recordKey,
      if (operation != null) 'operation': operation,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (queuedAt != null) 'queued_at': queuedAt,
    });
  }

  SyncOutboxCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? collectionName,
    Value<String>? recordKey,
    Value<String>? operation,
    Value<String>? payloadJson,
    Value<DateTime>? queuedAt,
  }) {
    return SyncOutboxCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      collectionName: collectionName ?? this.collectionName,
      recordKey: recordKey ?? this.recordKey,
      operation: operation ?? this.operation,
      payloadJson: payloadJson ?? this.payloadJson,
      queuedAt: queuedAt ?? this.queuedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (collectionName.present) {
      map['collection_name'] = Variable<String>(collectionName.value);
    }
    if (recordKey.present) {
      map['record_key'] = Variable<String>(recordKey.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (queuedAt.present) {
      map['queued_at'] = Variable<DateTime>(queuedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('collectionName: $collectionName, ')
          ..write('recordKey: $recordKey, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('queuedAt: $queuedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalTasksTable localTasks = $LocalTasksTable(this);
  late final $LocalCategoriesTable localCategories = $LocalCategoriesTable(
    this,
  );
  late final $LocalRecurrenceRulesTable localRecurrenceRules =
      $LocalRecurrenceRulesTable(this);
  late final $LocalProfilesTable localProfiles = $LocalProfilesTable(this);
  late final $LocalExternalEventsTable localExternalEvents =
      $LocalExternalEventsTable(this);
  late final $LocalTaskSuggestionsTable localTaskSuggestions =
      $LocalTaskSuggestionsTable(this);
  late final $SyncOutboxTable syncOutbox = $SyncOutboxTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localTasks,
    localCategories,
    localRecurrenceRules,
    localProfiles,
    localExternalEvents,
    localTaskSuggestions,
    syncOutbox,
  ];
}

typedef $$LocalTasksTableCreateCompanionBuilder = LocalTasksCompanion Function({
  required String id,
  Value<String?> pbId,
  required String userId,
  required String title,
  Value<String?> description,
  Value<String> categoryId,
  Value<int> baseImportance,
  Value<int> effectiveImportance,
  Value<DateTime?> dueDate,
  Value<String> status,
  Value<bool> isOverdue,
  required DateTime createdAt,
  Value<DateTime?> completedAt,
  Value<DateTime?> ignoredAt,
  Value<DateTime?> inProgressAt,
  Value<String> attachmentPathsJson,
  Value<String?> recurrenceRuleId,
  Value<String?> calendarEventId,
  Value<String?> emailRefJson,
  Value<String> subtasksJson,
  Value<String?> givenById,
  Value<String?> givenByName,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$LocalTasksTableUpdateCompanionBuilder = LocalTasksCompanion Function({
  Value<String> id,
  Value<String?> pbId,
  Value<String> userId,
  Value<String> title,
  Value<String?> description,
  Value<String> categoryId,
  Value<int> baseImportance,
  Value<int> effectiveImportance,
  Value<DateTime?> dueDate,
  Value<String> status,
  Value<bool> isOverdue,
  Value<DateTime> createdAt,
  Value<DateTime?> completedAt,
  Value<DateTime?> ignoredAt,
  Value<DateTime?> inProgressAt,
  Value<String> attachmentPathsJson,
  Value<String?> recurrenceRuleId,
  Value<String?> calendarEventId,
  Value<String?> emailRefJson,
  Value<String> subtasksJson,
  Value<String?> givenById,
  Value<String?> givenByName,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

class $$LocalTasksTableFilterComposer
    extends Composer<_$AppDatabase, $LocalTasksTable> {
  $$LocalTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pbId => $composableBuilder(
    column: $table.pbId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseImportance => $composableBuilder(
    column: $table.baseImportance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get effectiveImportance => $composableBuilder(
    column: $table.effectiveImportance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOverdue => $composableBuilder(
    column: $table.isOverdue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get ignoredAt => $composableBuilder(
    column: $table.ignoredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get inProgressAt => $composableBuilder(
    column: $table.inProgressAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attachmentPathsJson => $composableBuilder(
    column: $table.attachmentPathsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrenceRuleId => $composableBuilder(
    column: $table.recurrenceRuleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get calendarEventId => $composableBuilder(
    column: $table.calendarEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emailRefJson => $composableBuilder(
    column: $table.emailRefJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtasksJson => $composableBuilder(
    column: $table.subtasksJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get givenById => $composableBuilder(
    column: $table.givenById,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get givenByName => $composableBuilder(
    column: $table.givenByName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalTasksTable> {
  $$LocalTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pbId => $composableBuilder(
    column: $table.pbId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseImportance => $composableBuilder(
    column: $table.baseImportance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get effectiveImportance => $composableBuilder(
    column: $table.effectiveImportance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOverdue => $composableBuilder(
    column: $table.isOverdue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get ignoredAt => $composableBuilder(
    column: $table.ignoredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get inProgressAt => $composableBuilder(
    column: $table.inProgressAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attachmentPathsJson => $composableBuilder(
    column: $table.attachmentPathsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceRuleId => $composableBuilder(
    column: $table.recurrenceRuleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get calendarEventId => $composableBuilder(
    column: $table.calendarEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emailRefJson => $composableBuilder(
    column: $table.emailRefJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtasksJson => $composableBuilder(
    column: $table.subtasksJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get givenById => $composableBuilder(
    column: $table.givenById,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get givenByName => $composableBuilder(
    column: $table.givenByName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalTasksTable> {
  $$LocalTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get pbId =>
      $composableBuilder(column: $table.pbId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get baseImportance => $composableBuilder(
    column: $table.baseImportance,
    builder: (column) => column,
  );

  GeneratedColumn<int> get effectiveImportance => $composableBuilder(
    column: $table.effectiveImportance,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isOverdue =>
      $composableBuilder(column: $table.isOverdue, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get ignoredAt =>
      $composableBuilder(column: $table.ignoredAt, builder: (column) => column);

  GeneratedColumn<DateTime> get inProgressAt => $composableBuilder(
    column: $table.inProgressAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get attachmentPathsJson => $composableBuilder(
    column: $table.attachmentPathsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurrenceRuleId => $composableBuilder(
    column: $table.recurrenceRuleId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get calendarEventId => $composableBuilder(
    column: $table.calendarEventId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get emailRefJson => $composableBuilder(
    column: $table.emailRefJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subtasksJson => $composableBuilder(
    column: $table.subtasksJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get givenById =>
      $composableBuilder(column: $table.givenById, builder: (column) => column);

  GeneratedColumn<String> get givenByName => $composableBuilder(
    column: $table.givenByName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$LocalTasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalTasksTable,
          LocalTask,
          $$LocalTasksTableFilterComposer,
          $$LocalTasksTableOrderingComposer,
          $$LocalTasksTableAnnotationComposer,
          $$LocalTasksTableCreateCompanionBuilder,
          $$LocalTasksTableUpdateCompanionBuilder,
          (
            LocalTask,
            BaseReferences<_$AppDatabase, $LocalTasksTable, LocalTask>,
          ),
          LocalTask,
          PrefetchHooks Function()
        > {
  $$LocalTasksTableTableManager(_$AppDatabase db, $LocalTasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> pbId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<int> baseImportance = const Value.absent(),
                Value<int> effectiveImportance = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> isOverdue = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> ignoredAt = const Value.absent(),
                Value<DateTime?> inProgressAt = const Value.absent(),
                Value<String> attachmentPathsJson = const Value.absent(),
                Value<String?> recurrenceRuleId = const Value.absent(),
                Value<String?> calendarEventId = const Value.absent(),
                Value<String?> emailRefJson = const Value.absent(),
                Value<String> subtasksJson = const Value.absent(),
                Value<String?> givenById = const Value.absent(),
                Value<String?> givenByName = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTasksCompanion(
                id: id,
                pbId: pbId,
                userId: userId,
                title: title,
                description: description,
                categoryId: categoryId,
                baseImportance: baseImportance,
                effectiveImportance: effectiveImportance,
                dueDate: dueDate,
                status: status,
                isOverdue: isOverdue,
                createdAt: createdAt,
                completedAt: completedAt,
                ignoredAt: ignoredAt,
                inProgressAt: inProgressAt,
                attachmentPathsJson: attachmentPathsJson,
                recurrenceRuleId: recurrenceRuleId,
                calendarEventId: calendarEventId,
                emailRefJson: emailRefJson,
                subtasksJson: subtasksJson,
                givenById: givenById,
                givenByName: givenByName,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> pbId = const Value.absent(),
                required String userId,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<int> baseImportance = const Value.absent(),
                Value<int> effectiveImportance = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> isOverdue = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> ignoredAt = const Value.absent(),
                Value<DateTime?> inProgressAt = const Value.absent(),
                Value<String> attachmentPathsJson = const Value.absent(),
                Value<String?> recurrenceRuleId = const Value.absent(),
                Value<String?> calendarEventId = const Value.absent(),
                Value<String?> emailRefJson = const Value.absent(),
                Value<String> subtasksJson = const Value.absent(),
                Value<String?> givenById = const Value.absent(),
                Value<String?> givenByName = const Value.absent(),
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTasksCompanion.insert(
                id: id,
                pbId: pbId,
                userId: userId,
                title: title,
                description: description,
                categoryId: categoryId,
                baseImportance: baseImportance,
                effectiveImportance: effectiveImportance,
                dueDate: dueDate,
                status: status,
                isOverdue: isOverdue,
                createdAt: createdAt,
                completedAt: completedAt,
                ignoredAt: ignoredAt,
                inProgressAt: inProgressAt,
                attachmentPathsJson: attachmentPathsJson,
                recurrenceRuleId: recurrenceRuleId,
                calendarEventId: calendarEventId,
                emailRefJson: emailRefJson,
                subtasksJson: subtasksJson,
                givenById: givenById,
                givenByName: givenByName,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalTasksTable, LocalTask>(table),
                  BaseReferences<_$AppDatabase, $LocalTasksTable, LocalTask>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalTasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalTasksTable,
      LocalTask,
      $$LocalTasksTableFilterComposer,
      $$LocalTasksTableOrderingComposer,
      $$LocalTasksTableAnnotationComposer,
      $$LocalTasksTableCreateCompanionBuilder,
      $$LocalTasksTableUpdateCompanionBuilder,
      (LocalTask, BaseReferences<_$AppDatabase, $LocalTasksTable, LocalTask>),
      LocalTask,
      PrefetchHooks Function()
    >;
typedef $$LocalCategoriesTableCreateCompanionBuilder =
    LocalCategoriesCompanion Function({
      required String id,
      Value<String?> pbId,
      required String userId,
      required String name,
      required int colorValue,
      required String iconName,
      Value<int> sortOrder,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$LocalCategoriesTableUpdateCompanionBuilder =
    LocalCategoriesCompanion Function({
      Value<String> id,
      Value<String?> pbId,
      Value<String> userId,
      Value<String> name,
      Value<int> colorValue,
      Value<String> iconName,
      Value<int> sortOrder,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$LocalCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalCategoriesTable> {
  $$LocalCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pbId => $composableBuilder(
    column: $table.pbId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalCategoriesTable> {
  $$LocalCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pbId => $composableBuilder(
    column: $table.pbId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalCategoriesTable> {
  $$LocalCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get pbId =>
      $composableBuilder(column: $table.pbId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$LocalCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalCategoriesTable,
          LocalCategory,
          $$LocalCategoriesTableFilterComposer,
          $$LocalCategoriesTableOrderingComposer,
          $$LocalCategoriesTableAnnotationComposer,
          $$LocalCategoriesTableCreateCompanionBuilder,
          $$LocalCategoriesTableUpdateCompanionBuilder,
          (
            LocalCategory,
            BaseReferences<_$AppDatabase, $LocalCategoriesTable, LocalCategory>,
          ),
          LocalCategory,
          PrefetchHooks Function()
        > {
  $$LocalCategoriesTableTableManager(
    _$AppDatabase db,
    $LocalCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> pbId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> colorValue = const Value.absent(),
                Value<String> iconName = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCategoriesCompanion(
                id: id,
                pbId: pbId,
                userId: userId,
                name: name,
                colorValue: colorValue,
                iconName: iconName,
                sortOrder: sortOrder,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> pbId = const Value.absent(),
                required String userId,
                required String name,
                required int colorValue,
                required String iconName,
                Value<int> sortOrder = const Value.absent(),
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCategoriesCompanion.insert(
                id: id,
                pbId: pbId,
                userId: userId,
                name: name,
                colorValue: colorValue,
                iconName: iconName,
                sortOrder: sortOrder,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalCategoriesTable, LocalCategory>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalCategoriesTable,
                    LocalCategory
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalCategoriesTable,
      LocalCategory,
      $$LocalCategoriesTableFilterComposer,
      $$LocalCategoriesTableOrderingComposer,
      $$LocalCategoriesTableAnnotationComposer,
      $$LocalCategoriesTableCreateCompanionBuilder,
      $$LocalCategoriesTableUpdateCompanionBuilder,
      (
        LocalCategory,
        BaseReferences<_$AppDatabase, $LocalCategoriesTable, LocalCategory>,
      ),
      LocalCategory,
      PrefetchHooks Function()
    >;
typedef $$LocalRecurrenceRulesTableCreateCompanionBuilder =
    LocalRecurrenceRulesCompanion Function({
      required String id,
      Value<String?> pbId,
      required String userId,
      required String title,
      Value<String?> description,
      required String type,
      Value<int> intervalValue,
      Value<String> intervalUnit,
      Value<bool> afterCompletion,
      Value<String?> frequency,
      Value<String> daysOfWeekJson,
      Value<int?> dayOfMonth,
      Value<String> timeOfDay,
      Value<int> baseImportance,
      Value<String> categoryId,
      Value<DateTime?> lastMissedDueDate,
      required DateTime nextDueAt,
      Value<bool> isActive,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$LocalRecurrenceRulesTableUpdateCompanionBuilder =
    LocalRecurrenceRulesCompanion Function({
      Value<String> id,
      Value<String?> pbId,
      Value<String> userId,
      Value<String> title,
      Value<String?> description,
      Value<String> type,
      Value<int> intervalValue,
      Value<String> intervalUnit,
      Value<bool> afterCompletion,
      Value<String?> frequency,
      Value<String> daysOfWeekJson,
      Value<int?> dayOfMonth,
      Value<String> timeOfDay,
      Value<int> baseImportance,
      Value<String> categoryId,
      Value<DateTime?> lastMissedDueDate,
      Value<DateTime> nextDueAt,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$LocalRecurrenceRulesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalRecurrenceRulesTable> {
  $$LocalRecurrenceRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pbId => $composableBuilder(
    column: $table.pbId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalValue => $composableBuilder(
    column: $table.intervalValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get intervalUnit => $composableBuilder(
    column: $table.intervalUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get afterCompletion => $composableBuilder(
    column: $table.afterCompletion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get daysOfWeekJson => $composableBuilder(
    column: $table.daysOfWeekJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeOfDay => $composableBuilder(
    column: $table.timeOfDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseImportance => $composableBuilder(
    column: $table.baseImportance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastMissedDueDate => $composableBuilder(
    column: $table.lastMissedDueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextDueAt => $composableBuilder(
    column: $table.nextDueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalRecurrenceRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalRecurrenceRulesTable> {
  $$LocalRecurrenceRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pbId => $composableBuilder(
    column: $table.pbId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalValue => $composableBuilder(
    column: $table.intervalValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get intervalUnit => $composableBuilder(
    column: $table.intervalUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get afterCompletion => $composableBuilder(
    column: $table.afterCompletion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get daysOfWeekJson => $composableBuilder(
    column: $table.daysOfWeekJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeOfDay => $composableBuilder(
    column: $table.timeOfDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseImportance => $composableBuilder(
    column: $table.baseImportance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastMissedDueDate => $composableBuilder(
    column: $table.lastMissedDueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextDueAt => $composableBuilder(
    column: $table.nextDueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalRecurrenceRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalRecurrenceRulesTable> {
  $$LocalRecurrenceRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get pbId =>
      $composableBuilder(column: $table.pbId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get intervalValue => $composableBuilder(
    column: $table.intervalValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get intervalUnit => $composableBuilder(
    column: $table.intervalUnit,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get afterCompletion => $composableBuilder(
    column: $table.afterCompletion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<String> get daysOfWeekJson => $composableBuilder(
    column: $table.daysOfWeekJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timeOfDay =>
      $composableBuilder(column: $table.timeOfDay, builder: (column) => column);

  GeneratedColumn<int> get baseImportance => $composableBuilder(
    column: $table.baseImportance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastMissedDueDate => $composableBuilder(
    column: $table.lastMissedDueDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextDueAt =>
      $composableBuilder(column: $table.nextDueAt, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$LocalRecurrenceRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalRecurrenceRulesTable,
          LocalRecurrenceRule,
          $$LocalRecurrenceRulesTableFilterComposer,
          $$LocalRecurrenceRulesTableOrderingComposer,
          $$LocalRecurrenceRulesTableAnnotationComposer,
          $$LocalRecurrenceRulesTableCreateCompanionBuilder,
          $$LocalRecurrenceRulesTableUpdateCompanionBuilder,
          (
            LocalRecurrenceRule,
            BaseReferences<
              _$AppDatabase,
              $LocalRecurrenceRulesTable,
              LocalRecurrenceRule
            >,
          ),
          LocalRecurrenceRule,
          PrefetchHooks Function()
        > {
  $$LocalRecurrenceRulesTableTableManager(
    _$AppDatabase db,
    $LocalRecurrenceRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalRecurrenceRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalRecurrenceRulesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalRecurrenceRulesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> pbId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> intervalValue = const Value.absent(),
                Value<String> intervalUnit = const Value.absent(),
                Value<bool> afterCompletion = const Value.absent(),
                Value<String?> frequency = const Value.absent(),
                Value<String> daysOfWeekJson = const Value.absent(),
                Value<int?> dayOfMonth = const Value.absent(),
                Value<String> timeOfDay = const Value.absent(),
                Value<int> baseImportance = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<DateTime?> lastMissedDueDate = const Value.absent(),
                Value<DateTime> nextDueAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalRecurrenceRulesCompanion(
                id: id,
                pbId: pbId,
                userId: userId,
                title: title,
                description: description,
                type: type,
                intervalValue: intervalValue,
                intervalUnit: intervalUnit,
                afterCompletion: afterCompletion,
                frequency: frequency,
                daysOfWeekJson: daysOfWeekJson,
                dayOfMonth: dayOfMonth,
                timeOfDay: timeOfDay,
                baseImportance: baseImportance,
                categoryId: categoryId,
                lastMissedDueDate: lastMissedDueDate,
                nextDueAt: nextDueAt,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> pbId = const Value.absent(),
                required String userId,
                required String title,
                Value<String?> description = const Value.absent(),
                required String type,
                Value<int> intervalValue = const Value.absent(),
                Value<String> intervalUnit = const Value.absent(),
                Value<bool> afterCompletion = const Value.absent(),
                Value<String?> frequency = const Value.absent(),
                Value<String> daysOfWeekJson = const Value.absent(),
                Value<int?> dayOfMonth = const Value.absent(),
                Value<String> timeOfDay = const Value.absent(),
                Value<int> baseImportance = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<DateTime?> lastMissedDueDate = const Value.absent(),
                required DateTime nextDueAt,
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalRecurrenceRulesCompanion.insert(
                id: id,
                pbId: pbId,
                userId: userId,
                title: title,
                description: description,
                type: type,
                intervalValue: intervalValue,
                intervalUnit: intervalUnit,
                afterCompletion: afterCompletion,
                frequency: frequency,
                daysOfWeekJson: daysOfWeekJson,
                dayOfMonth: dayOfMonth,
                timeOfDay: timeOfDay,
                baseImportance: baseImportance,
                categoryId: categoryId,
                lastMissedDueDate: lastMissedDueDate,
                nextDueAt: nextDueAt,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalRecurrenceRulesTable, LocalRecurrenceRule>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalRecurrenceRulesTable,
                    LocalRecurrenceRule
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalRecurrenceRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalRecurrenceRulesTable,
      LocalRecurrenceRule,
      $$LocalRecurrenceRulesTableFilterComposer,
      $$LocalRecurrenceRulesTableOrderingComposer,
      $$LocalRecurrenceRulesTableAnnotationComposer,
      $$LocalRecurrenceRulesTableCreateCompanionBuilder,
      $$LocalRecurrenceRulesTableUpdateCompanionBuilder,
      (
        LocalRecurrenceRule,
        BaseReferences<
          _$AppDatabase,
          $LocalRecurrenceRulesTable,
          LocalRecurrenceRule
        >,
      ),
      LocalRecurrenceRule,
      PrefetchHooks Function()
    >;
typedef $$LocalProfilesTableCreateCompanionBuilder =
    LocalProfilesCompanion Function({
      required String userId,
      Value<String?> pbId,
      required String profileJson,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalProfilesTableUpdateCompanionBuilder =
    LocalProfilesCompanion Function({
      Value<String> userId,
      Value<String?> pbId,
      Value<String> profileJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalProfilesTable> {
  $$LocalProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pbId => $composableBuilder(
    column: $table.pbId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileJson => $composableBuilder(
    column: $table.profileJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalProfilesTable> {
  $$LocalProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pbId => $composableBuilder(
    column: $table.pbId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileJson => $composableBuilder(
    column: $table.profileJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalProfilesTable> {
  $$LocalProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get pbId =>
      $composableBuilder(column: $table.pbId, builder: (column) => column);

  GeneratedColumn<String> get profileJson => $composableBuilder(
    column: $table.profileJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalProfilesTable,
          LocalProfile,
          $$LocalProfilesTableFilterComposer,
          $$LocalProfilesTableOrderingComposer,
          $$LocalProfilesTableAnnotationComposer,
          $$LocalProfilesTableCreateCompanionBuilder,
          $$LocalProfilesTableUpdateCompanionBuilder,
          (
            LocalProfile,
            BaseReferences<_$AppDatabase, $LocalProfilesTable, LocalProfile>,
          ),
          LocalProfile,
          PrefetchHooks Function()
        > {
  $$LocalProfilesTableTableManager(_$AppDatabase db, $LocalProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String?> pbId = const Value.absent(),
                Value<String> profileJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalProfilesCompanion(
                userId: userId,
                pbId: pbId,
                profileJson: profileJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                Value<String?> pbId = const Value.absent(),
                required String profileJson,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalProfilesCompanion.insert(
                userId: userId,
                pbId: pbId,
                profileJson: profileJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalProfilesTable, LocalProfile>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalProfilesTable,
                    LocalProfile
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalProfilesTable,
      LocalProfile,
      $$LocalProfilesTableFilterComposer,
      $$LocalProfilesTableOrderingComposer,
      $$LocalProfilesTableAnnotationComposer,
      $$LocalProfilesTableCreateCompanionBuilder,
      $$LocalProfilesTableUpdateCompanionBuilder,
      (
        LocalProfile,
        BaseReferences<_$AppDatabase, $LocalProfilesTable, LocalProfile>,
      ),
      LocalProfile,
      PrefetchHooks Function()
    >;
typedef $$LocalExternalEventsTableCreateCompanionBuilder =
    LocalExternalEventsCompanion Function({
      required String id,
      Value<String?> pbId,
      required String userId,
      required String externalId,
      required String source,
      required String title,
      required DateTime startTime,
      required DateTime endTime,
      Value<String> location,
      Value<String> description,
      Value<String?> meetingUrl,
      Value<String> attendeesJson,
      Value<bool> hasLinkedTask,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalExternalEventsTableUpdateCompanionBuilder =
    LocalExternalEventsCompanion Function({
      Value<String> id,
      Value<String?> pbId,
      Value<String> userId,
      Value<String> externalId,
      Value<String> source,
      Value<String> title,
      Value<DateTime> startTime,
      Value<DateTime> endTime,
      Value<String> location,
      Value<String> description,
      Value<String?> meetingUrl,
      Value<String> attendeesJson,
      Value<bool> hasLinkedTask,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalExternalEventsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalExternalEventsTable> {
  $$LocalExternalEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pbId => $composableBuilder(
    column: $table.pbId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meetingUrl => $composableBuilder(
    column: $table.meetingUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attendeesJson => $composableBuilder(
    column: $table.attendeesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasLinkedTask => $composableBuilder(
    column: $table.hasLinkedTask,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalExternalEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalExternalEventsTable> {
  $$LocalExternalEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pbId => $composableBuilder(
    column: $table.pbId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meetingUrl => $composableBuilder(
    column: $table.meetingUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attendeesJson => $composableBuilder(
    column: $table.attendeesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasLinkedTask => $composableBuilder(
    column: $table.hasLinkedTask,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalExternalEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalExternalEventsTable> {
  $$LocalExternalEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get pbId =>
      $composableBuilder(column: $table.pbId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get meetingUrl => $composableBuilder(
    column: $table.meetingUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get attendeesJson => $composableBuilder(
    column: $table.attendeesJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasLinkedTask => $composableBuilder(
    column: $table.hasLinkedTask,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalExternalEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalExternalEventsTable,
          LocalExternalEvent,
          $$LocalExternalEventsTableFilterComposer,
          $$LocalExternalEventsTableOrderingComposer,
          $$LocalExternalEventsTableAnnotationComposer,
          $$LocalExternalEventsTableCreateCompanionBuilder,
          $$LocalExternalEventsTableUpdateCompanionBuilder,
          (
            LocalExternalEvent,
            BaseReferences<
              _$AppDatabase,
              $LocalExternalEventsTable,
              LocalExternalEvent
            >,
          ),
          LocalExternalEvent,
          PrefetchHooks Function()
        > {
  $$LocalExternalEventsTableTableManager(
    _$AppDatabase db,
    $LocalExternalEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalExternalEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalExternalEventsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalExternalEventsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> pbId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> externalId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> startTime = const Value.absent(),
                Value<DateTime> endTime = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String?> meetingUrl = const Value.absent(),
                Value<String> attendeesJson = const Value.absent(),
                Value<bool> hasLinkedTask = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalExternalEventsCompanion(
                id: id,
                pbId: pbId,
                userId: userId,
                externalId: externalId,
                source: source,
                title: title,
                startTime: startTime,
                endTime: endTime,
                location: location,
                description: description,
                meetingUrl: meetingUrl,
                attendeesJson: attendeesJson,
                hasLinkedTask: hasLinkedTask,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> pbId = const Value.absent(),
                required String userId,
                required String externalId,
                required String source,
                required String title,
                required DateTime startTime,
                required DateTime endTime,
                Value<String> location = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String?> meetingUrl = const Value.absent(),
                Value<String> attendeesJson = const Value.absent(),
                Value<bool> hasLinkedTask = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalExternalEventsCompanion.insert(
                id: id,
                pbId: pbId,
                userId: userId,
                externalId: externalId,
                source: source,
                title: title,
                startTime: startTime,
                endTime: endTime,
                location: location,
                description: description,
                meetingUrl: meetingUrl,
                attendeesJson: attendeesJson,
                hasLinkedTask: hasLinkedTask,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalExternalEventsTable, LocalExternalEvent>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalExternalEventsTable,
                    LocalExternalEvent
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalExternalEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalExternalEventsTable,
      LocalExternalEvent,
      $$LocalExternalEventsTableFilterComposer,
      $$LocalExternalEventsTableOrderingComposer,
      $$LocalExternalEventsTableAnnotationComposer,
      $$LocalExternalEventsTableCreateCompanionBuilder,
      $$LocalExternalEventsTableUpdateCompanionBuilder,
      (
        LocalExternalEvent,
        BaseReferences<
          _$AppDatabase,
          $LocalExternalEventsTable,
          LocalExternalEvent
        >,
      ),
      LocalExternalEvent,
      PrefetchHooks Function()
    >;
typedef $$LocalTaskSuggestionsTableCreateCompanionBuilder =
    LocalTaskSuggestionsCompanion Function({
      required String id,
      Value<String?> pbId,
      required String userId,
      required String emailId,
      required String sender,
      required String subject,
      required String snippet,
      required DateTime receivedAt,
      required String title,
      required String description,
      Value<String> categoryId,
      Value<int> importance,
      Value<DateTime?> suggestedDueDate,
      Value<String> status,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalTaskSuggestionsTableUpdateCompanionBuilder =
    LocalTaskSuggestionsCompanion Function({
      Value<String> id,
      Value<String?> pbId,
      Value<String> userId,
      Value<String> emailId,
      Value<String> sender,
      Value<String> subject,
      Value<String> snippet,
      Value<DateTime> receivedAt,
      Value<String> title,
      Value<String> description,
      Value<String> categoryId,
      Value<int> importance,
      Value<DateTime?> suggestedDueDate,
      Value<String> status,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalTaskSuggestionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalTaskSuggestionsTable> {
  $$LocalTaskSuggestionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pbId => $composableBuilder(
    column: $table.pbId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emailId => $composableBuilder(
    column: $table.emailId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sender => $composableBuilder(
    column: $table.sender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snippet => $composableBuilder(
    column: $table.snippet,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get importance => $composableBuilder(
    column: $table.importance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get suggestedDueDate => $composableBuilder(
    column: $table.suggestedDueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalTaskSuggestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalTaskSuggestionsTable> {
  $$LocalTaskSuggestionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pbId => $composableBuilder(
    column: $table.pbId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emailId => $composableBuilder(
    column: $table.emailId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sender => $composableBuilder(
    column: $table.sender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snippet => $composableBuilder(
    column: $table.snippet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get importance => $composableBuilder(
    column: $table.importance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get suggestedDueDate => $composableBuilder(
    column: $table.suggestedDueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalTaskSuggestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalTaskSuggestionsTable> {
  $$LocalTaskSuggestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get pbId =>
      $composableBuilder(column: $table.pbId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get emailId =>
      $composableBuilder(column: $table.emailId, builder: (column) => column);

  GeneratedColumn<String> get sender =>
      $composableBuilder(column: $table.sender, builder: (column) => column);

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get snippet =>
      $composableBuilder(column: $table.snippet, builder: (column) => column);

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get importance => $composableBuilder(
    column: $table.importance,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get suggestedDueDate => $composableBuilder(
    column: $table.suggestedDueDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalTaskSuggestionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalTaskSuggestionsTable,
          LocalTaskSuggestion,
          $$LocalTaskSuggestionsTableFilterComposer,
          $$LocalTaskSuggestionsTableOrderingComposer,
          $$LocalTaskSuggestionsTableAnnotationComposer,
          $$LocalTaskSuggestionsTableCreateCompanionBuilder,
          $$LocalTaskSuggestionsTableUpdateCompanionBuilder,
          (
            LocalTaskSuggestion,
            BaseReferences<
              _$AppDatabase,
              $LocalTaskSuggestionsTable,
              LocalTaskSuggestion
            >,
          ),
          LocalTaskSuggestion,
          PrefetchHooks Function()
        > {
  $$LocalTaskSuggestionsTableTableManager(
    _$AppDatabase db,
    $LocalTaskSuggestionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalTaskSuggestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalTaskSuggestionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalTaskSuggestionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> pbId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> emailId = const Value.absent(),
                Value<String> sender = const Value.absent(),
                Value<String> subject = const Value.absent(),
                Value<String> snippet = const Value.absent(),
                Value<DateTime> receivedAt = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<int> importance = const Value.absent(),
                Value<DateTime?> suggestedDueDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTaskSuggestionsCompanion(
                id: id,
                pbId: pbId,
                userId: userId,
                emailId: emailId,
                sender: sender,
                subject: subject,
                snippet: snippet,
                receivedAt: receivedAt,
                title: title,
                description: description,
                categoryId: categoryId,
                importance: importance,
                suggestedDueDate: suggestedDueDate,
                status: status,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> pbId = const Value.absent(),
                required String userId,
                required String emailId,
                required String sender,
                required String subject,
                required String snippet,
                required DateTime receivedAt,
                required String title,
                required String description,
                Value<String> categoryId = const Value.absent(),
                Value<int> importance = const Value.absent(),
                Value<DateTime?> suggestedDueDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalTaskSuggestionsCompanion.insert(
                id: id,
                pbId: pbId,
                userId: userId,
                emailId: emailId,
                sender: sender,
                subject: subject,
                snippet: snippet,
                receivedAt: receivedAt,
                title: title,
                description: description,
                categoryId: categoryId,
                importance: importance,
                suggestedDueDate: suggestedDueDate,
                status: status,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalTaskSuggestionsTable, LocalTaskSuggestion>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalTaskSuggestionsTable,
                    LocalTaskSuggestion
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalTaskSuggestionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalTaskSuggestionsTable,
      LocalTaskSuggestion,
      $$LocalTaskSuggestionsTableFilterComposer,
      $$LocalTaskSuggestionsTableOrderingComposer,
      $$LocalTaskSuggestionsTableAnnotationComposer,
      $$LocalTaskSuggestionsTableCreateCompanionBuilder,
      $$LocalTaskSuggestionsTableUpdateCompanionBuilder,
      (
        LocalTaskSuggestion,
        BaseReferences<
          _$AppDatabase,
          $LocalTaskSuggestionsTable,
          LocalTaskSuggestion
        >,
      ),
      LocalTaskSuggestion,
      PrefetchHooks Function()
    >;
typedef $$SyncOutboxTableCreateCompanionBuilder = SyncOutboxCompanion Function({
  Value<int> id,
  required String userId,
  required String collectionName,
  required String recordKey,
  required String operation,
  required String payloadJson,
  required DateTime queuedAt,
});
typedef $$SyncOutboxTableUpdateCompanionBuilder = SyncOutboxCompanion Function({
  Value<int> id,
  Value<String> userId,
  Value<String> collectionName,
  Value<String> recordKey,
  Value<String> operation,
  Value<String> payloadJson,
  Value<DateTime> queuedAt,
});

class $$SyncOutboxTableFilterComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectionName => $composableBuilder(
    column: $table.collectionName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordKey => $composableBuilder(
    column: $table.recordKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get queuedAt => $composableBuilder(
    column: $table.queuedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncOutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectionName => $composableBuilder(
    column: $table.collectionName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordKey => $composableBuilder(
    column: $table.recordKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get queuedAt => $composableBuilder(
    column: $table.queuedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncOutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get collectionName => $composableBuilder(
    column: $table.collectionName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recordKey =>
      $composableBuilder(column: $table.recordKey, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get queuedAt =>
      $composableBuilder(column: $table.queuedAt, builder: (column) => column);
}

class $$SyncOutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncOutboxTable,
          SyncOutboxData,
          $$SyncOutboxTableFilterComposer,
          $$SyncOutboxTableOrderingComposer,
          $$SyncOutboxTableAnnotationComposer,
          $$SyncOutboxTableCreateCompanionBuilder,
          $$SyncOutboxTableUpdateCompanionBuilder,
          (
            SyncOutboxData,
            BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxData>,
          ),
          SyncOutboxData,
          PrefetchHooks Function()
        > {
  $$SyncOutboxTableTableManager(_$AppDatabase db, $SyncOutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> collectionName = const Value.absent(),
                Value<String> recordKey = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> queuedAt = const Value.absent(),
              }) => SyncOutboxCompanion(
                id: id,
                userId: userId,
                collectionName: collectionName,
                recordKey: recordKey,
                operation: operation,
                payloadJson: payloadJson,
                queuedAt: queuedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                required String collectionName,
                required String recordKey,
                required String operation,
                required String payloadJson,
                required DateTime queuedAt,
              }) => SyncOutboxCompanion.insert(
                id: id,
                userId: userId,
                collectionName: collectionName,
                recordKey: recordKey,
                operation: operation,
                payloadJson: payloadJson,
                queuedAt: queuedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncOutboxTable, SyncOutboxData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SyncOutboxTable,
                    SyncOutboxData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncOutboxTable,
      SyncOutboxData,
      $$SyncOutboxTableFilterComposer,
      $$SyncOutboxTableOrderingComposer,
      $$SyncOutboxTableAnnotationComposer,
      $$SyncOutboxTableCreateCompanionBuilder,
      $$SyncOutboxTableUpdateCompanionBuilder,
      (
        SyncOutboxData,
        BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxData>,
      ),
      SyncOutboxData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalTasksTableTableManager get localTasks =>
      $$LocalTasksTableTableManager(_db, _db.localTasks);
  $$LocalCategoriesTableTableManager get localCategories =>
      $$LocalCategoriesTableTableManager(_db, _db.localCategories);
  $$LocalRecurrenceRulesTableTableManager get localRecurrenceRules =>
      $$LocalRecurrenceRulesTableTableManager(_db, _db.localRecurrenceRules);
  $$LocalProfilesTableTableManager get localProfiles =>
      $$LocalProfilesTableTableManager(_db, _db.localProfiles);
  $$LocalExternalEventsTableTableManager get localExternalEvents =>
      $$LocalExternalEventsTableTableManager(_db, _db.localExternalEvents);
  $$LocalTaskSuggestionsTableTableManager get localTaskSuggestions =>
      $$LocalTaskSuggestionsTableTableManager(_db, _db.localTaskSuggestions);
  $$SyncOutboxTableTableManager get syncOutbox =>
      $$SyncOutboxTableTableManager(_db, _db.syncOutbox);
}
