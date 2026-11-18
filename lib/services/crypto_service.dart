import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

class CryptoService {
  static const String _prefix = 'STK1:';

  static Future<SecretKey> _deriveKey(
    String password,
    List<int> salt,
  ) async {
    final derivation = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 310000,
      bits: 256,
    );

    return derivation.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
  }

  static Future<String> encryptText({
    required String plaintext,
    required String password,
  }) async {
    if (password.length < 12) {
      throw const FormatException(
        'استخدم كلمة مرور لا تقل عن 12 حرفاً.',
      );
    }
    if (plaintext.isEmpty) {
      throw const FormatException('لا يوجد نص لتشفيره.');
    }

    final random = Random.secure();
    final salt = List<int>.generate(16, (_) => random.nextInt(256));
    final algorithm = AesGcm.with256bits();
    final nonce = algorithm.newNonce();
    final key = await _deriveKey(password, salt);
    final secretBox = await algorithm.encrypt(
      utf8.encode(plaintext),
      secretKey: key,
      nonce: nonce,
    );

    final packed = <int>[
      ...salt,
      ...nonce,
      ...secretBox.cipherText,
      ...secretBox.mac.bytes,
    ];
    return '$_prefix${base64Encode(packed)}';
  }

  static Future<String> decryptText({
    required String encoded,
    required String password,
  }) async {
    if (password.isEmpty) {
      throw const FormatException('أدخل كلمة المرور.');
    }
    if (!encoded.startsWith(_prefix)) {
      throw const FormatException('تنسيق النص المشفر غير معروف.');
    }

    final bytes = base64Decode(encoded.substring(_prefix.length).trim());
    if (bytes.length < 44) {
      throw const FormatException('البيانات المشفرة غير مكتملة.');
    }

    final salt = bytes.sublist(0, 16);
    final nonce = bytes.sublist(16, 28);
    final ciphertext = bytes.sublist(28, bytes.length - 16);
    final mac = Mac(bytes.sublist(bytes.length - 16));
    final key = await _deriveKey(password, salt);

    final clearBytes = await AesGcm.with256bits().decrypt(
      SecretBox(ciphertext, nonce: nonce, mac: mac),
      secretKey: key,
    );
    return utf8.decode(clearBytes);
  }
}
