import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/services/ads_service.dart';
import 'features/home/home_screen.dart';
import 'features/tools/calculator/calculator_screen.dart';
import 'features/tools/notepad/notepad_screen.dart';
import 'features/tools/timer/timer_screen.dart';
import 'features/tools/qr/qr_screen.dart';
import 'features/tools/converter/converter_screen.dart';
import 'features/tools/files/files_screen.dart';
import 'features/tools/music/music_screen.dart';
import 'features/tools/wifi/wifi_screen.dart';
import 'features/tools/battery/battery_screen.dart';
import 'features/tools/pdf/pdf_screen.dart';
import 'features/tools/compass/compass_screen.dart';
import 'features/tools/flashlight/flashlight_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await AdsService.initialize();
  final prefs = await SharedPreferences.getInstance();
  final locale = prefs.getString('locale') ?? 'ar';
  runApp(ToolHubApp(initialLocale: locale));
}

class ToolHubApp extends StatefulWidget {
  final String initialLocale;
  const ToolHubApp({super.key, required this.initialLocale});

  static _ToolHubAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_ToolHubAppState>();

  @override
  State<ToolHubApp> createState() => _ToolHubAppState();
}

class _ToolHubAppState extends State<ToolHubApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = Locale(widget.initialLocale);
  }

  void setLocale(Locale locale) async {
    setState(() => _locale = locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToolHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ar')],
      initialRoute: '/',
      routes: {
        '/': (ctx) => const HomeScreen(),
        '/calculator': (ctx) => const CalculatorScreen(),
        '/notepad': (ctx) => const NotepadScreen(),
        '/timer': (ctx) => const TimerScreen(),
        '/qr': (ctx) => const QrScreen(),
        '/converter': (ctx) => const ConverterScreen(),
        '/files': (ctx) => const FilesScreen(),
        '/music': (ctx) => const MusicScreen(),
        '/wifi': (ctx) => const WifiScreen(),
        '/battery': (ctx) => const BatteryScreen(),
        '/pdf': (ctx) => const PdfScreen(),
        '/compass': (ctx) => const CompassScreen(),
        '/flashlight': (ctx) => const FlashlightScreen(),
      },
    );
  }
}
