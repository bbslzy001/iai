// main.dart

import 'package:flutter/material.dart';

import 'package:iai/color_schemes.dart';
import 'package:iai/helpers/file_helper.dart';
import 'package:iai/router/my_router.dart';

void main() async {
  // Ensure widgets are initialized before runApp is called.
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 FileDirectoryManager
  await FileDirectoryManager().initialize();

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
      onGenerateRoute: MyAppRouter.generateRoute,
    );
  }
}
