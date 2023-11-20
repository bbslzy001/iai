import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setting'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClearItem(
              buttonText: 'Clear Unused Cache',
              clearFunction: _clearUnusedCache,
            ),
            const Divider(),
            ClearItem(
              buttonText: 'Clear Data Cache',
              clearFunction: _clearDataCache,
            ),
            const Divider(),
            ClearItem(
              buttonText: 'Clear App Data',
              clearFunction: _clearAppData,
            )
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

  Future<void> _clearDataCache() async {
    DefaultCacheManager().emptyCache();
  }

  Future<void> _clearAppData() async {
  }
}

class ClearItem extends StatefulWidget {
  final String buttonText;
  final Future<void> Function() clearFunction;

  const ClearItem({
    Key? key,
    required this.buttonText,
    required this.clearFunction,
  }) : super(key: key);

  @override
  _ClearItemState createState() => _ClearItemState();
}

class _ClearItemState extends State<ClearItem> {
  int _clearing = -1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Text(
            widget.buttonText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Visibility(
            visible: _clearing == -1,
            child: const Spacer(),
          ),
          Visibility(
            visible: _clearing == 0,
            child: const Expanded(
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2.0),
              ),
            ),
          ),
          Visibility(
            visible: _clearing == 1,
            child: Expanded(
              child: Center(
                child: Icon(Icons.check, color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _clearing == -1
                ? () async {
              setState(() {
                _clearing = 0;
              });

              // Simulate operation delay
              await Future.delayed(Duration(seconds: 3));

              await widget.clearFunction();

              setState(() {
                _clearing = 1;
              });
            }
                : null,
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
