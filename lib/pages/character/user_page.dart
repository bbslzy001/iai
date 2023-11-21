import 'package:flutter/material.dart';

import 'package:iai/models/user.dart';
import 'package:iai/widgets/image_shower.dart';

class UserPage extends StatefulWidget {
  final User user;

  UserPage({Key? key, required this.user}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.username),
        backgroundColor: colorScheme.primaryContainer,
      ),
      body: Stack(
        children: [
          // 上半部分背景
          Container(
            height: screenHeight * 0.1,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: screenHeight * 0.2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0), // Adjust the value as needed
                    child: MyImageShower(
                      image: widget.user.backgroundImage,
                      defaultImage: 'assets/images/user.png',
                    ),
                  ),
                ),
                SizedBox(height: 32),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    widget.user.description,
                    style: TextStyle(fontSize: 20),
                  ),
                )
              ],
            ),
          ),
        ],
      )
    );
  }
}