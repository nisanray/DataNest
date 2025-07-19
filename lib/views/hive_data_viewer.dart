import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class HiveDataViewer extends StatefulWidget {
  const HiveDataViewer({Key? key}) : super(key: key);

  @override
  State<HiveDataViewer> createState() => _HiveDataViewerState();
}

class _HiveDataViewerState extends State<HiveDataViewer> {
  final List<String> boxes = ['sections', 'records', 'fields'];
  String selectedBox = 'sections';
  List<dynamic> boxData = [];
  bool loading = false;

  Future<void> loadBox() async {
    debugPrint('[UI] Loading data for box: $selectedBox');
    setState(() => loading = true);
    final box = await Hive.openBox(selectedBox);
    setState(() {
      boxData = box.values.toList();
      loading = false;
    });
    debugPrint('[UI] Loaded ${boxData.length} items from Hive');
  }

  String _prettyJson(dynamic obj) {
    try {
      return const JsonEncoder.withIndent('  ')
          .convert(obj is Map ? obj : obj?.toJson() ?? obj?.toString());
    } catch (_) {
      return obj?.toString() ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[UI] HiveDataViewer build');
    return AlertDialog(
      title: const Text('View Hive Data'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: selectedBox,
              items: boxes
                  .map((b) => DropdownMenuItem(
                        value: b,
                        child: Text(b),
                      ))
                  .toList(),
              onChanged: (val) async {
                if (val != null) {
                  debugPrint('[UI] Selected box changed to: $val');
                  setState(() => selectedBox = val);
                  await loadBox();
                }
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: loadBox,
              child: const Text('Load Data'),
            ),
            const SizedBox(height: 12),
            if (loading)
              const CircularProgressIndicator()
            else
              SizedBox(
                height: 300,
                child: SingleChildScrollView(
                  child: Text(
                    boxData.isEmpty
                        ? 'No data.'
                        : boxData.map((e) => _prettyJson(e)).join('\n\n'),
                    style:
                        const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
