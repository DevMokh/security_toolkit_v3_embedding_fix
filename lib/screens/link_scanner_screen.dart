import 'package:flutter/material.dart';

import '../services/url_analysis_service.dart';
import '../widgets/tool_page.dart';

class LinkScannerScreen extends StatefulWidget {
  const LinkScannerScreen({super.key});

  @override
  State<LinkScannerScreen> createState() => _LinkScannerScreenState();
}

class _LinkScannerScreenState extends State<LinkScannerScreen> {
  final _url = TextEditingController();
  UrlAnalysisResult? _result;
  String? _error;

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  void _analyze() {
    try {
      final result = UrlAnalysisService.analyze(_url.text);
      setState(() {
        _result = result;
        _error = null;
      });
    } on FormatException catch (error) {
      setState(() {
        _result = null;
        _error = error.message;
      });
    }
  }

  Color _riskColor(int score) {
    if (score >= 60) return const Color(0xFFFF6B6B);
    if (score >= 30) return const Color(0xFFFFC16A);
    return const Color(0xFF42E8B4);
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return ToolPage(
      title: 'Link Scanner',
      description:
          'تحليل محلي لبنية الرابط دون فتحه أو إرسال عنوانه إلى خدمة خارجية. النتيجة إرشادية وليست حكماً قطعياً.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _url,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'الرابط المراد تحليله',
              hintText: 'https://example.com/path',
            ),
            onSubmitted: (_) => _analyze(),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: _analyze,
            icon: const Icon(Icons.travel_explore),
            label: const Text('تحليل محلي'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Color(0xFFFF6B6B))),
          ],
          if (result != null) ...[
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'المؤشرات البنيوية',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SelectableText('النطاق: ${result.host}'),
                    Text('المخطط: ${result.scheme.toUpperCase()}'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('مؤشر الاشتباه البنيوي'),
                        const Spacer(),
                        Text(
                          '${result.riskScore}/100',
                          style: TextStyle(
                            color: _riskColor(result.riskScore),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    LinearProgressIndicator(
                      value: result.riskScore / 100,
                      color: _riskColor(result.riskScore),
                      backgroundColor: Colors.white12,
                    ),
                    const SizedBox(height: 12),
                    if (result.findings.isEmpty)
                      const Text('لم تظهر مؤشرات بنيوية من القواعد المحلية الحالية.')
                    else
                      ...result.findings.map(
                        (finding) => Padding(
                          padding: const EdgeInsets.only(bottom: 7),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFFFFC16A),
                                size: 18,
                              ),
                              const SizedBox(width: 7),
                              Expanded(child: Text(finding)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'درجة الاشتباه تقريبية وليست احتمالاً إحصائياً. عدم ظهور مؤشرات لا يعني أن الرابط آمن؛ لم يتم فحص سمعة النطاق أو محتوى الخادم.',
              style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}
