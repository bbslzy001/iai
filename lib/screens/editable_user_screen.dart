import 'package:flutter/material.dart';

import 'package:conversation_notebook/models/user.dart';
import 'package:conversation_notebook/helpers/database_helper.dart';

class EditableUserScreen extends StatefulWidget {
  final int userId;

  const EditableUserScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _EditableUserScreenState createState() => _EditableUserScreenState();
}

class _EditableUserScreenState extends State<EditableUserScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  User? _user;

  @override
  void initState() async {
    super.initState();
    if (widget.userId != -1) {
      _user = await _dbHelper.getUserById(widget.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        title: Text(widget.userId != -1 ? 'Edit User' : 'Add User'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                initialValue: _user?.username ?? '',
                decoration: InputDecoration(labelText: 'Username'),
                onChanged: (value) {
                  // Update the userName when the user types
                  setState(() {
                    _user?.username = value;
                  });
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _user?.description ?? '',
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (value) {
                  // Update the description when the user types
                  setState(() {
                    _user?.description = value;
                  });
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _user?.avatarPath ?? '',
                decoration: InputDecoration(labelText: 'Avatar Path'),
                onChanged: (value) {
                  // Update the avatarPath when the user types
                  setState(() {
                    _user?.avatarPath = value;
                  });
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _user?.backgroundPath ?? '',
                decoration: InputDecoration(labelText: 'Background Path'),
                onChanged: (value) {
                  // Update the backgroundPath when the user types
                  setState(() {
                    _user?.backgroundPath = value;
                  });
                },
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  // Save data to the database
                  if (_user != null) {
                    if (widget.userId != -1) {
                      // Update existing scene
                      await _dbHelper.updateUser(_user!);
                    } else {
                      // Insert new scene
                      await _dbHelper.insertUser(_user!);
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
