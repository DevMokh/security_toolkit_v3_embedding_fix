class SteganographyService {
  static const String _zero = '\u200B';
  static const String _one = '\u200C';

  static String hide({
    required String carrier,
    required String secret,
  }) {
    if (secret.isEmpty) {
      throw const FormatException('اكتب النص الذي تريد إخفاءه أولاً.');
    }

    final bits = secret.codeUnits
        .map((unit) => unit.toRadixString(2).padLeft(16, '0'))
        .join();

    final hidden = bits
        .split('')
        .map((bit) => bit == '0' ? _zero : _one)
        .join();

    return '$carrier$hidden';
  }

  static String extract(String encodedText) {
    final bits = encodedText
        .split('')
        .where((character) => character == _zero || character == _one)
        .map((character) => character == _zero ? '0' : '1')
        .join();

    if (bits.isEmpty) {
      throw const FormatException('لم يتم العثور على بيانات مخفية.');
    }
    if (bits.length % 16 != 0) {
      throw const FormatException('البيانات المخفية غير مكتملة أو تم تعديلها.');
    }

    final codeUnits = <int>[];
    for (var index = 0; index < bits.length; index += 16) {
      codeUnits.add(
        int.parse(bits.substring(index, index + 16), radix: 2),
      );
    }
    return String.fromCharCodes(codeUnits);
  }
}
