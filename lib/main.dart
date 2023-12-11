import 'dart:convert';

import 'package:calendar_app/widgets/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'hive_objects/category.dart';
import 'hive_objects/event.dart';
import 'widgets/calendar.dart';
import 'widgets/event.dart';

late Box<Category> categoryBox;
late Box<Event> eventBox;

const String categoryBoxName = "categories";
const String eventBoxName = "events";

String customkey = "calendar";

void main() async {
  await Hive.initFlutter();

  const secureStorage = FlutterSecureStorage();

  final encryptionKeyString = await secureStorage.read(key: customkey);

  if (encryptionKeyString == null) {
    final key = Hive.generateSecureKey();
    await secureStorage.write(key: customkey, value: base64UrlEncode(key));
  }

  final key = await secureStorage.read(key: customkey);
  final encryptionKeyUnit8List = base64Url.decode(key!);

  Hive.registerAdapter<Category>(CategoryAdapter());
  Hive.registerAdapter<Event>(EventAdapter());

  categoryBox = await Hive.openBox<Category>(categoryBoxName,
      encryptionCipher: HiveAesCipher(encryptionKeyUnit8List));
  eventBox = await Hive.openBox<Event>(eventBoxName,
      encryptionCipher: HiveAesCipher(encryptionKeyUnit8List));

  await categoryBox.compact();
  await eventBox.compact();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar App',
      theme: ThemeData(
        textTheme: Theme.of(context)
            .textTheme
            .apply(fontFamily: GoogleFonts.poppins().fontFamily),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent),
        useMaterial3: true,
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => const Calendar(),
        EventDetails.routeName: (context) => const EventDetails(),
        CategoryDetail.routeName: (context) => const CategoryDetail()
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
