import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/section_model.dart';

class SectionController extends GetxController {
  var sections = <Section>[].obs;
  late Box<Section> sectionBox;

  @override
  void onInit() {
    super.onInit();
    sectionBox = Hive.box<Section>('sections');
    loadSections();
  }

  void loadSections() {
    sections.value = sectionBox.values.toList();
  }

  void addSection(Section section) async {
    await sectionBox.put(section.id, section);
    sections.add(section);
    update();
  }

  void editSection(String id, Section updated) async {
    await sectionBox.put(id, updated);
    int idx = sections.indexWhere((s) => s.id == id);
    if (idx != -1) sections[idx] = updated;
  }

  void deleteSection(String id) async {
    await sectionBox.delete(id);
    sections.removeWhere((s) => s.id == id);
  }

  void refreshSections() async {
    final box = await Hive.openBox<Section>('sections');
    sections.value = box.values.toList();
    update();
  }

  // Placeholder for sync logic
  Future<void> syncSection(Section section) async {
    // TODO: Implement Firestore sync and set section.synced = true on success
  }
}
