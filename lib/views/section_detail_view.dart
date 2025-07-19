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
import '../controllers/record_controller.dart';
import 'package:flutter/foundation.dart';

class SectionDetailView extends StatefulWidget {
  final Section section;
  final String userId;
  const SectionDetailView(
      {Key? key, required this.section, required this.userId})
      : super(key: key);

  @override
  State<SectionDetailView> createState() => _SectionDetailViewState();
}

class _SectionDetailViewState extends State<SectionDetailView> {
  late SectionController sectionController;
  late RecordController recordController;
  late FieldController fieldController;

  @override
  void initState() {
    super.initState();
    debugPrint(
        '[UI] SectionDetailView initialized for section: ${widget.section.id}, user: ${widget.userId}');
    if (Get.isRegistered<SectionController>(tag: widget.userId)) {
      sectionController = Get.find<SectionController>(tag: widget.userId);
    } else {
      sectionController =
          Get.put(SectionController(userId: widget.userId), tag: widget.userId);
    }
    // Register FieldController and RecordController for this section+user
    final tag = '${widget.section.id}_${widget.userId}';
    if (!Get.isRegistered<FieldController>(tag: tag)) {
      fieldController = Get.put(
          FieldController(sectionId: widget.section.id, userId: widget.userId),
          tag: tag);
    }
    if (!Get.isRegistered<RecordController>(tag: tag)) {
      recordController = Get.put(
          RecordController(sectionId: widget.section.id, userId: widget.userId),
          tag: tag);
    }
    // RecordsTab and FieldsTab will use ValueListenableBuilder to automatically update
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        '[UI] SectionDetailView build for section: ${widget.section.id}');
    final iconData = sectionIcons.firstWhere(
      (icon) => icon['value'] == widget.section.icon,
      orElse: () => sectionIcons.first,
    );
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            widget.section.name,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: widget.section.color != null
              ? Color(
                  int.parse(widget.section.color!.replaceFirst('#', '0xff')))
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
            RecordsTab(section: widget.section, userId: widget.userId),
            // Fields Tab
            FieldsTab(section: widget.section, userId: widget.userId),
            // Settings Tab
            SettingsTab(section: widget.section, userId: widget.userId),
          ],
        ),
      ),
    );
  }
}
