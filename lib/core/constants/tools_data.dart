import 'package:flutter/material.dart';

class ToolModel {
  final String id;
  final String nameEn;
  final String nameAr;
  final IconData icon;
  final Color color;
  final String route;

  const ToolModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.icon,
    required this.color,
    required this.route,
  });
}

const List<ToolModel> allTools = [
  ToolModel(
    id: 'calculator',
    nameEn: 'Calculator',
    nameAr: 'الحاسبة',
    icon: Icons.calculate_rounded,
    color: Color(0xFF6C63FF),
    route: '/calculator',
  ),
  ToolModel(
    id: 'notepad',
    nameEn: 'Notepad',
    nameAr: 'المفكرة',
    icon: Icons.note_rounded,
    color: Color(0xFFFF6584),
    route: '/notepad',
  ),
  ToolModel(
    id: 'timer',
    nameEn: 'Timer',
    nameAr: 'المؤقت',
    icon: Icons.timer_rounded,
    color: Color(0xFF03DAC6),
    route: '/timer',
  ),
  ToolModel(
    id: 'qr',
    nameEn: 'QR Scanner',
    nameAr: 'قارئ QR',
    icon: Icons.qr_code_scanner_rounded,
    color: Color(0xFFFF9800),
    route: '/qr',
  ),
  ToolModel(
    id: 'converter',
    nameEn: 'Unit Converter',
    nameAr: 'محول الوحدات',
    icon: Icons.swap_horiz_rounded,
    color: Color(0xFF4CAF50),
    route: '/converter',
  ),
  ToolModel(
    id: 'files',
    nameEn: 'File Manager',
    nameAr: 'مدير الملفات',
    icon: Icons.folder_rounded,
    color: Color(0xFF2196F3),
    route: '/files',
  ),
  ToolModel(
    id: 'music',
    nameEn: 'Music Player',
    nameAr: 'مشغل الموسيقى',
    icon: Icons.music_note_rounded,
    color: Color(0xFFE91E63),
    route: '/music',
  ),
  ToolModel(
    id: 'wifi',
    nameEn: 'WiFi Analyzer',
    nameAr: 'كاشف الواي فاي',
    icon: Icons.wifi_rounded,
    color: Color(0xFF009688),
    route: '/wifi',
  ),
  ToolModel(
    id: 'battery',
    nameEn: 'Battery Info',
    nameAr: 'معلومات البطارية',
    icon: Icons.battery_charging_full_rounded,
    color: Color(0xFFFF5722),
    route: '/battery',
  ),
  ToolModel(
    id: 'pdf',
    nameEn: 'Image to PDF',
    nameAr: 'صور إلى PDF',
    icon: Icons.picture_as_pdf_rounded,
    color: Color(0xFF795548),
    route: '/pdf',
  ),
  ToolModel(
    id: 'compass',
    nameEn: 'Compass',
    nameAr: 'البوصلة',
    icon: Icons.explore_rounded,
    color: Color(0xFF607D8B),
    route: '/compass',
  ),
  ToolModel(
    id: 'flashlight',
    nameEn: 'Flashlight',
    nameAr: 'المصباح',
    icon: Icons.flashlight_on_rounded,
    color: Color(0xFFFFC107),
    route: '/flashlight',
  ),
];
