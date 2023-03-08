import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactListScreen extends StatefulWidget {
  static const String routeName = "contacts";
  const ContactListScreen({super.key});

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  String? _message;
  bool _isInit = true;
  List<Contact>? _contacts;
  List<Contact> _selectedContacts = [];
  @override
  void didChangeDependencies() {
    if (_isInit) {
      _message = ModalRoute.of(context)!.settings.arguments as String;

      _isInit = false;
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Send To..."),
      ),
      body: SafeArea(
          child: Container(
        padding:
            const EdgeInsets.only(left: 15, right: 15, bottom: 50, top: 15),
        child: Column(
          children: [
            Container(
              height: 250,
              child: Row(children: [
                ..._selectedContacts
                    .map((e) => Text(e.phones.map((e) => e.number).join(",")))
              ]),
            ),
            const Divider(
              height: 2,
              color: Colors.grey,
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
