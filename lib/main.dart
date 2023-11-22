// main.dart

import 'package:flutter/material.dart';

import 'package:iai/color_schemes.dart';
import 'package:iai/models/scene.dart';
import 'package:iai/models/user.dart';
import 'package:iai/pages/character/scene_page.dart';
import 'package:iai/pages/character/user_page.dart';
import 'package:iai/pages/home_page.dart';
import 'package:iai/pages/setting_page.dart';
import 'package:iai/pages/character/add_scene_page.dart';
import 'package:iai/pages/character/add_user_page.dart';
import 'package:iai/pages/character/character_page.dart';
import 'package:iai/pages/character/chat_page.dart';
import 'package:iai/pages/character/edit_scene_page.dart';
import 'package:iai/pages/character/edit_user_page.dart';
import 'package:iai/pages/character/management_page.dart';
import 'package:iai/pages/notebook/notebook_page.dart';
import 'package:iai/helpers/encrypt_helper.dart';

void main() async {
  // Ensure widgets are initialized before runApp is called.
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 KeyManager
  await EncryptManager().initialize();

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
          case '/setting':
            return MaterialPageRoute(builder: (context) => const SettingPage());
          case '/character':
            return MaterialPageRoute(builder: (context) => const CharacterPage());
          case '/notebook':
            return MaterialPageRoute(builder: (context) => const NotebookPage());
          case '/addScene':
            return MaterialPageRoute(builder: (context) => const AddScenePage());
          case '/addUser':
            return MaterialPageRoute(builder: (context) => const AddUserPage());
          case '/chat':
            final Map<String, Scene> args = settings.arguments as Map<String, Scene>;
            return MaterialPageRoute(builder: (context) => ChatPage(scene: args['scene']!));
          case '/management':
            return MaterialPageRoute(builder: (context) => const ManagementPage());
          case '/editScene':
            final Map<String, int> args = settings.arguments as Map<String, int>;
            return MaterialPageRoute(builder: (context) => EditScenePage(sceneId: args['sceneId']!));
          case '/editUser':
            final Map<String, int> args = settings.arguments as Map<String, int>;
            return MaterialPageRoute(builder: (context) => EditUserPage(userId: args['userId']!));
          case '/scene':
            final Map<String, Scene> args = settings.arguments as Map<String, Scene>;
            return MaterialPageRoute(builder: (context) => ScenePage(scene: args['scene']!));
          case '/user':
            final Map<String, User> args = settings.arguments as Map<String, User>;
            return MaterialPageRoute(builder: (context) => UserPage(user: args['user']!));
        }
        return null;
      },
    );
  }
}
