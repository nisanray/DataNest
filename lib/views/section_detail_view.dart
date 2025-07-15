import 'package:flutter/material.dart';
import '../models/section_model.dart';
import 'section_create_view.dart' show sectionIcons;
import 'records_tab.dart';
import 'fields_tab.dart';

class SectionDetailView extends StatelessWidget {
  final Section section;
  const SectionDetailView({Key? key, required this.section}) : super(key: key);

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
          title: Text(section.name),
          backgroundColor: section.color != null
              ? Color(int.parse(section.color!.replaceFirst('#', '0xff')))
              : null,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Records', icon: Icon(Icons.table_rows)),
              Tab(text: 'Fields', icon: Icon(Icons.view_column)),
              Tab(text: 'Settings', icon: Icon(Icons.settings)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Records Tab
            RecordsTab(section: section),
            // Fields Tab
            FieldsTab(section: section),
            // Settings Tab
            Center(
              child: Text(
                'Section settings will appear here.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
