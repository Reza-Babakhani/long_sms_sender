import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:long_sms_sender/utils/text_util.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tapsell_plus/tapsell_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final List<Contact> _selectedContacts = [];
  String _search = "";
  final TextEditingController _textController = TextEditingController();

  Future<void> ad() async {
    String adId = await TapsellPlus.instance
        .requestInterstitialAd("640af8a6972aed14bd5e31c5");

    await TapsellPlus.instance.showInterstitialAd(adId, onOpened: (map) {
      // Ad opened
    }, onError: (map) {
      // Error when showing ad
    });
  }

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      _message = ModalRoute.of(context)!.settings.arguments as String;

      await ad();

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
                content:
                    Text("لطفاً مجوز ارسال پیامک را از تنظیمات فعال کنید."),
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
            msg: "$successCount/$msgCount پیامک با موفقیت ارسال شد",
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("ارسال به..."),
          actions: [
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () async {
                if (_selectedContacts.isEmpty) {
                  Fluttertoast.showToast(
                      msg: "لطفا حداقل یک مخاطب را انتخاب کنید.",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.black87,
                      textColor: Colors.white,
                      fontSize: 16.0);
                } else {
                  await _sendSMS().then((value) async {
                    if (_selectedContacts.length == 1) {
                      Uri sms = Uri.parse(
                          'sms:${_selectedContacts.first.phones.first.number}');
                      if (await launchUrl(sms)) {
                        //app opened
                      } else {
                        //app is not opened
                      }
                    }
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
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
                          hintText: "جستجو یا ورود شماره تلفن..."),
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
                                "برای افزودن یک مخاطب به صورت دستی، باید یک شماره تلفن معتبر وارد کنید.",
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
      ),
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
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.end,
      ),
      trailing: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            selectContact(c);
          }),
    );
  }
}
