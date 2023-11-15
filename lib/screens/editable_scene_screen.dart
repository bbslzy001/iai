import 'package:flutter/material.dart';

import 'package:conversation_notebook/models/scene.dart';
import 'package:conversation_notebook/models/user.dart';
import 'package:conversation_notebook/helpers/database_helper.dart';

class EditableSceneScreen extends StatefulWidget {
  final int sceneId;

  const EditableSceneScreen({Key? key, required this.sceneId}) : super(key: key);

  @override
  _EditableSceneScreenState createState() => _EditableSceneScreenState();
}

class _EditableSceneScreenState extends State<EditableSceneScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<User> _users = [];
  Scene? _scene;

  @override
  void initState() async {
    super.initState();
    _users = await _dbHelper.getUsers();
    if (widget.sceneId != -1) {
      _scene = await _dbHelper.getSceneById(widget.sceneId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        title: Text(widget.sceneId != -1 ? 'Edit Scene' : 'Add Scene'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                initialValue: _scene?.sceneName ?? '',
                decoration: InputDecoration(labelText: 'Scene Name'),
                onChanged: (value) {
                  // Update the sceneName when the user types
                  setState(() {
                    _scene?.sceneName = value;
                  });
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _scene?.backgroundPath ?? '',
                decoration: InputDecoration(labelText: 'Background Path'),
                onChanged: (value) {
                  // Update the backgroundPath when the user types
                  setState(() {
                    _scene?.backgroundPath = value;
                  });
                },
              ),
              SizedBox(height: 16),
              DropdownButton<int>(
                value: _scene?.user1Id ?? 0,
                items: _users.map((user) {
                  return DropdownMenuItem<int>(
                    value: user.id,
                    child: Text(user.username),
                  );
                }).toList(),
                onChanged: (value) {
                  // Update user1Id when the user selects a user
                  setState(() {
                    _scene?.user1Id = value ?? 0;
                  });
                },
                hint: Text('Select User 1'),
              ),
              SizedBox(height: 16),
              DropdownButton<int>(
                value: _scene?.user2Id ?? 0,
                items: _users.map((user) {
                  return DropdownMenuItem<int>(
                    value: user.id,
                    child: Text(user.username),
                  );
                }).toList(),
                onChanged: (value) {
                  // Update user2Id when the user selects a user
                  setState(() {
                    _scene?.user2Id = value ?? 0;
                  });
                },
                hint: Text('Select User 2'),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  // Save data to the database
                  if (_scene != null) {
                    if (widget.sceneId != -1) {
                      // Update existing scene
                      await _dbHelper.updateScene(_scene!);
                    } else {
                      // Insert new scene
                      await _dbHelper.insertScene(_scene!);
                    }
                  }
                  // Navigate back to the previous screen
                  Navigator.pop(context);
                },
                child: Text('Finish'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
