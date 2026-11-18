import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/steganography_service.dart';
import '../utils/ui_feedback.dart';
import '../widgets/tool_page.dart';

class SteganographyScreen extends StatefulWidget {
  const SteganographyScreen({super.key});

  @override
  State<SteganographyScreen> createState() => _SteganographyScreenState();
}

class _SteganographyScreenState extends State<SteganographyScreen> {
  final _carrier = TextEditingController(
    text: 'هذه رسالة عادية للتوعية بأهمية فحص النصوص.',
  );
  final _secret = TextEditingController();
  final _encoded = TextEditingController();
  final _extracted = TextEditingController();

  @override
  void dispose() {
    _carrier.dispose();
    _secret.dispose();
    _encoded.dispose();
    _extracted.dispose();
    super.dispose();
  }

  void _hide() {
    try {
      _encoded.text = SteganographyService.hide(
        carrier: _carrier.text,
        secret: _secret.text,
      );
      showMessage(context, 'تم إخفاء النص داخل الرسالة.');
    } on FormatException catch (error) {
      showMessage(context, error.message);
    }
  }

  void _extract() {
    try {
      _extracted.text = SteganographyService.extract(_encoded.text);
    } on FormatException catch (error) {
      showMessage(context, error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToolPage(
      title: 'Steganography',
      description:
          'إخفاء واستخراج نصوص باستخدام محارف Unicode عديمة العرض. هذه طريقة توضيحية وليست تشفيراً.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _carrier,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'الرسالة الحاملة'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _secret,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'النص المراد إخفاؤه'),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: _hide,
            icon: const Icon(Icons.visibility_off_outlined),
            label: const Text('إخفاء النص'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _encoded,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'النص الناتج أو الصق نصاً لاستخراجه',
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _extract,
            icon: const Icon(Icons.visibility_outlined),
            label: const Text('استخراج النص المخفي'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _extracted,
            readOnly: true,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'النص المستخرج'),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _encoded.text));
                showMessage(context, 'تم نسخ النص الناتج.');
              },
              icon: const Icon(Icons.copy),
              label: const Text('نسخ الناتج'),
            ),
          ),
        ],
      ),
    );
  }
}
