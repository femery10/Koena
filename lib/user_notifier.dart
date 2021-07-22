import 'dart:collection';

import 'package:expandable_listview_example/classes/users.dart';
import 'package:flutter/cupertino.dart';

class UserNotifier with ChangeNotifier {
  List<KUser> _userList = [];
  late KUser _currentUser;

  UnmodifiableListView<KUser> get userList => UnmodifiableListView(_userList);

  KUser get currentUser => _currentUser;

  set userList(List<KUser> userList){
    _userList = userList;
    notifyListeners();
  }

  set currentUser(KUser user){
    _currentUser = user;
    notifyListeners();
  }
}