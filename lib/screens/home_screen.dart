import 'package:auto_direction/auto_direction.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:long_sms_sender/screens/contact_list_screen.dart';
import 'package:long_sms_sender/utils/text_util.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _message = "";
  int _parts = 0;
  final TextEditingController _textController = TextEditingController();

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
                        _parts =
                            TextUtil.countSequence(_textController.text, 159);
                      });
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text("$_parts SMS to send")),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          _clearText();
                        },
                        child: const Text("Clear"),
                      ),
                    ),
                    Expanded(child: Container()),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: FloatingActionButton(
          onPressed: () async {
            if (_parts > 0) {
              await Navigator.of(context)
                  .pushNamed(ContactListScreen.routeName, arguments: _message)
                  .then((value) {
                _clearText();
              });
            } else {
              Fluttertoast.showToast(
                  msg: "Please write your message!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black87,
                  textColor: Colors.white,
                  fontSize: 16.0);
            }
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

  void _clearText() {
    setState(() {
      _message = "";
      _textController.clear();
      _parts = 0;
    });
  }
}
