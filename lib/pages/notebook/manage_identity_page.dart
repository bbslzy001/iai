// pages/character/manage_scene_user_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:iai/helpers/database_helper.dart';
import 'package:iai/models/identity.dart';
import 'package:iai/utils/build_future_builder.dart';
import 'package:iai/widgets/avatar_provider.dart';

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
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _isChanged);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
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
        body: buildFutureBuilder([_identitiesFuture], (dataList) {
          final identities = dataList[0];
          return ManageIdentityContent(identities: identities, updateStateCallback: updateStateCallback, isChangedCallback: isChangedCallback);
        }),
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
