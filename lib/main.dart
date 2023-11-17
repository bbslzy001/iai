// main.dart

import 'package:flutter/material.dart';

import 'package:conversation_notebook/color_schemes.dart';
import 'package:conversation_notebook/pages/character/add_scene_page.dart';
import 'package:conversation_notebook/pages/character/add_user_page.dart';
import 'package:conversation_notebook/pages/character/chat_page.dart';
import 'package:conversation_notebook/pages/character/edit_scene_page.dart';
import 'package:conversation_notebook/pages/character/edit_user_page.dart';
import 'package:conversation_notebook/pages/character/home_page.dart';
import 'package:conversation_notebook/pages/character/management_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Character',
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => const HomePage());
          case '/addScene':
            return MaterialPageRoute(builder: (context) => const AddScenePage());
          case '/addUser':
            return MaterialPageRoute(builder: (context) => const AddUserPage());
          case '/chat':
            final Map<String, int> args = settings.arguments as Map<String, int>;
            return MaterialPageRoute(builder: (context) => ChatPage(user1Id: args['user1Id']!, user2Id: args['user2Id']!));
          case '/management':
            return MaterialPageRoute(builder: (context) => const ManagementPage());
          case '/editScene':
            final Map<String, int> args = settings.arguments as Map<String, int>;
            return MaterialPageRoute(builder: (context) => EditScenePage(sceneId: args['sceneId']!));
          case '/editUser':
            final Map<String, int> args = settings.arguments as Map<String, int>;
            return MaterialPageRoute(builder: (context) => EditUserPage(userId: args['userId']!));
          // case 'scene':
          //   return MaterialPageRoute(builder: (context) => const ScenePage());
          // case 'setting':
          //   return MaterialPageRoute(builder: (context) => const SettingPage());
          // case 'user':
          //   return MaterialPageRoute(builder: (context) => const UserPage());
        }
        return null;
      },
    );
  }
}
