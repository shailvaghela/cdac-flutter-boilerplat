import 'package:flutter/cupertino.dart';
import 'package:flutter_demo/services/LocalStorageService/local_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LanguageChangeController with ChangeNotifier{

  Locale? _appLocale;
  Locale? get appLocale => _appLocale;
  final  _storage = LocalStorage(); // Secure storage instance

  void changeLanguage(Locale type) async{

    _appLocale = type;

    if(type == Locale('en')){
      _storage.setLanguage('en');
    }
    else if(type == Locale('hi')){
      _storage.setLanguage('hi');
    }

    notifyListeners();
  }
}