import 'package:flutter/material.dart';

import 'screens/browser_screen.dart';
import 'screens/cve_screen.dart';
import 'screens/encryption_screen.dart';
import 'screens/image_screen.dart';
import 'screens/link_scanner_screen.dart';
import 'screens/phishing_screen.dart';
import 'screens/steganography_screen.dart';

class SecurityToolkitApp extends StatelessWidget {
  const SecurityToolkitApp({super.key});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF42E8B4);
    return MaterialApp(
      title: 'Security Toolkit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080D12),
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.dark,
          surface: const Color(0xFF111A23),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF080D12),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF111A23),
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFF24313D)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF101820),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF2A3946)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF2A3946)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: accent, width: 1.4),
          ),
        ),
      ),
      home: const ToolkitHome(),
    );
  }
}

class ToolkitHome extends StatefulWidget {
  const ToolkitHome({super.key});

  @override
  State<ToolkitHome> createState() => _ToolkitHomeState();
}

class _ToolkitHomeState extends State<ToolkitHome> {
  int _selectedIndex = 0;

  static const _destinations = <_Destination>[
    _Destination('إخفاء النص', Icons.text_fields),
    _Destination('التشفير', Icons.lock_outline),
    _Destination('ثغرات CVE', Icons.bug_report_outlined),
    _Destination('توعية الصور', Icons.image_outlined),
    _Destination('محاكاة التصيد', Icons.mail_outline),
    _Destination('فحص الروابط', Icons.link),
    _Destination('السيرفر والمتصفح', Icons.public),
  ];

  static const _pages = <Widget>[
    SteganographyScreen(),
    EncryptionScreen(),
    CveScreen(),
    ImageAwarenessScreen(),
    PhishingAwarenessScreen(),
    LinkScannerScreen(),
    BrowserScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.shield_moon_outlined, color: Color(0xFF42E8B4)),
            SizedBox(width: 10),
            Text(
              'SECURITY TOOLKIT',
              style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.1),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      color: Color(0xFF42E8B4),
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'مختبر التوعية الأمنية',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'اختبر على بياناتك أو أنظمة لديك تصريح باختبارها فقط.',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 76,
          decoration: const BoxDecoration(
            color: Color(0xFF0D141C),
            border: Border(top: BorderSide(color: Color(0xFF24313D))),
          ),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            scrollDirection: Axis.horizontal,
            itemCount: _destinations.length,
            separatorBuilder: (_, __) => const SizedBox(width: 5),
            itemBuilder: (context, index) {
              final selected = index == _selectedIndex;
              final item = _destinations[index];
              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => setState(() => _selectedIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 86,
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF17352F)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF42E8B4)
                          : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        size: 21,
                        color: selected
                            ? const Color(0xFF42E8B4)
                            : Colors.grey.shade400,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: selected ? Colors.white : Colors.grey.shade400,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Destination {
  final String label;
  final IconData icon;

  const _Destination(this.label, this.icon);
}
