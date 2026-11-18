import 'package:flutter_test/flutter_test.dart';
import 'package:security_toolkit/services/crypto_service.dart';
import 'package:security_toolkit/services/steganography_service.dart';

void main() {
  group('SteganographyService', () {
    test('hides and extracts text', () {
      const secret = 'Hello مرحباً';
      final encoded = SteganographyService.hide(
        carrier: 'ordinary message ',
        secret: secret,
      );
      expect(SteganographyService.extract(encoded), secret);
    });

    test('rejects text without hidden data', () {
      expect(
        () => SteganographyService.extract('ordinary message'),
        throwsFormatException,
      );
    });
  });

  group('CryptoService', () {
    test('encrypts and decrypts a message', () async {
      const plaintext = 'Security Toolkit test';
      const password = 'Correct-Horse-Battery-57!';
      final encrypted = await CryptoService.encryptText(
        plaintext: plaintext,
        password: password,
      );
      expect(
        await CryptoService.decryptText(
          encoded: encrypted,
          password: password,
        ),
        plaintext,
      );
    });

    test('rejects a wrong password', () async {
      final encrypted = await CryptoService.encryptText(
        plaintext: 'test',
        password: 'Correct-Horse-Battery-57!',
      );
      await expectLater(
        CryptoService.decryptText(
          encoded: encrypted,
          password: 'Not-The-Correct-Password',
        ),
        throwsA(anything),
      );
    });
  });
}
