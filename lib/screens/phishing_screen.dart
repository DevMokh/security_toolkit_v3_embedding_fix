import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/ui_feedback.dart';
import '../widgets/tool_page.dart';

class PhishingAwarenessScreen extends StatefulWidget {
  const PhishingAwarenessScreen({super.key});

  @override
  State<PhishingAwarenessScreen> createState() =>
      _PhishingAwarenessScreenState();
}

class _PhishingAwarenessScreenState extends State<PhishingAwarenessScreen> {
  final _organization = TextEditingController(text: 'Example Company');
  final _campaign = TextEditingController(text: 'Security Awareness Week');
  final _message = TextEditingController();
  String _scenario = 'account';

  @override
  void dispose() {
    _organization.dispose();
    _campaign.dispose();
    _message.dispose();
    super.dispose();
  }

  void _generate() {
    final organization = _organization.text.trim().isEmpty
        ? 'Example Company'
        : _organization.text.trim();
    final campaign = _campaign.text.trim().isEmpty
        ? 'Security Awareness Week'
        : _campaign.text.trim();

    final scenarioText = switch (_scenario) {
      'delivery' => 'هناك تحديث تدريبي افتراضي لحالة شحنة.',
      'account' => 'توجد رسالة تدريبية تزعم ضرورة مراجعة إعدادات الحساب.',
      _ => 'توجد رسالة تدريبية تزعم وجود مستند جديد بانتظار المراجعة.',
    };

    _message.text = '''
[تمرين توعية أمنية — لا تُرسل كرسالة حقيقية]

الجهة التجريبية: $organization
الحملة: $campaign

مرحباً،
$scenarioText

هذا رابط تدريبي آمن لا يجمع بيانات:
https://example.com/security-awareness

مؤشرات يجب على المتدرب ملاحظتها:
• الاستعجال أو الضغط لاتخاذ إجراء.
• التحقق من اسم النطاق قبل فتح أي رابط.
• عدم إدخال كلمة مرور عبر رابط وصل برسالة.
• التواصل مع الجهة عبر قناة معروفة مستقلة عن الرسالة.

[نهاية المحاكاة التدريبية]
''';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ToolPage(
      title: 'Phishing Awareness Lab',
      description:
          'إنشاء رسائل محاكاة موسومة بوضوح لأغراض التوعية. لا تنشئ روابط خبيثة أو صفحات دخول مزيفة ولا تجمع بيانات اعتماد.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _organization,
            decoration: const InputDecoration(labelText: 'اسم الجهة التجريبية'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _campaign,
            decoration: const InputDecoration(labelText: 'اسم حملة التوعية'),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _scenario,
            decoration: const InputDecoration(labelText: 'سيناريو التدريب'),
            items: const [
              DropdownMenuItem(value: 'account', child: Text('تنبيه حساب تجريبي')),
              DropdownMenuItem(value: 'delivery', child: Text('إشعار شحنة تجريبية')),
              DropdownMenuItem(value: 'document', child: Text('مستند للمراجعة')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _scenario = value);
            },
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: _generate,
            icon: const Icon(Icons.auto_awesome_outlined),
            label: const Text('إنشاء رسالة المحاكاة'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _message,
            maxLines: 13,
            decoration: const InputDecoration(labelText: 'رسالة التدريب'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _message.text.isEmpty
                ? null
                : () {
                    Clipboard.setData(ClipboardData(text: _message.text));
                    showMessage(context, 'تم نسخ رسالة التدريب.');
                  },
            icon: const Icon(Icons.copy),
            label: const Text('نسخ الرسالة'),
          ),
        ],
      ),
    );
  }
}
