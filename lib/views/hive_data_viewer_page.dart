import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/section_model.dart';
import '../models/record_model.dart';
import '../models/field_model.dart';
// Removed unused GetX import

class HiveDataViewerPage extends StatefulWidget {
  const HiveDataViewerPage({Key? key}) : super(key: key);

  @override
  State<HiveDataViewerPage> createState() => _HiveDataViewerPageState();
}

class _HiveDataViewerPageState extends State<HiveDataViewerPage> {
  final List<String> boxNames = ['sections', 'records', 'fields'];
  String selectedBox = 'sections';
  List<dynamic> boxData = [];
  bool loading = false;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    debugPrint('[UI] HiveDataViewerPage initialized');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBoxData(selectedBox);
    });
  }

  Future<void> _loadBoxData(String boxName) async {
    setState(() => loading = true);
    debugPrint('[UI] Loading data for box: $boxName');
    try {
      List<dynamic> data;
      switch (boxName) {
        case 'sections':
          data = Hive.box<Section>(boxName).values.toList();
          break;
        case 'records':
          data = Hive.box<Record>(boxName).values.toList();
          break;
        case 'fields':
          data = Hive.box<Field>(boxName).values.toList();
          break;
        default:
          data = Hive.box(boxName).values.toList();
      }
      setState(() {
        boxData = data;
        selectedBox = boxName;
        loading = false;
      });
      debugPrint(
          '[UI] Loaded ${boxData.length} items from Hive for box: $boxName');
    } catch (e) {
      setState(() {
        boxData = [];
        selectedBox = boxName;
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading box: $e')),
      );
      debugPrint('[UI] Error loading box: $boxName, Error: $e');
    }
  }

  void _clearBox() async {
    debugPrint('[UI] Clearing box: $selectedBox');
    switch (selectedBox) {
      case 'sections':
        await Hive.box<Section>(selectedBox).clear();
        break;
      case 'records':
        await Hive.box<Record>(selectedBox).clear();
        break;
      case 'fields':
        await Hive.box<Field>(selectedBox).clear();
        break;
      default:
        await Hive.box(selectedBox).clear();
    }
    _loadBoxData(selectedBox);
    debugPrint('[UI] Box cleared: $selectedBox');
  }

  List<dynamic> get filteredData {
    debugPrint('[UI] Filtering data with query: $searchQuery');
    if (searchQuery.isEmpty) {
      debugPrint('[UI] No search query, returning all data.');
      return boxData;
    }
    final filtered = boxData
        .where((item) =>
            item.toString().toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
    debugPrint('[UI] Filtered data length: ${filtered.length}');
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[UI] HiveDataViewerPage build');
    String prettyJson(dynamic obj) {
      try {
        if (obj is Section || obj is Record || obj is Field) {
          return JsonEncoder.withIndent('  ').convert(obj.toJson());
        }
        return JsonEncoder.withIndent('  ').convert(obj);
      } catch (_) {
        return obj?.toString() ?? '';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hive Data Viewer'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => _loadBoxData(selectedBox),
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Clear Box',
            onPressed: _clearBox,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedBox,
                    items: boxNames
                        .map((name) => DropdownMenuItem(
                              value: name,
                              child: Text(name),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        debugPrint('[UI] Selected box changed to: $val');
                        _loadBoxData(val);
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Hive Box',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (val) {
                      debugPrint('[UI] Search query changed to: $val');
                      setState(() => searchQuery = val);
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (loading) {
                  debugPrint('[UI] Loading indicator shown.');
                  // Show progress only for a short time, not continuously
                  return const Center(child: CircularProgressIndicator());
                }
                if (filteredData.isEmpty) {
                  debugPrint('[UI] No data found.');
                  return const Center(child: Text('No data found.'));
                }
                debugPrint('[UI] Displaying ${filteredData.length} items.');
                return ListView.builder(
                  itemCount: filteredData.length,
                  itemBuilder: (context, index) {
                    final item = filteredData[index];
                    debugPrint('[UI] Building item $index: $item');
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      elevation: 3,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple.shade100,
                          child: Text('${index + 1}',
                              style: const TextStyle(color: Colors.deepPurple)),
                        ),
                        title: Text('Key: $index',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: SelectableText(
                          prettyJson(item),
                          style: const TextStyle(
                              fontFamily: 'monospace', fontSize: 14),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.copy),
                          tooltip: 'Copy',
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: prettyJson(item)));
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Copied!')));
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
