// screens/user_management_screen.dart

import 'package:flutter/material.dart';

class UserManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to User Management Page!',
              style: TextStyle(fontSize: 18),
            ),
            // Add your user management widgets here
          ],
        ),
      ),
    );
  }
}
