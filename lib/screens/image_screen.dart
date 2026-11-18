import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import '../utils/ui_feedback.dart';
import '../widgets/tool_page.dart';

class ImageAwarenessScreen extends StatefulWidget {
  const ImageAwarenessScreen({super.key});

  @override
  State<ImageAwarenessScreen> createState() => _ImageAwarenessScreenState();
}

class _ImageAwarenessScreenState extends State<ImageAwarenessScreen> {
  final _picker = ImagePicker();
  Uint8List? _cleanedBytes;
  String? _cleanedName;
  String _status = 'اختر صورة لتجربة إزالة بياناتها الوصفية.';
  bool _processing = false;

  Future<void> _pick(ImageSource source) async {
    if (source == ImageSource.camera) {
      final permission = await Permission.camera.request();
      if (!permission.isGranted) {
        if (mounted) showMessage(context, 'لم يتم منح صلاحية الكاميرا.');
        return;
      }
    }

    try {
      final picked = await _picker.pickImage(
        source: source,
        requestFullMetadata: false,
        imageQuality: 100,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      if (bytes.length > 20 * 1024 * 1024) {
        if (mounted) showMessage(context, 'حجم الصورة يتجاوز الحد التجريبي (20MB).');
        return;
      }

      setState(() {
        _processing = true;
        _status = 'جارٍ إعادة ترميز الصورة وحذف البيانات الوصفية...';
      });

      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        throw const FormatException('صيغة الصورة غير مدعومة أو الملف تالف.');
      }

      final extension = picked.name.toLowerCase().split('.').last;
      if (!{'jpg', 'jpeg', 'png', 'webp'}.contains(extension)) {
        throw const FormatException(
          'يدعم التنظيف حالياً JPG وJPEG وPNG وWebP فقط.',
        );
      }
      late final Uint8List cleaned;
      late final String outputExtension;
      late final String mimeType;

      if (extension == 'png') {
        cleaned = Uint8List.fromList(img.encodePng(decoded));
        outputExtension = 'png';
        mimeType = 'image/png';
      } else if (extension == 'webp') {
        cleaned = Uint8List.fromList(img.encodeJpg(decoded, quality: 94));
        outputExtension = 'jpg';
        mimeType = 'image/jpeg';
      } else {
        cleaned = Uint8List.fromList(img.encodeJpg(decoded, quality: 94));
        outputExtension = 'jpg';
        mimeType = 'image/jpeg';
      }

      if (!mounted) return;
      setState(() {
        _cleanedBytes = cleaned;
        _cleanedName =
            'security_toolkit_cleaned_${DateTime.now().millisecondsSinceEpoch}.$outputExtension';
        _status =
            'تمت إعادة ترميز الصورة. إعادة الترميز تزيل عادةً بيانات EXIF المضمنة، لكن افحص الملف الناتج قبل مشاركته.';
      });
      _mimeType = mimeType;
    } on FormatException catch (error) {
      if (mounted) showMessage(context, error.message);
    } catch (_) {
      if (mounted) showMessage(context, 'تعذر معالجة الصورة.');
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  String _mimeType = 'image/jpeg';

  Future<void> _share() async {
    final bytes = _cleanedBytes;
    final name = _cleanedName;
    if (bytes == null || name == null) return;

    try {
      await SharePlus.instance.share(
        ShareParams(
          title: 'صورة بعد إزالة البيانات الوصفية',
          text: 'نسخة توعوية أعيد ترميزها لإزالة بيانات EXIF المعتادة.',
          files: [
            XFile.fromData(
              bytes,
              mimeType: _mimeType,
            ),
          ],
          fileNameOverrides: [name],
        ),
      );
    } catch (_) {
      if (mounted) showMessage(context, 'تعذر فتح قائمة مشاركة الصورة.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToolPage(
      title: 'Image Metadata Awareness',
      description:
          'اختر صورة أو التقط صورة، ثم أعد ترميزها لإزالة بيانات EXIF المعتادة. لا يتم إدخال أو إخفاء أي Payload تنفيذي.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.image_search_outlined,
                    size: 42,
                    color: Color(0xFF42E8B4),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'قد تحتوي بيانات EXIF على طراز الجهاز ووقت التصوير وأحياناً إحداثيات GPS.',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _status,
                    style: TextStyle(color: Colors.grey.shade300, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _processing ? null : () => _pick(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('اختيار صورة من المعرض'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _processing ? null : () => _pick(ImageSource.camera),
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('التقاط صورة'),
          ),
          if (_processing) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
          if (_cleanedBytes != null) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(
                _cleanedBytes!,
                height: 220,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const SizedBox(height: 100, child: Center(child: Text('تعذر عرض الصورة'))),
              ),
            ),
            const SizedBox(height: 8),
            SelectableText('اسم الملف: $_cleanedName'),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _share,
              icon: const Icon(Icons.share_outlined),
              label: const Text('مشاركة / حفظ النسخة المنظفة'),
            ),
          ],
          const SizedBox(height: 12),
          const Text(
            'محاكاة الـ Payload: تعرض الفكرة باستخدام نص تدريبي فقط. لا يتم تضمين ملفات تنفيذية أو محتوى ضار في الصور.',
            style: TextStyle(color: Color(0xFFFFC16A), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
