import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:long_sms_sender/utils/text_util.dart';
import 'package:permission_handler/permission_handler.dart';

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
  String _search = "";
  TextEditingController _textController = TextEditingController();
  @override
  void didChangeDependencies() {
    if (_isInit) {
      _message = ModalRoute.of(context)!.settings.arguments as String;

      _isInit = false;
    }

    super.didChangeDependencies();
  }

  Future _sendSMS() async {
    if (await Permission.sms.isPermanentlyDenied) {
      if (context.mounted) {
        await showDialog(
            context: context,
            builder: (ctx) {
              return const AlertDialog(
                content: Text(
                    "Please activate the permission to send SMS from the settings."),
              );
            });
        openAppSettings();
      }
    }

    if (await Permission.sms.request().isGranted) {
      var msgs = TextUtil.splitEveryNth(_message, 159);
      var msgCount = TextUtil.countSequence(_message, 159);
      int successCount = 0;
      for (String? m in msgs) {
        var result = await sendSMS(
            message: m!,
            recipients:
                _selectedContacts.map((e) => e.phones.first.number).toList(),
            sendDirect: true);

        if (result == "SMS Sent!") {
          successCount++;
        }
      }

      if (successCount == msgCount) {
        Fluttertoast.showToast(
            msg: "$successCount/$msgCount SMS sent successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black87,
            textColor: Colors.white,
            fontSize: 16.0);
      }
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
            onPressed: () async {
              if (_selectedContacts.isEmpty) {
                Fluttertoast.showToast(
                    msg: "Please select at least one contact.",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black87,
                    textColor: Colors.white,
                    fontSize: 16.0);
              } else {
                await _sendSMS().then((value) {
                  Navigator.of(context).pop();
                });
              }
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
                    //keyboardType: TextInputType.phone,
                    controller: _textController,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search Contact or Add Number..."),
                    onChanged: (value) {
                      setState(() {
                        _search = value.toLowerCase();
                      });
                    },
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                IconButton(
                  onPressed: () async {
                    if (TextUtil.phoneNumberValidate(_textController.text)) {
                      selectContact(Contact(
                          displayName: _textController.text,
                          phones: [Phone(_textController.text)]));
                      _textController.clear();
                    } else {
                      Fluttertoast.showToast(
                          msg:
                              "To add a contact manually, a valid phone number must be entered.",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.black87,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    }
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
                  if (_search.isEmpty) {
                    _contacts = snapshot.data;
                  } else {
                    _contacts = snapshot.data!.where((element) {
                      var nameIgnoreCase = element.displayName.toLowerCase();
                      var phones = element.phones
                          .map((p) => p.number.replaceAll(" ", ""))
                          .toList();
                      return nameIgnoreCase.contains(_search) ||
                          phones.any((phone) => phone.contains(_search));
                    }).toList();
                  }

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
