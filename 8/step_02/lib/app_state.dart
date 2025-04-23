// lib/app_state.dart

import 'dart:async';                                     // new

import 'package:cloud_firestore/cloud_firestore.dart';   // new
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'guest_book_message.dart';                        // new

/// 用户的出席状态
enum Attending { yes, no, unknown }                        // new

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  // 留言板相关状态
  StreamSubscription<QuerySnapshot>? _guestBookSubscription;
  List<GuestBookMessage> _guestBookMessages = [];
  List<GuestBookMessage> get guestBookMessages => _guestBookMessages;

  // 出席统计相关状态
  int _attendees = 0;                                      // new
  int get attendees => _attendees;                         // new

  Attending _attending = Attending.unknown;               // new
  StreamSubscription<DocumentSnapshot>? _attendingSubscription; // new
  Attending get attending => _attending;                  // new
  set attending(Attending value) {                        // new
    _attending = value;                                   // new
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance
        .collection('attendees')                         // new
        .doc(userId);
    userDoc.set(<String, dynamic>{
      'attending': value == Attending.yes,              // new
    });
    notifyListeners();                                  // new
  }                                                     // new

  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 配置 FirebaseUI 登录提供者
    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

    // 订阅 attendees 集合，自动统计 attend==true 的数量
    FirebaseFirestore.instance
        .collection('attendees')                         // new
        .where('attending', isEqualTo: true)             // new
        .snapshots()                                     // new
        .listen((snapshot) {
      _attendees = snapshot.docs.length;                 // new
      notifyListeners();                                // new
    });                                                 // new

    // 监听用户登录状态变化
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;

        // 订阅 guestbook 留言流
        _guestBookSubscription = FirebaseFirestore.instance
            .collection('guestbook')
            .orderBy('timestamp', descending: true)
            .snapshots()
            .listen((snapshot) {
          _guestBookMessages = snapshot.docs.map((doc) {
            final data = doc.data();
            return GuestBookMessage(
              name: data['name'] as String,
              message: data['text'] as String,
            );
          }).toList();
          notifyListeners();
        });

        // 订阅当前用户的出席文档，监听自己的 attend 状态
        _attendingSubscription = FirebaseFirestore.instance
            .collection('attendees')                     // new
            .doc(user.uid)
            .snapshots()                                 // new
            .listen((snapshot) {
          final data = snapshot.data();                 // new
          if (data == null) {
            _attending = Attending.unknown;             // new
          } else if (data['attending'] as bool) {
            _attending = Attending.yes;                 // new
          } else {
            _attending = Attending.no;                  // new
          }
          notifyListeners();                            // new
        });
      } else {
        // 用户登出，清理状态和订阅
        _loggedIn = false;
        _guestBookMessages = [];
        _attending = Attending.unknown;                // new
        _guestBookSubscription?.cancel();
        _attendingSubscription?.cancel();              // new
      }
      notifyListeners();
    });
  }

  /// 添加一条留言到 guestbook
  Future<DocumentReference> addMessageToGuestBook(String message) {
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }

    return FirebaseFirestore.instance
        .collection('guestbook')
        .add(<String, dynamic>{
      'text': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'name': FirebaseAuth.instance.currentUser!.displayName,
      'userId': FirebaseAuth.instance.currentUser!.uid,
    });
  }
}
