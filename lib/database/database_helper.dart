import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('calendar.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    print('=== 数据库初始化信息 ===');
    print('开始初始化数据库');
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    print('📂 数据库路径: $path');
    print('==================');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        print('创建数据库表');
        await _createDB(db, version);
        print('数据库表创建完成');
      },
      onOpen: (db) {
        print('数据库已打开');
      },
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE events(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        color INTEGER
      )
    ''');
  }

  Future<int> insertEvent(Map<String, dynamic> event) async {
    print('DatabaseHelper: 开始插入事件: $event');
    final db = await database;
    final result = await db.insert('events', event);
    print('DatabaseHelper: 插入结果ID: $result');
    return result;
  }

  Future<List<Map<String, dynamic>>> getEvents(String date) async {
    print('DatabaseHelper: 开始查询日期 $date 的事件');
    final db = await database;
    print('DatabaseHelper: 查询条件 date = $date');
    final result = await db.query(
      'events',
      where: 'date LIKE ?',
      whereArgs: ['$date%'],
    );
    print('DatabaseHelper: 查询结果: $result');
    return result;
  }

  Future<int> updateEvent(Map<String, dynamic> event) async {
    final db = await database;
    return await db.update(
      'events',
      event,
      where: 'id = ?',
      whereArgs: [event['id']],
    );
  }

  Future<int> deleteEvent(int id) async {
    final db = await database;
    return await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
