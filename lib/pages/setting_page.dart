import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  int _clearingUnusedCache = -1;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Setting'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    'Clear Unused Cache',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Visibility(
                    visible: _clearingUnusedCache == -1,
                    child: Spacer(),
                  ),
                  Visibility(
                    visible: _clearingUnusedCache == 0,
                    child: Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _clearingUnusedCache == 1,
                    child: Expanded(
                      child: Center(
                        child: Icon(Icons.check, color: colorScheme.primary),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _clearingUnusedCache == -1
                        ? () async {
                            setState(() {
                              _clearingUnusedCache = 0;
                            });

                            // 模拟操作延时
                            await Future.delayed(Duration(seconds: 3));

                            await _clearUnusedCache();

                            setState(() {
                              _clearingUnusedCache = 1;
                            });
                          }
                        : null,
                    child: Text('Clear'),
                  ),
                ],
              ),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }

  Future<void> _clearUnusedCache() async {
    // 获取应用程序的本地缓存目录
    Directory appCacheDir = await getTemporaryDirectory();

    // 获取缓存目录中的所有文件和子目录（不递归）
    List<FileSystemEntity> entities = appCacheDir.listSync(followLinks: false);

    // 遍历所有文件和子目录
    for (FileSystemEntity entity in entities) {
      // 删除文件或目录
      if (entity is File) {
        entity.deleteSync();
      } else if (entity is Directory) {
        if (entity.path.split('/').last == "libCachedImageData") {
          continue;
        }
        entity.deleteSync(recursive: true); // 递归删除子目录和子文件
      }
    }
  }
}
