import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'models/section_model.dart';
import 'models/record_model.dart';
import 'models/field_model.dart';
import 'controllers/section_controller.dart';
import 'views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(SectionAdapter());
  Hive.registerAdapter(RecordAdapter());
  Hive.registerAdapter(FieldAdapter()); // Register FieldAdapter
  await Hive.openBox<Section>('sections');
  await Hive.openBox<Record>('records');
  await Hive.openBox<Field>('fields'); // Open fields box
  await Firebase.initializeApp();

  // Initialize SectionController
  Get.put(SectionController());

  runApp(const DataNestApp());
}

class DataNestApp extends StatelessWidget {
  const DataNestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DataNest',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      // Set HomeView as the home page
      home: HomeView(),
    );
  }
}
