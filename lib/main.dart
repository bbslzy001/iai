// main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      builder: (context, child) {
        final isLightMode = Theme.of(context).brightness == Brightness.light;
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          // 设置顶部状态栏背景色
          statusBarColor: Colors.transparent,
          // 设置顶部状态栏亮度
          statusBarIconBrightness: isLightMode ? Brightness.dark : Brightness.light,
          // 设置底部导航栏背景色
          systemNavigationBarColor: isLightMode ? Colors.white : Colors.black,
          // 设置底部导航栏亮度
          systemNavigationBarIconBrightness: isLightMode ? Brightness.dark : Brightness.light,
        ));

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), // 保证文字大小不受手机系统设置影响
          child: child!,
        );
      },
    );
  }
}
