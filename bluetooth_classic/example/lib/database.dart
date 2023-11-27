import 'dart:io';

import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:drift/drift.dart';

part 'database.g.dart';

class PreviousRecord extends Table {
  //format
  //date: 2023-11-12
  //brushingTime: 2:13
  //sectionRatio: 12.32:87.68
  //brushingMethod: 12.41%
  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text().withLength(min: 7, max: 11)();
  TextColumn get brushingTime => text().withLength(min: 3, max: 6)();
  TextColumn get sectionRatio => text().withLength(min: 3, max: 15)();
  TextColumn get brushingMethod => text().withLength(min: 1, max: 8)();
}

@DriftDatabase(tables: [PreviousRecord])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}