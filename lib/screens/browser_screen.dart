import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

import '../utils/ui_feedback.dart';
import '../widgets/tool_page.dart';

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  final _address = TextEditingController(text: 'https://example.com');
  late final WebViewController _controller;
  String _pageStatus = 'لم يتم فتح صفحة بعد';
  String _serverStatus = 'لم يتم الفحص';
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.disabled)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _pageStatus = 'جارٍ التحميل');
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _pageStatus = 'تم التحميل');
          },
          onWebResourceError: (_) {
            if (mounted) setState(() => _pageStatus = 'حدث خطأ في تحميل الصفحة');
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null || uri.scheme != 'https') {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
  }

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  void _openPage() {
    final uri = Uri.tryParse(_address.text.trim());
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      showMessage(context, 'المتصفح المدمج يسمح بروابط HTTPS فقط.');
      return;
    }
    _controller.loadRequest(uri);
  }

  Future<void> _checkServer() async {
    setState(() {
      _checking = true;
      _serverStatus = 'جارٍ الاتصال بخدمة NVD...';
    });
    try {
      final response = await http
          .get(
            Uri.https(
              'services.nvd.nist.gov',
              '/rest/json/cves/2.0',
              {'resultsPerPage': '1'},
            ),
          )
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;
      setState(() {
        _serverStatus = response.statusCode == 200
            ? 'متصل • NVD HTTP 200'
            : 'استجابة الخادم: HTTP ${response.statusCode}';
      });
    } catch (_) {
      if (mounted) setState(() => _serverStatus = 'غير متاح حالياً');
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToolPage(
      title: 'Server Status & WebView',
      description:
          'فحص اتصال خدمة NVD العامة ومتصفح مدمج يقيّد التنقل على HTTPS ويعطّل JavaScript افتراضياً.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'حالة الخدمة',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 7),
                  Text(_serverStatus),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _checking ? null : _checkServer,
                    icon: const Icon(Icons.sync),
                    label: const Text('اختبار اتصال NVD'),
                  ),
                  if (_checking) const LinearProgressIndicator(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _address,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'عنوان HTTPS',
              hintText: 'https://example.com',
            ),
            onSubmitted: (_) => _openPage(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _openPage,
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('فتح الصفحة'),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _pageStatus,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 390,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: WebViewWidget(controller: _controller),
            ),
          ),
        ],
      ),
    );
  }
}
