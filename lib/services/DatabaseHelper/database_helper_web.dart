import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_demo/models/state_district/state_district.dart';
import 'package:idb_shim/idb_browser.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';


import '../LogService/log_service_new.dart'; // For web

class DbHelper {
  // Private static instance
  static DbHelper? _instance;

  IdbFactory? _idbFactory;
  Database? _db;
  static const String _dbName = "my_records.db";

  // Private constructor to prevent external instantiation
  DbHelper._();

  // Factory constructor for the singleton pattern
  factory DbHelper() {
    _instance ??= DbHelper._();
    return _instance!;
  }

  // Initialize the IndexedDB factory
  Future<void> init() async {
    // Only initialize if the factory hasn't been initialized yet
    if (_idbFactory == null) {
      _idbFactory = getIdbFactory();
      await _openDatabase();
    }
  }

  // Open the database and create an object store if it doesn't exist
  Future<void> _openDatabase() async {
    if (_idbFactory == null) return;

    _db = await _idbFactory!.open(_dbName, version: 4, onUpgradeNeeded: (VersionChangeEvent event) {
      Database db = event.database;
      db.createObjectStore('user_login', autoIncrement: true);
      db.createObjectStore("user_profile",autoIncrement: false);
      db.createObjectStore('state_district', autoIncrement: true);
      db.createObjectStore('geo_picture', autoIncrement: true);

    });
  }

  Future<String> insertUserLoginDetails( String encryptedUsername,
      String encryptedAccessToken,
      String encryptedRefreshToken,
      String decryptedEncryptionKey) async
  {
    if (_db == null) {
      debugPrint("Database not open yet!");
      return "";
    }

    try {
      var txn = _db!.transaction('user_login', idbModeReadWrite);
      var store = txn.objectStore('user_login');
      await store.put({
        'username': encryptedUsername,
        'accessToken': encryptedAccessToken,
        'refreshToken': encryptedRefreshToken,
        'encryptionKey': decryptedEncryptionKey,
      });
      await txn.completed;
     /* LogServiceNew.logToFile(
        message: "Inserted user login info",
        screenName: "Database Helper",
        methodName: "insertUserLoginDetails",
        level: Level.info,
        // stackTrace: "$stackTrace",
      );*/
      return "success";
    } catch (e, stackTrace) {
      if (kDebugMode) {
        log(e.toString());
        print(stackTrace);
      }
    /*  LogServiceNew.logToFile(
        message: "Exception $e while inserting user login details",
        screenName: "Database Helper",
        methodName: "insertUserLoginDetails",
        level: Level.warning,
        stackTrace: "$stackTrace",
      );*/
      return "failed to store credentials";
    }
  }

  Future<Map<String, dynamic>?> getUserLoginDetails() async
  {
    if (_db == null) {
      debugPrint("Database not open yet!");
    }

    try {
      var txn = _db!.transaction('user_login', idbModeReadOnly);  // Open a read-only transaction
      var store = txn.objectStore('user_login');

      // Retrieve the first entry (if available) from the store
      var result = await store.getObject(1);  // Here '1' is the key for the first record. You can change the key if needed.
      await txn.completed;

      // If there's no data in the store, return null
      if (result == null) {
        return null;
      }

      // Return the result as a map
      return result as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        log("Error retrieving user login details: $e");
      }
      return null;  // In case of an error, return null
    }
  }

  Future<void> insertUserProfile(Map<String, dynamic> userProfile) async
  {
    debugPrint("insertingdb$_db");

    if (_db == null) {
      debugPrint("Database not open yet!");
    }
    debugPrint("inserting db$_db");
    try {
    /*  LogServiceNew.logToFile(
        message: "Attempting to insert user profile",
        screenName: "Database Helper",
        methodName: "insertGeoPicture",
        level: Level.debug,
      );*/

      log("inserting start");
      var uuid = Uuid();
      String id = uuid.v4().toString();
      userProfile['id'] = id;
      var txn = _db!.transaction('user_profile', idbModeReadWrite);
      var store = txn.objectStore('user_profile');
      await store.put(userProfile, id);
      await txn.completed;
      log("inserting completed");

      log("inserting$store");


    }  catch (e, stackTrace) {
      if (kDebugMode) {
        log("Exception $e while attempting to insert user profile");
        print(stackTrace);
      }
     /* LogServiceNew.logToFile(
        message: "Exception $e while attempting to insert user profile",
        screenName: "Database Helper",
        methodName: "insertGeoPicture",
        level: Level.warning,
        stackTrace: "$stackTrace",
      );*/
    }
  }

  Future<List<Map<String, dynamic>>> getUserProfiles() async
  {
    if (_db == null) {
      debugPrint("Database not open yet!");
      return [];
    }
    try {
      /* LogServiceNew.logToFile(
        message: "Attempting to get all user profiles",
        screenName: "Database Helper",
        methodName: "getUserProfiles",
        level: Level.debug,
      );*/

      var txn = _db!.transaction('user_profile', idbModeReadOnly);

      var store = txn.objectStore('user_profile');

      var allValues = await store.getAll();

      // Create a set to collect distinct states (sets automatically handle uniqueness)
      List<Map<String, dynamic>> userProfiles = [];

      // Iterate through the values and extract the state
      for (var value in allValues) {

        if (value is Map<String, dynamic>) {

         userProfiles.add(value);

        } else {
          debugPrint('Warning: value is not of type Map<String, dynamic>');
        }
      }

      log("userprofile ${userProfiles.length}");
      return userProfiles;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        log("Exception $e while attempting to get user profiles");
        debugPrint(stackTrace.toString());
      }
      /*  LogServiceNew.logToFile(
        message: "Exception $e while attempting to get user profiles",
        screenName: "Database Helper",
        methodName: "getUserProfiles",
        level: Level.warning,
        stackTrace: "$stackTrace",
      );*/
      return [];
    }
  }

  Future<void> deleteUserProfile(String id) async
  {
    if (_db == null) {
      debugPrint("Database not open yet!");
    }
    try {
      /*LogServiceNew.logToFile(
        message: "Attempting to delete user profile",
        screenName: "Database Helper",
        methodName: "insertGeoPicture",
        level: Level.debug,
      );*/
      if(kDebugMode){
        print("id runtime type ${id.runtimeType}");
      }

      var txn = _db!.transaction('user_profile', idbModeReadWrite);
      var store = txn.objectStore('user_profile');

      // Perform the delete operation
      await store.delete(id);

      // Ensure the transaction is committed
      await txn.completed;

   /*   LogServiceNew.logToFile(
        message: "Deleted user profile",
        screenName: "Database Helper",
        methodName: "insertGeoPicture",
        level: Level.debug,
      );*/
    } catch (e, stackTrace) {
      if (kDebugMode) {
        log("Exception $e while attempting to delete user profile");
        print(stackTrace);
      }
     /* LogServiceNew.logToFile(
        message: "Exception $e while attempting to delete user profile",
        screenName: "Database Helper",
        methodName: "insertGeoPicture",
        level: Level.warning,
        stackTrace: "$stackTrace",
      );*/
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> userProfile) async {

    if (_db == null) {
      debugPrint("Database not open yet!");
    }
    try {
     /* LogServiceNew.logToFile(
        message: "Attempting to update user profile in IndexedDB",
        screenName: "Database Helper",
        methodName: "updateUserProfile",
        level: Level.debug,
      );*/
      // Ensure the 'id' is a string (if needed)

      var txn = _db!.transaction('user_profile', idbModeReadWrite);

      if(kDebugMode){
        log('txn created $txn');
      }
      var store = txn.objectStore('user_profile');

      if(kDebugMode){
        log("store $store");
      }

      debugPrint("final user profile${userProfile['id']}");

      // Use 'put' to insert or update the user profile in the store using 'id' as the key
      await store.put(userProfile, userProfile['id']);

      // await store.put(userProfile);
      if(kDebugMode){
        log("store .put ");
      }
      // await store.put(userProfile);
      await txn.completed; // Ensure the transaction completes successful


    /*  LogServiceNew.logToFile(
        message: "User profile updated in IndexedDB",
        screenName: "Database Helper",
        methodName: "updateUserProfile",
        level: Level.debug,
      );*/
    } catch (e, stackTrace) {
      if (kDebugMode) {
        log("Exception $e while updating user profile in IndexedDB");
        print(stackTrace);
      }

     /* LogServiceNew.logToFile(
        message: "Exception $e while updating user profile in IndexedDB",
        screenName: "Database Helper",
        methodName: "updateUserProfile",
        level: Level.warning,
        stackTrace: "$stackTrace",
      );*/
    }
  }

  Future<void> insertGeoPicture(String picture, String currentlocation) async
  {
    if (_db == null) {
      debugPrint("Database not open yet!");
    }
    try {
     /* LogServiceNew.logToFile(
        message: "Attempting to insert geo picture",
        screenName: "Database Helper",
        methodName: "insertGeoPicture",
        level: Level.debug,
      );*/

      var txn = _db!.transaction('geo_picture', idbModeReadWrite);
      var store = txn.objectStore('geo_picture');
      await store.put({'picture': picture, 'currentlocation': currentlocation});
      await txn.completed;

     /* LogServiceNew.logToFile(
        message: "Inserted geo picture successfully",
        screenName: "Database Helper",
        methodName: "insertGeoPicture",
        level: Level.debug,
      );*/
    } catch (e, stackTrace) {
      if (kDebugMode) {
        log("Exception $e while insert geo picture");
        print(stackTrace);
      }

     /* LogServiceNew.logToFile(
        message: "Exception $e while insertGeoPicture",
        screenName: "Database Helper",
        methodName: "insertGeoPicture",
        level: Level.warning,
        stackTrace: "$stackTrace",
      );*/
    }
  }

  Future<List<Map<String, dynamic>>> getUGeoPictures() async
  {
    if (_db == null) {
      debugPrint("Database not open yet!");
      return [];
    }
    try {
    /*  LogServiceNew.logToFile(
        message: "Attempting to get u geo pictures",
        screenName: "Database Helper",
        methodName: "getUgeoPictures",
        level: Level.debug,
      );
*/
      var txn = _db!.transaction('geo_picture', idbModeReadOnly);
      var store = txn.objectStore('geo_picture');

      var allValues = await store.getAll();

      // Create a set to collect distinct states (sets automatically handle uniqueness)
      List<Map<String, dynamic>> geoPicturesWithTag = [];

      // Iterate through the values and extract the state
      for (var value in allValues) {

        if (value is Map<String, dynamic>) {

          geoPicturesWithTag.add(value);

        } else {
          debugPrint('Warning: value is not of type Map<String, dynamic>');
        }
      }

      return geoPicturesWithTag;

    } catch (e, stackTrace) {
      if (kDebugMode) {
        log("Exception $e while get ugeopictures");
        print(stackTrace);
      }
     /* LogServiceNew.logToFile(
        message: "Exception $e while get ugeopictures",
        screenName: "Database Helper",
        methodName: "getUgeoPictures",
        level: Level.warning,
        stackTrace: "$stackTrace",
      );
*/
      return [];
    }
  }

  Future<void> insertDistricts(List<District> districts) async
  {
    if (_db == null) {
      debugPrint("Database not open yet!");
    }

    try{
      var txn = _db!.transaction('state_district', idbModeReadWrite);
      var store = txn.objectStore('state_district');

      for (var district in districts) {
        // Convert the district to a map (assuming district.toMap() works)
        final districtMap = district.toMap();

        // Add or update the district
        await store.put(districtMap); // IndexedDB uses put for both adding and updating
      }

      // Wait for transaction to complete
      await txn.completed;
    }
    catch (e, stackTrace) {
      if (kDebugMode) {
        log("Exception $e while attempting to insert user profile");
        print(stackTrace);
      }
      /* LogServiceNew.logToFile(
        message: "Exception $e while attempting to insert user profile",
        screenName: "Database Helper",
        methodName: "insertGeoPicture",
        level: Level.warning,
        stackTrace: "$stackTrace",
      );*/
    }
  }

  Future<List<String>> getDistrictStates() async
  {
    if (_db == null) {
      debugPrint("Database not open yet!");
      return [];
    }

    try {
      // Start a transaction to access the object store in read-only mode
      var txn = _db!.transaction('state_district', idbModeReadOnly);
      var store = txn.objectStore('state_district');

      // Get all values from the object store
      var allValues = await store.getAll();

      // Create a set to collect distinct states (sets automatically handle uniqueness)
      Set<String> distinctStates = {};

      // Iterate through the values and extract the state
      for (var value in allValues) {
        if (value is Map<String, dynamic>) {
          var district = value;

          // Add the state to the set (which ensures it's unique)
          if (district['state'] != null) {
            distinctStates.add(district['state'] as String);
          }
        } else {
          print('Warning: value is not of type Map<String, dynamic>');
        }
      }

      // Return the distinct states as a List
      return List<String>.from(distinctStates);
    } catch (e, stackTrace) {
      print("Exception $e while fetching distinct states");
      print(stackTrace);
      return [];
    }
  }

  Future<List<String>> getDistrictsByStateDB(String state) async
  {
    if (_db == null) {
      debugPrint("Database not open yet!");
      return [];
    }

    try {
      // Start a transaction to access the object store in read-only mode
      var txn = _db!.transaction('state_district', idbModeReadOnly);
      var store = txn.objectStore('state_district');

      // Get all values from the object store
      var allValues = await store.getAll();

      // Create a list to hold the districts
      List<String> districts = [];

      // Iterate through the values and extract districts for the given state
      for (var value in allValues) {
        if (value is Map<String, dynamic>) {
          var district = value;

          // Filter records by the state
          if (district['state'] == state) {
            // Add the district name to the list
            districts.add(district['district'] as String);
          }
        } else {
          debugPrint('Warning: value is not of type Map<String, dynamic>');
        }
      }

      // Return the list of districts
      return districts;
    } catch (e, stackTrace) {
      debugPrint("Exception $e while fetching districts for $state");
      debugPrint(stackTrace.toString()); // Print the stack trace as a string
      return [];
    }
  }


}
