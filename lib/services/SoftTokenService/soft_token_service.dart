import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class SoftTokenGenerateService {
  static const String _tokenTable = 'soft_token';
  late Database _database;

  // Initialize the database
  Future<void> initDb() async {
    _database = await openDatabase(
      'app_data.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tokenTable(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            token TEXT,
            expiryTime INTEGER
          )
        ''');
      },
    );
  }

  // Generate a new soft token and store it in SQLite
  Future<String> generateSoftToken() async {
    // Create a unique soft token (16-character string)
    String token = Uuid().v4().substring(0, 16); // Get first 16 characters of UUID

    // Set token expiry time (e.g., 5 minutes from now)
    int expiryTime = DateTime.now().add(Duration(minutes: 5)).millisecondsSinceEpoch;

    // Store the token and expiry time in SQLite
    await _storeToken(token, expiryTime);

    return token;
  }

  // Store the soft token and expiry time in the database
  Future<void> _storeToken(String token, int expiryTime) async {
    await _database.insert(
      _tokenTable,
      {'token': token, 'expiryTime': expiryTime},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch the stored token from SQLite
  Future<Map<String, dynamic>?> getStoredToken() async {
    List<Map<String, dynamic>> result = await _database.query(_tokenTable);
    
    // If token exists and hasn't expired
    if (result.isNotEmpty) {
      Map<String, dynamic> tokenData = result.first;
      int expiryTime = tokenData['expiryTime'];
      if (expiryTime > DateTime.now().millisecondsSinceEpoch) {
        return tokenData;
      }
    }

    return null; // No valid token found
  }

  // Remove the token if it's expired or after successful sync
  Future<void> removeToken() async {
    await _database.delete(_tokenTable);
  }
}
