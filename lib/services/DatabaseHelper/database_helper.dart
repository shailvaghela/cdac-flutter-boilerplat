import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'user_profile.db');
    //debugPrint("dbPath----$path");//----/data/user/0/com.example.myprofile/databases/user_profile.db
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user_profile (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            dob TEXT,
            contact TEXT,
            gender TEXT,
            address TEXT,
            education TEXT,
            profilePic TEXT,
            latlong TEXT,
            currentlocation TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertUserProfile(Map<String, dynamic> userProfile) async {
    final db = await database;
    await db.insert('user_profile', userProfile);
  }

  Future<List<Map<String, dynamic>>> getUserProfiles() async {
    final db = await database;
    return await db.query('user_profile');
  }

  Future<void> deleteUserProfile(int id) async {
    final db = await database;
    await db.delete(
      'user_profile',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateUserProfile(Map<String, dynamic> userProfile) async {
    final db = await database;
    await db.update(
      'user_profile',
      userProfile,
      where: 'id = ?',
      whereArgs: [
        userProfile['id']
      ], // Use the ID to identify which record to update
    );
  }
}
