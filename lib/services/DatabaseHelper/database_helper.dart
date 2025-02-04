import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_demo/services/LogService/log_service_new.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/state_district/state_district.dart';

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
      version: 5,
      onCreate: (db, version) async {
        await db.execute('PRAGMA foreign_keys = ON;');

        await db.execute('''
          CREATE TABLE user_profile (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            firstname TEXT,
            middlename TEXT,
            lastname TEXT,
            state TEXT,
            district TEXT,
            dob TEXT,
            contact TEXT,
            gender TEXT,
            address TEXT,
            education TEXT,
            pinCode TEXT,
            profilePic TEXT,
            latlong TEXT,
            currentlocation TEXT
          )
        ''');

        LogServiceNew.logToFile(
          message: "Created Table user_profile",
          screenName: "Database Helper",
          methodName: "initDB",
          level: Level.debug,
        );

        await db.execute('''
          CREATE TABLE user_login (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            accessToken TEXT UNIQUE NOT NULL,
            refreshToken TEXT UNIQUE NOT NULL,
            encryptionKey TEXT UNIQUE NOT NULL
          )
        ''');
        LogServiceNew.logToFile(
          message: "Created Table user_login",
          screenName: "Database Helper",
          methodName: "initDB",
          level: Level.debug,
        );

        // await db.execute('''
        //   CREATE TABLE soft_token(
        //     id INTEGER PRIMARY KEY AUTOINCREMENT,
        //     token TEXT,
        //     expiryTime INTEGER
        //   )
        // ''');
        // LogServiceNew.logToFile(
        //   message: "Created Table user_profile",
        //   screenName: "Database Helper",
        //   methodName: "initDB",
        //   level: Level.debug,
        // );

        await db.execute('''
          CREATE TABLE geo_picture(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            picture TEXT,
            currentlocation TEXT
          )
        ''');
        LogServiceNew.logToFile(
          message: "Created Table geo_picture",
          screenName: "Database Helper",
          methodName: "initDB",
          level: Level.debug,
        );

        await db.execute('''
          CREATE TABLE state_district (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            state TEXT,
            district TEXT
          )
        ''');
        LogServiceNew.logToFile(
          message: "Created Table state_district",
          screenName: "Database Helper",
          methodName: "initDB",
          level: Level.debug,
        );
      },
    );
  }

  // Insert data into the database
  Future<void> insertDistricts(List<District> districts) async {
    try {
      final db = await database;

      LogServiceNew.logToFile(
        message: "Inserting district",
        screenName: "Database Helper",
        methodName: "insertDistricts",
        level: Level.debug,
        // stackTrace: "$stackTrace",
      );

      // Insert each district into the database
      for (var district in districts) {
        await db.insert(
          "state_district",
          district.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      LogServiceNew.logToFile(
        message: "Inserted district successfully",
        screenName: "Database Helper",
        methodName: "insertDistricts",
        level: Level.debug,
        // stackTrace: "$stackTrace",
      );
    } catch (e, stackTrace) {
      LogServiceNew.logToFile(
        message: "Error while inserting district : $e",
        screenName: "Database Helper",
        methodName: "insertDistricts",
        level: Level.error,
        stackTrace: "$stackTrace",
      );
    }
  }

  // Get a list of distinct states
  Future<List<String>> getDistinctStates() async {
    try {
      final db = await database;
      LogServiceNew.logToFile(
        message: "getting distinct states",
        screenName: "Database Helper",
        methodName: "getDistinctStates",
        level: Level.debug,
        // stackTrace: "$stackTrace",
      );

      // Query the database for distinct states
      List<Map<String, dynamic>> maps =
          await db.rawQuery('SELECT DISTINCT state FROM "state_district"');

      LogServiceNew.logToFile(
        message: "Got distinct states",
        screenName: "Database Helper",
        methodName: "getDistinctStates",
        level: Level.debug,
        stackTrace: "$maps",
      );

      // Convert the result into a list of distinct state names
      return List.generate(maps.length, (i) {
        return maps[i]['state'] as String;
      });
    } catch (e, stackTrace) {
      LogServiceNew.logToFile(
        message: "Error while getting distinct states : $e",
        screenName: "Database Helper",
        methodName: "getDistinctStates",
        level: Level.error,
        stackTrace: "$stackTrace",
      );

      return [];
    }
  }

  // Get districts filtered by state
  Future<List<District>> getDistrictsByState(String state) async {
    try {
      final db = await database;

      LogServiceNew.logToFile(
        message: "getting districts by state $state",
        screenName: "Database Helper",
        methodName: "getDistrictsByState",
        level: Level.debug,
        // stackTrace: "$stackTrace",
      );

      // Query the database for districts in the specified state
      List<Map<String, dynamic>> maps = await db.query(
        "state_district",
        where: 'state = ?',
        whereArgs: [state],
      );
      LogServiceNew.logToFile(
        message: "Got districts by state $state",
        screenName: "Database Helper",
        methodName: "getDistrictsByState",
        level: Level.debug,
        stackTrace: "$maps",
      );

      // Convert the query result into a list of District objects
      return List.generate(maps.length, (i) {
        return District(
          state: maps[i]['state'],
          district: maps[i]['district'],
        );
      });
    } catch (e, stackTrace) {
      LogServiceNew.logToFile(
        message: "Error while getting districts by state $state",
        screenName: "Database Helper",
        methodName: "getDistrictsByState",
        level: Level.debug,
        stackTrace: "$stackTrace",
      );
      return [];
    }
  }

  Future<List<String>> getDistrictsByStateDB(String state) async {
    try {
      final db = await database;

      LogServiceNew.logToFile(
        message: "getting districts by state $state",
        screenName: "Database Helper",
        methodName: "getDistrictsByStateDB",
        level: Level.debug,
        // stackTrace: "$stackTrace",
      );

      // Query the database for districts in the specified state
      List<Map<String, dynamic>> maps = await db.query(
        "state_district",
        where: 'state = ?',
        whereArgs: [state],
      );
      LogServiceNew.logToFile(
        message: "Got districts by state $state",
        screenName: "Database Helper",
        methodName: "getDistrictsByStateDB",
        level: Level.debug,
        stackTrace: "$maps",
      );

      /// Convert the query result into a list of district names (strings)
      return List.generate(maps.length, (i) {
        return maps[i]['district']; // Return just the district name as a string
      });
    } catch (e, stackTrace) {
      LogServiceNew.logToFile(
        message: "Error while getting districts by state $state",
        screenName: "Database Helper",
        methodName: "getDistrictsByStateDB",
        level: Level.debug,
        stackTrace: "$stackTrace",
      );
      return [];
    }
  }

  Future<void> insertGeoPicture(String picture, String currentlocation) async {
    final db = await database;
    await db.insert(
      'geo_picture',
      {'picture': picture, 'currentlocation': currentlocation},
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

  Future<List<Map<String, dynamic>>> getUGeoPictures() async {
    final db = await database;
    return await db.query('geo_picture');
  }

  Future<void> deleteUserProfile(int id) async {
    final db = await database;
    await db.delete(
      'user_profile',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // // Store the soft token and expiry time in the database
  // Future<void> storeToken(String token, int expiryTime) async {
  //   try {
  //     final db = await database;
  //     await db.insert(
  //       'soft_token',
  //       {'token': token, 'expiryTime': expiryTime},
  //       conflictAlgorithm: ConflictAlgorithm.replace,
  //     );

  //     if (kDebugMode) {
  //       log("Token stored in database");
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       log("Can not insert soft token");
  //       log(e.toString());
  //       debugPrintStack();
  //     }
  //   }
  // }

  // Future<Map<String, dynamic>?> getStoredToken() async {
  //   try {
  //     final db = await database;
  //     List<Map<String, dynamic>> result = await db.query('soft_token');

  //     // If token exists and hasn't expired
  //     if (result.isNotEmpty) {
  //       Map<String, dynamic> tokenData = result.first;
  //       int expiryTime = tokenData['expiryTime'];
  //       if (expiryTime > DateTime.now().millisecondsSinceEpoch) {
  //         return tokenData;
  //       }
  //     }
  //     return null;
  //   } catch (e) {
  //     if (kDebugMode) {
  //       log("Can not insert soft token");
  //       log(e.toString());
  //       debugPrintStack();
  //     }
  //     return null;
  //   }
  // }

  // Remove the token if it's expired or after successful sync
  Future<void> removeToken() async {
    try {
      final db = await database;
      await db.delete('soft_token');
    } catch (e) {
      if (kDebugMode) {
        log("Can not insert soft token");
        log(e.toString());
        debugPrintStack();
      }
    }
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

  Future<String> insertUserLoginDetails(
      String encryptedUsername,
      String encryptedAccessToken,
      String encryptedRefreshToken,
      String decryptedEncryptionKey) async {
    try {
      LogServiceNew.logToFile(
        message: "Inserting user login info",
        screenName: "Database Helper",
        methodName: "insertUserLoginDetails",
        level: Level.debug,
        // stackTrace: "$stackTrace",
      );
      // Get the database instance
      final db = await database;

      // Insert the user login details into the 'user_login' table
      await db.insert(
        'user_login',
        {
          'username': encryptedUsername,
          'accessToken': encryptedAccessToken,
          'refreshToken': encryptedRefreshToken,
          'encryptionKey': decryptedEncryptionKey,
        },
        conflictAlgorithm: ConflictAlgorithm
            .replace, // Replace the existing entry if it exists
      );
      LogServiceNew.logToFile(
        message: "Inserted user login info",
        screenName: "Database Helper",
        methodName: "insertUserLoginDetails",
        level: Level.info,
        // stackTrace: "$stackTrace",
      );

      return "success";
    } catch (e, stackTrace) {
      if (kDebugMode) {
        log(e.toString());
        debugPrintStack();
      }
      LogServiceNew.logToFile(
        message: "Error while inserting user login info: $e",
        screenName: "Database Helper",
        methodName: "insertUserLoginDetails",
        level: Level.error,
        stackTrace: "$stackTrace",
      );
      return "failed to store credentials";
    }
  }

  Future<Map<String, dynamic>?> getUserLoginDetails() async {
    try {
      // Get the database instance
      final db = await database;
      LogServiceNew.logToFile(
        message: "Getting user login info:",
        screenName: "Database Helper",
        methodName: "getUserLoginDetails",
        level: Level.debug,
        stackTrace: "No entries in table",
      );

      // Query the 'user_login' table to get the first row (or all rows)
      final List<Map<String, dynamic>> result = await db.query(
        'user_login',
        limit: 1, // Limits to the first row
      );

      // Check if a result is found, if yes, return the first item
      if (result.isNotEmpty) {
        LogServiceNew.logToFile(
          message: "Got user login info",
          screenName: "Database Helper",
          methodName: "getUserLoginDetails",
          level: Level.info,
          // stackTrace: "$stackTrace",
        );
        return result.first;
      } else {
        LogServiceNew.logToFile(
          message: "Error while getting user login info:",
          screenName: "Database Helper",
          methodName: "getUserLoginDetails",
          level: Level.warning,
          stackTrace: "No entries in table",
        );
        return null; // No entries in the table
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        log(e.toString());
        debugPrintStack();
      }
      LogServiceNew.logToFile(
        message: "Error while getting user login info: $e",
        screenName: "Database Helper",
        methodName: "getUserLoginDetails",
        level: Level.error,
        stackTrace: "$stackTrace",
      );
      return null; // If an error occurs, return null
    }
  }

  Future<Map<String, String>?> runDynamicReadQuery(
      String tableName, List<String> columnsToQuery,
      {int rowsLimit = 1}) async {
    try {
      final db = await database;
      LogServiceNew.logToFile(
        message: "Attempting to query: $columnsToQuery $tableName",
        screenName: "Database Helper",
        methodName: "runDynamicQuery",
        level: Level.debug,
        // stackTrace: "$stackTrace",
      );

      if (rowsLimit <= 1) {
        throw Exception(
            "Cannot fetch less than 1 row. Passed $rowsLimit as limit");
      }

      // Query to fetch the encrypted username and access token from the first row
      final result = await db.query(
        tableName,
        columns: columnsToQuery,
        limit: rowsLimit,
      );
      LogServiceNew.logToFile(
        message: "Attempting to query: $tableName $columnsToQuery",
        screenName: "Database Helper",
        methodName: "runDynamicQuery",
        level: Level.debug,
        // stackTrace: "$stackTrace",
      );

      if (result.isNotEmpty) {
        final row = result.first;
        // Dynamically create a map with column names and values
        final Map<String, String> resultMap = {};
        for (var column in columnsToQuery) {
          resultMap[column] = row[column] as String; // Ensure to cast to String
        }
        LogServiceNew.logToFile(
          message: "Got result for query: $tableName $columnsToQuery",
          screenName: "Database Helper",
          methodName: "runDynamicQuery",
          level: Level.info,
          // stackTrace: "$stackTrace",
        );

        return resultMap;
      } else {
        LogServiceNew.logToFile(
          message: "Query result is empty",
          screenName: "Database Helper",
          methodName: "runDynamicQuery",
          level: Level.warning,
          // stackTrace: "$stackTrace",
        );
        // Handle case when no data is found
        return null;
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        log("Error fetching user details from database: $e");
      }
      LogServiceNew.logToFile(
        message: "Error running dynamic query: $e",
        screenName: "Database Helper",
        methodName: "runDynamicQuery",
        level: Level.error,
        stackTrace: "$stackTrace",
      );
      return null;
    }
  }

  Future<void> deleteUserLoginEntries(String encryptedUsername) async {
    try {
      final db = await database;
      LogServiceNew.logToFile(
        message: "Removing user login entry",
        screenName: "Database Helper",
        methodName: "deleteUserLoginEntries",
        level: Level.debug,
      );
      await db.delete(
        'user_login', // Table to delete from
        where: 'username = ?', // Condition to delete the correct row
        whereArgs: [
          encryptedUsername
        ], // Parameter to match the row (encryptedUsername)
      );
      LogServiceNew.logToFile(
        message: "Removed user login entry",
        screenName: "Database Helper",
        methodName: "deleteUserLoginEntries",
        level: Level.debug,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        log("Error deleting user login entries ${e.toString()}");
      }
      LogServiceNew.logToFile(
        message: "Could not delete user login entry $e",
        screenName: "Database Helper",
        methodName: "deleteUserLoginEntries",
        level: Level.error,
        stackTrace: "$stackTrace",
      );
    }
  }

  Future<String> updateUserLoginDetails(String newEncryptedAccessToken,
      String newEncryptedRefreshToken, String newDecryptedEncryptionKey) async {
    try {
      final db = await database;

      LogServiceNew.logToFile(
        message: "Update user login entry",
        screenName: "Database Helper",
        methodName: "updateUserLoginDetails",
        level: Level.debug,
      );

      // Get the count of users in the 'user_login' table
      final countResult = await db.rawQuery('SELECT COUNT(*) FROM user_login');
      final userCount = Sqflite.firstIntValue(countResult) ?? 0;

      if (userCount == 0) {
        // No user login entry, ask user to relogin
        if (kDebugMode) {
          log("No user logged in. Prompting user to relogin.");
        }
        LogServiceNew.logToFile(
          message: "No user logged in. Prompting user to relogin.",
          screenName: "Database Helper",
          methodName: "updateUserLoginDetails",
          level: Level.debug,
        );
        return "re-login";
      }

      if (userCount > 1) {
        // Too many users, delete all login entries and logout
        if (kDebugMode) {
          log("Too many users. Deleting all login entries.");
        }

        // Delete all user login entries
        await db.delete('user_login');

        LogServiceNew.logToFile(
          message: "Too many users were logged in. Deleted all past logins.",
          screenName: "Database Helper",
          methodName: "updateUserLoginDetails",
          level: Level.warning,
        );

        return "re-login";
      }

      // If there is exactly 1 entry, proceed to update
      final result = await db.update(
        'user_login',
        {
          'accessToken': newEncryptedAccessToken,
          'refreshToken': newEncryptedRefreshToken,
          'encryptionKey': newDecryptedEncryptionKey,
        },
        where:
            'rowid = (SELECT rowid FROM user_login LIMIT 1)', // Update the first row
      );

      if (result == 0) {
        // Handle case where no rows were updated
        if (kDebugMode) {
          log("Failed to update user login details.");
        }
        LogServiceNew.logToFile(
          message: "Failed to update user login details.",
          screenName: "Database Helper",
          methodName: "updateUserLoginDetails",
          level: Level.warning,
        );

        return "re-login";
      } else {
        if (kDebugMode) {
          log("User login details updated successfully.");
        }
        LogServiceNew.logToFile(
          message: "User login details updated successfully.",
          screenName: "Database Helper",
          methodName: "updateUserLoginDetails",
          level: Level.info,
        );

        return "success";
      }
    } catch (e) {
      if (kDebugMode) {
        log("Could not update details for user");
        log(e.toString());
      }

      return "error";
    }
  }

  // Insert States and Districts with error handling
  Future<void> insertStateAndDistricts(
      Map<String, List<String>> stateData) async {
    final db = await database;

    try {
      LogServiceNew.logToFile(
        message: "Inserting State and District Master Data",
        screenName: "Database Helper",
        methodName: "insertStateAndDistricts",
        level: Level.debug,
      );
      // Start a transaction to ensure consistency
      await db.transaction((txn) async {
        // Insert states
        for (var stateName in stateData.keys) {
          await txn.insert(
            'states',
            {'name': stateName},
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );

          // Get the state_id for the inserted state
          final stateId = await txn
              .rawQuery('SELECT id FROM states WHERE name = ?', [stateName]);

          // If the state was not found (very unlikely due to ConflictAlgorithm.ignore), handle the case
          if (stateId.isEmpty) {
            debugPrint('State not found: $stateName');
            continue; // Skip inserting districts for this state
          }

          final stateIdValue = stateId[0]['id'];
          List<String> districts = stateData[stateName]!;

          // Insert districts for each state
          for (var district in districts) {
            await txn.insert(
              'districts',
              {'name': district, 'state_id': stateIdValue},
              conflictAlgorithm: ConflictAlgorithm.ignore,
            );
          }
        }
      });
      LogServiceNew.logToFile(
        message: "Inserted State and District Master Data successfully",
        screenName: "Database Helper",
        methodName: "insertStateAndDistricts",
        level: Level.debug,
      );
    } catch (e, stackTrace) {
      LogServiceNew.logToFile(
        message: "Error while inserting State and District Master Data : $e",
        screenName: "Database Helper",
        methodName: "insertStateAndDistricts",
        level: Level.error,
        stackTrace: "$stackTrace",
      );
      // Catch any errors that occur during the transaction
      if (kDebugMode) {
        debugPrint('Error during insert operation: $e');
      }
      // Optionally rethrow or handle specific error cases
    }
  }
}
