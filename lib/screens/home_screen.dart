import 'package:auto_direction/auto_direction.dart';
import 'package:flutter/material.dart';
import 'package:long_sms_sender/screens/contact_list_screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _message = "";

  TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Send Long SMS"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                AutoDirection(
                  text: _message,
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(15),
                        ),
                      ),
                    ),
                    maxLines: 10,
                    onChanged: (val) {
                      setState(() {
                        _message = val;
                      });
                    },
                  ),
                ),
                TextButton(
                    onPressed: () {
                      setState(() {
                        _message = "";
                        _textController.clear();
                      });
                    },
                    child: const Text("Clear"))
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context)
                .pushNamed(ContactListScreen.routeName, arguments: _message);
          },
          child: const RotationTransition(
            turns: AlwaysStoppedAnimation(0.9),
            child: Icon(
              Icons.send,
            ),
          ),
        ),
      ),
    );
  }
}
