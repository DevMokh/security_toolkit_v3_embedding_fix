import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/crypto_service.dart';
import '../utils/ui_feedback.dart';
import '../widgets/tool_page.dart';

class EncryptionScreen extends StatefulWidget {
  const EncryptionScreen({super.key});

  @override
  State<EncryptionScreen> createState() => _EncryptionScreenState();
}

class _EncryptionScreenState extends State<EncryptionScreen> {
  final _input = TextEditingController();
  final _password = TextEditingController();
  final _output = TextEditingController();
  bool _busy = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _input.dispose();
    _password.dispose();
    _output.dispose();
    super.dispose();
  }

  Future<void> _encrypt() async {
    setState(() => _busy = true);
    try {
      _output.text = await CryptoService.encryptText(
        plaintext: _input.text,
        password: _password.text,
      );
      showMessage(context, 'تم التشفير باستخدام AES-256-GCM.');
    } on FormatException catch (error) {
      showMessage(context, error.message);
    } catch (_) {
      showMessage(context, 'تعذر إتمام التشفير.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _decrypt() async {
    setState(() => _busy = true);
    try {
      _input.text = await CryptoService.decryptText(
        encoded: _output.text,
        password: _password.text,
      );
      showMessage(context, 'تم فك التشفير والتحقق من سلامة البيانات.');
    } on FormatException catch (error) {
      showMessage(context, error.message);
    } catch (_) {
      showMessage(context, 'فشل فك التشفير: كلمة المرور أو البيانات غير صحيحة.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToolPage(
      title: 'AES-256-GCM Encryption',
      description:
          'تشفير موثّق مع Salt عشوائي واشتقاق مفتاح PBKDF2-HMAC-SHA256. احتفظ بكلمة المرور؛ لا توجد طريقة لاستعادتها.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _input,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'النص الأصلي / النص بعد الفك'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _password,
            obscureText: _hidePassword,
            decoration: InputDecoration(
              labelText: 'كلمة المرور (12 حرفاً على الأقل)',
              suffixIcon: IconButton(
                onPressed: () => setState(() => _hidePassword = !_hidePassword),
                icon: Icon(_hidePassword ? Icons.visibility : Icons.visibility_off),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _busy ? null : _encrypt,
                  child: const Text('تشفير'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : _decrypt,
                  child: const Text('فك التشفير'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_busy) const LinearProgressIndicator(),
          TextField(
            controller: _output,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'الناتج المشفر (STK1 / Base64)',
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _output.text));
                showMessage(context, 'تم نسخ النص المشفر.');
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
