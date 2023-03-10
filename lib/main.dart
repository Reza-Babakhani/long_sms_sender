import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:long_sms_sender/screens/contact_list_screen.dart';
import 'package:tapsell_plus/tapsell_plus.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());

  const appId =
      "omkpnchrbnpqitobcieqlbceqhqgbbdcernactokglbqafaqliojeqnitnholqbrsbsjlt";
  TapsellPlus.instance.initialize(appId);
  TapsellPlus.instance.setGDPRConsent(true);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> ad() async {
    String adId = await TapsellPlus.instance.requestStandardBannerAd(
        "6408c187bd020942896e7229", TapsellPlusBannerType.BANNER_320x50);

    await TapsellPlus.instance.showStandardBannerAd(adId,
        TapsellPlusHorizontalGravity.BOTTOM, TapsellPlusVerticalGravity.CENTER,
        margin: const EdgeInsets.only(bottom: 1), onOpened: (map) {
      // Ad opened
    }, onError: (map) {
      // Error when showing ad
    });
  }

  bool _isInit = true;

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      bool result = await InternetConnectionChecker().hasConnection;
      if (result == true) {
        await ad();
      }
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Send long sms',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.grey, fontFamily: "Vazir"),
      home: const HomeScreen(),
      routes: {
        ContactListScreen.routeName: (ctx) => const ContactListScreen(),
      },
    );
  }
}
