class UrlAnalysisResult {
  final String host;
  final String scheme;
  final int riskScore;
  final List<String> findings;

  const UrlAnalysisResult({
    required this.host,
    required this.scheme,
    required this.riskScore,
    required this.findings,
  });
}

class UrlAnalysisService {
  static const _shorteners = <String>{
    'bit.ly',
    't.co',
    'tinyurl.com',
    'is.gd',
    'cutt.ly',
    'rb.gy',
    'shorturl.at',
  };

  static UrlAnalysisResult analyze(String input) {
    final uri = Uri.tryParse(input.trim());
    if (uri == null || uri.host.isEmpty) {
      throw const FormatException('صيغة الرابط غير صالحة.');
    }
    if (!{'http', 'https'}.contains(uri.scheme.toLowerCase())) {
      throw const FormatException('يسمح بتحليل روابط HTTP وHTTPS فقط.');
    }

    final host = uri.host.toLowerCase();
    final findings = <String>[];
    var score = 0;

    if (uri.userInfo.isNotEmpty) {
      findings.add('يحتوي الرابط على بيانات مستخدم قبل اسم النطاق.');
      score += 25;
    }
    if (host.split('.').any((part) => part.startsWith('xn--'))) {
      findings.add('يستخدم Punycode؛ تحقق من الأحرف المتشابهة بصرياً.');
      score += 20;
    }
    if (RegExp(r'^(?:\d{1,3}\.){3}\d{1,3}$').hasMatch(host)) {
      findings.add('يستخدم عنوان IP مباشرة بدلاً من اسم نطاق.');
      score += 15;
    }
    if (_shorteners.contains(host)) {
      findings.add('نطاق مختصر يخفي عنوان الوجهة النهائي.');
      score += 15;
    }
    if (uri.scheme.toLowerCase() == 'http') {
      findings.add('الاتصال يستخدم HTTP دون تشفير النقل.');
      score += 10;
    }
    if (uri.hasPort && !{80, 443}.contains(uri.port)) {
      findings.add('يستخدم منفذاً غير شائع.');
      score += 10;
    }
    if (host.split('.').length >= 5) {
      findings.add('عدد مستويات النطاق الفرعية مرتفع.');
      score += 10;
    }
    final riskyWords = RegExp(
      r'(login|verify|secure|account|update|wallet|password|bank)',
      caseSensitive: false,
    );
    if (riskyWords.hasMatch('${uri.path}?${uri.query}')) {
      findings.add('المسار يحتوي كلمات شائعة في صفحات تسجيل الدخول والتحقق.');
      score += 10;
    }
    if (uri.toString().length > 180) {
      findings.add('الرابط طويل بشكل غير معتاد.');
      score += 5;
    }

    return UrlAnalysisResult(
      host: host,
      scheme: uri.scheme,
      riskScore: score.clamp(0, 100).toInt(),
      findings: findings,
    );
  }
}
