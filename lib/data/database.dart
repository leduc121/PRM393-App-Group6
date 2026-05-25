import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class Products extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get category => text()();
  RealColumn get price => real()();
  RealColumn get originalPrice => real()();
  RealColumn get rating => real()();
  IntColumn get reviewCount => integer()();
  TextColumn get description => text()();
  TextColumn get specs => text()();
  TextColumn get imageName => text()();
  TextColumn get tag => text()();
  IntColumn get stock => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class CartItems extends Table {
  IntColumn get productId => integer()();
  IntColumn get quantity => integer()();

  @override
  Set<Column> get primaryKey => {productId};
}

class Orders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get timestamp => integer()();
  RealColumn get totalAmount => real()();
  TextColumn get itemDetails => text()();
  TextColumn get status => text()();
  TextColumn get deliveryAddress => text()();
  TextColumn get paymentMethod => text()();
}

class ChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sender => text()(); // "user" or "shop"
  TextColumn get message => text()();
  IntColumn get timestamp => integer()();
}

class Notifications extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get message => text()();
  IntColumn get timestamp => integer()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Products, CartItems, Orders, ChatMessages, Notifications])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'aerosport_shop_database.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
