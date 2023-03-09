import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:long_sms_sender/utils/text_util.dart';

class ContactListScreen extends StatefulWidget {
  static const String routeName = "contacts";
  const ContactListScreen({super.key});

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  String _message = "";
  bool _isInit = true;
  List<Contact>? _contacts;
  List<Contact> _selectedContacts = [];
  TextEditingController _textController = TextEditingController();
  @override
  void didChangeDependencies() {
    if (_isInit) {
      _message = ModalRoute.of(context)!.settings.arguments as String;

      _isInit = false;
    }

    super.didChangeDependencies();
  }

  void _sendSMS() async {
    print("sending.....");
    var msgs = TextUtil.SplitEveryNth(_message, 160);
    print(msgs);
    print(_message);
    for (String? m in msgs) {
      String _result = await sendSMS(
              message: m!,
              recipients:
                  _selectedContacts.map((e) => e.phones.first.number).toList())
          .catchError((onError) {
        print(onError);
      });
      print(_result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Send To..."),
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              _sendSMS();
            },
          )
        ],
      ),
      body: SafeArea(
          child: Container(
        padding:
            const EdgeInsets.only(left: 15, right: 15, bottom: 50, top: 15),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(width: 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(children: [
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.phone,
                    controller: _textController,
                    decoration: const InputDecoration(
                        border: InputBorder.none, hintText: "Number..."),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                IconButton(
                  onPressed: () {
                    selectContact(Contact(
                        displayName: _textController.text,
                        phones: [Phone(_textController.text)]));
                    _textController.clear();
                  },
                  icon: const Icon(Icons.add_circle_outline_sharp),
                )
              ]),
            ),
            SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                child: Wrap(
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    runAlignment: WrapAlignment.start,
                    children: [
                      ..._selectedContacts.map((c) {
                        return Container(
                            padding: const EdgeInsets.all(5),
                            margin: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(width: 1)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(c.displayName),
                                const SizedBox(
                                  width: 5,
                                ),
                                IconButton(
                                  onPressed: () {
                                    removeSelectedContact(c);
                                  },
                                  icon: const Icon(
                                    Icons.remove_circle_outline_sharp,
                                  ),
                                  color: Colors.red,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                )
                              ],
                            ));
                      })
                    ]),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            FutureBuilder<List<Contact>>(
              future: FlutterContacts.getContacts(withProperties: true),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  _contacts = snapshot.data;

                  return Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _contacts!.length,
                      //prototypeItem: ContactItem(_contacts!.first),
                      cacheExtent: 30,
                      addAutomaticKeepAlives: true,
                      addRepaintBoundaries: true,
                      addSemanticIndexes: true,
                      itemBuilder: (ctx, i) {
                        return ContactItem(_contacts![i], selectContact);
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      )),
    );
  }

  void selectContact(Contact c) {
    if (!_selectedContacts.contains(c)) {
      setState(() {
        _selectedContacts.add(c);
      });
    }
  }

  void removeSelectedContact(Contact c) {
    if (_selectedContacts.contains(c)) {
      setState(() {
        _selectedContacts.remove(c);
      });
    }
  }
}

class ContactItem extends StatelessWidget {
  final Contact c;
  final Function selectContact;
  const ContactItem(
    this.c,
    this.selectContact, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(c.displayName),
      subtitle: Text(
        c.phones.map((e) {
          return e.number;
        }).join("\n"),
      ),
      trailing: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            selectContact(c);
          }),
    );
  }
}
