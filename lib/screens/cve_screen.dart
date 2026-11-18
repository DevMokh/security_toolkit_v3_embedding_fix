import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/ui_feedback.dart';
import '../widgets/tool_page.dart';

class CveScreen extends StatefulWidget {
  const CveScreen({super.key});

  @override
  State<CveScreen> createState() => _CveScreenState();
}

class _CveScreenState extends State<CveScreen> {
  final _query = TextEditingController(text: 'zero click');
  List<Map<String, dynamic>> _items = [];
  bool _loading = false;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() => _loading = true);
    try {
      final keyword = _query.text.trim();
      final uri = Uri.https(
        'services.nvd.nist.gov',
        '/rest/json/cves/2.0',
        {
          if (keyword.isNotEmpty) 'keywordSearch': keyword,
          'resultsPerPage': '20',
        },
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 25));
      if (response.statusCode != 200) {
        throw Exception('NVD HTTP ${response.statusCode}');
      }
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final rows = (decoded['vulnerabilities'] as List? ?? const []);
      _items = rows
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .toList();
    } catch (_) {
      if (mounted) showMessage(context, 'تعذر الوصول إلى قاعدة بيانات NVD.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _description(Map<String, dynamic> cve) {
    final descriptions = cve['descriptions'] as List? ?? const [];
    for (final item in descriptions.whereType<Map>()) {
      if (item['lang'] == 'en') return '${item['value'] ?? ''}';
    }
    if (descriptions.isNotEmpty && descriptions.first is Map) {
      return '${descriptions.first['value'] ?? 'لا يوجد وصف'}';
    }
    return 'لا يوجد وصف متاح.';
  }

  String _severity(Map<String, dynamic> cve) {
    final metrics = cve['metrics'] as Map? ?? const {};
    const preference = [
      'cvssMetricV40',
      'cvssMetricV31',
      'cvssMetricV30',
      'cvssMetricV2',
    ];
    for (final key in preference) {
      final values = metrics[key] as List? ?? const [];
      if (values.isEmpty || values.first is! Map) continue;
      final data = values.first['cvssData'] as Map? ?? const {};
      final score = data['baseScore'];
      final severity = data['baseSeverity'];
      if (score != null) {
        return 'CVSS $score${severity == null ? '' : ' • $severity'}';
      }
    }
    return 'لم يتوفر تقييم CVSS';
  }

  @override
  Widget build(BuildContext context) {
    return ToolPage(
      title: 'CVE Vulnerabilities',
      description:
          'بحث في قاعدة NVD العامة وعرض أوصاف الثغرات وتقييم CVSS المتاح. المعلومات للاستطلاع والتحديث الدفاعي.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _query,
            decoration: const InputDecoration(
              labelText: 'كلمات البحث',
              hintText: 'zero click, android, browser',
            ),
            onSubmitted: (_) => _search(),
          ),
          const SizedBox(height: 9),
          FilledButton.icon(
            onPressed: _loading ? null : _search,
            icon: const Icon(Icons.search),
            label: Text(_loading ? 'جارٍ البحث...' : 'بحث في NVD'),
          ),
          const SizedBox(height: 12),
          if (_loading) const LinearProgressIndicator(),
          if (!_loading && _items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('لا توجد نتائج معروضة. ابدأ ببحث جديد.'),
            ),
          ..._items.map((row) {
            final cve = Map<String, dynamic>.from(row['cve'] as Map? ?? {});
            final id = '${cve['id'] ?? 'CVE'}';
            return Card(
              margin: const EdgeInsets.only(bottom: 9),
              child: ExpansionTile(
                title: Text(
                  id,
                  style: const TextStyle(
                    color: Color(0xFF42E8B4),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: Text(_severity(cve)),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(_description(cve)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
