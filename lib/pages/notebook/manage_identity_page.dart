// pages/character/manage_scene_user_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:iai/helpers/database_helper.dart';
import 'package:iai/widgets/avatar_provider.dart';
import 'package:iai/models/identity.dart';

class ManageIdentityPage extends StatefulWidget {
  const ManageIdentityPage({Key? key}) : super(key: key);

  @override
  _ManageIdentityPageState createState() => _ManageIdentityPageState();
}

class _ManageIdentityPageState extends State<ManageIdentityPage> {
  final _dbHelper = DatabaseHelper();

  bool _isChanged = false;

  void isChangedCallback() {
    _isChanged = true;
  }

  late Future<List<Identity>> _identitiesFuture;

  // 异步获取数据
  Future<List<Identity>> _getIdentitiesFuture() async {
    return await _dbHelper.getIdentities();
  }

  // 第一次获取数据
  @override
  void initState() {
    super.initState();
    _identitiesFuture = _getIdentitiesFuture();
  }

  // 重新获取数据，定义给子组件使用的回调函数
  void updateStateCallback() {
    setState(() {
      _identitiesFuture = _getIdentitiesFuture();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context, _isChanged);
          },
        ),
        title: const Text('Management'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'addIdentity') {
                Navigator.of(context).pushNamed('/addIdentity').then((result) {
                  if (result != null && result is bool && result) {
                    _isChanged = true; // 表明数据发生变化
                    updateStateCallback();
                  }
                });
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'addIdentity',
                child: Text('Add Identity'),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder(
        // 传入Future列表
        future: Future.wait([_identitiesFuture]),
        // 构建页面的回调
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          // 当重新触发FutureBuilder时，虽然snapshot.connectionState会变为waiting，但是snapshot中的数据不会消失，所以hasData为true，因此要先判断状态再判断是否有数据或错误
          if (snapshot.connectionState == ConnectionState.waiting || snapshot.connectionState == ConnectionState.active) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              // 数据准备完成，构建页面
              final identities = snapshot.data![0];
              return ManageIdentityContent(identities: identities, updateStateCallback: updateStateCallback, isChangedCallback: isChangedCallback);
            } else {
              return const Center(
                child: Text('Not Found Data'),
              );
            }
          } else if (snapshot.hasError) {
            // 如果发生错误，显示错误信息
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return const Center(
              child: Text('Unknown Error'),
            );
          }
        },
      ),
    );
  }
}

class ManageIdentityContent extends StatelessWidget {
  final _dbHelper = DatabaseHelper();

  final List<Identity> identities;
  final VoidCallback updateStateCallback;
  final VoidCallback isChangedCallback;

  ManageIdentityContent({Key? key, required this.identities, required this.updateStateCallback, required this.isChangedCallback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      itemCount: identities.length,
      itemBuilder: (context, index) {
        return Slidable(
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (BuildContext context) {
                  Navigator.of(context).pushNamed('/editIdentity', arguments: {
                    'identity': identities[index] as Identity,
                  }).then((result) {
                    if (result != null && result is bool && result) {
                      isChangedCallback();
                      updateStateCallback();
                    }
                  });
                },
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.primaryContainer,
                icon: Icons.edit,
                label: 'Edit',
              ),
              SlidableAction(
                onPressed: (BuildContext context) async {
                  await _dbHelper.deleteIdentity(identities[index].id!);
                  isChangedCallback();
                  updateStateCallback();
                },
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.errorContainer,
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
          ),
          child: ListTile(
            leading: CircleAvatar(
              foregroundImage: identities[index].backgroundImage.isNotEmpty ? MyAvatarProvider(identities[index].backgroundImage) : null,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(identities[index].identityName[0]),
            ),
            title: Text(identities[index].identityName),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
        );
      },
    );
  }
}
