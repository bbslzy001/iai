import 'dart:io';

import 'package:flutter/material.dart';

import 'package:iai/models/identity.dart';
import 'package:iai/models/note.dart';
import 'package:iai/models/scene.dart';
import 'package:iai/models/user.dart';
import 'package:iai/pages/character/add_scene_page.dart';
import 'package:iai/pages/character/add_user_page.dart';
import 'package:iai/pages/character/character_page.dart';
import 'package:iai/pages/character/chat_page.dart';
import 'package:iai/pages/character/edit_scene_page.dart';
import 'package:iai/pages/character/edit_user_page.dart';
import 'package:iai/pages/character/manage_scene_user_page.dart';
import 'package:iai/pages/character/scene_page.dart';
import 'package:iai/pages/character/user_page.dart';
import 'package:iai/pages/full_image_page.dart';
import 'package:iai/pages/full_video_page.dart';
import 'package:iai/pages/home_page.dart';
import 'package:iai/pages/notebook/add_identity_page.dart';
import 'package:iai/pages/notebook/add_note_page.dart';
import 'package:iai/pages/notebook/edit_identity_page.dart';
import 'package:iai/pages/notebook/edit_note_page.dart';
import 'package:iai/pages/notebook/identity_page.dart';
import 'package:iai/pages/notebook/manage_identity_page.dart';
import 'package:iai/pages/notebook/note_page.dart';
import 'package:iai/pages/notebook/notebook_page.dart';
import 'package:iai/pages/setting_page.dart';

class MyAppRouter {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (context) => const HomePage());
      case '/setting':
        return MaterialPageRoute(builder: (context) => const SettingPage());
      case '/character':
        return MaterialPageRoute(builder: (context) => const CharacterPage());
      case '/identity':
        return MaterialPageRoute(builder: (context) => const IdentityPage());
      case '/notebook':
        final Map<String, Identity> args = settings.arguments as Map<String, Identity>;
        return MaterialPageRoute(builder: (context) => NotebookPage(identity: args['identity']!));
      case '/addScene':
        return MaterialPageRoute(builder: (context) => const AddScenePage());
      case '/addUser':
        return MaterialPageRoute(builder: (context) => const AddUserPage());
      case '/chat':
        final Map<String, Scene> args = settings.arguments as Map<String, Scene>;
        return MaterialPageRoute(builder: (context) => ChatPage(scene: args['scene']!));
      case '/manageSceneUser':
        return MaterialPageRoute(builder: (context) => const ManageSceneUserPage());
      case '/manageIdentity':
        return MaterialPageRoute(builder: (context) => const ManageIdentityPage());
      case '/addIdentity':
        return MaterialPageRoute(builder: (context) => const AddIdentityPage());
      case '/editIdentity':
        final Map<String, Identity> args = settings.arguments as Map<String, Identity>;
        return MaterialPageRoute(builder: (context) => EditIdentityPage(identity: args['identity']!));
      case '/editScene':
        final Map<String, Scene> args = settings.arguments as Map<String, Scene>;
        return MaterialPageRoute(builder: (context) => EditScenePage(scene: args['scene']!));
      case '/editUser':
        final Map<String, User> args = settings.arguments as Map<String, User>;
        return MaterialPageRoute(builder: (context) => EditUserPage(user: args['user']!));
      case '/scene':
        final Map<String, Scene> args = settings.arguments as Map<String, Scene>;
        return MaterialPageRoute(builder: (context) => ScenePage(scene: args['scene']!));
      case '/user':
        final Map<String, User> args = settings.arguments as Map<String, User>;
        return MaterialPageRoute(builder: (context) => UserPage(user: args['user']!));
      case '/fullImage':
        final Map<String, File> args = settings.arguments as Map<String, File>;
        return MaterialPageRoute(builder: (context) => FullImagePage(imageFile: args['imageFile']!));
      case '/fullVideo':
        final Map<String, File> args = settings.arguments as Map<String, File>;
        return MaterialPageRoute(builder: (context) => FullVideoPage(videoThumbnailFile: args['videoThumbnailFile']!, videoFile: args['videoFile']!));
      case '/addNote':
        final Map<String, int> args = settings.arguments as Map<String, int>;
        return MaterialPageRoute(builder: (context) => AddNotePage(identityId: args['identityId']!));
      case '/note':
        final Map<String, Note> args = settings.arguments as Map<String, Note>;
        return MaterialPageRoute(builder: (context) => NotePage(note: args['note']!));
      case '/editNote':
        final Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (context) => EditNotePage(note: args['note']!));
    }
    return null;
  }
}
