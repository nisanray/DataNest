import 'package:flutter/material.dart';
import '../models/section_model.dart';
import 'section_create_view.dart' show sectionIcons;
import 'records_tab.dart';
import 'fields_tab.dart';
import '../controllers/field_controller.dart';
import '../controllers/section_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'settings_tab.dart';

class SectionDetailView extends StatelessWidget {
  final Section section;
  final String userId;
  const SectionDetailView(
      {Key? key, required this.section, required this.userId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconData = sectionIcons.firstWhere(
      (icon) => icon['value'] == section.icon,
      orElse: () => sectionIcons.first,
    );
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            section.name,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: section.color != null
              ? Color(int.parse(section.color!.replaceFirst('#', '0xff')))
              : null,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[350],
            tabs: [
              Tab(
                text: 'Records',
                icon: Icon(Icons.table_rows),
              ),
              Tab(
                text: 'Fields',
                icon: Icon(Icons.view_column),
              ),
              Tab(
                text: 'Settings',
                icon: Icon(Icons.settings),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Records Tab
            RecordsTab(section: section, userId: userId),
            // Fields Tab
            FieldsTab(section: section, userId: userId),
            // Settings Tab
            SettingsTab(section: section, userId: userId),
          ],
        ),
      ),
    );
  }
}
