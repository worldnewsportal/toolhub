import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});
  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  double _heading = 0;
  bool _hasPermission = false;

  @override
  void initState() { super.initState(); _checkPermission(); }

  Future<void> _checkPermission() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      setState(() => _hasPermission = true);
      FlutterCompass.events?.listen((e) {
        if (e.heading != null) setState(() => _heading = e.heading!);
      });
    }
  }

  String _direction(double h) {
    if (h >= 337.5 || h < 22.5) return 'N';
    if (h < 67.5) return 'NE';
    if (h < 112.5) return 'E';
    if (h < 157.5) return 'SE';
    if (h < 202.5) return 'S';
    if (h < 247.5) return 'SW';
    if (h < 292.5) return 'W';
    return 'NW';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.compass)),
      body: !_hasPermission
          ? Center(child: ElevatedButton(onPressed: _checkPermission, child: Text(l10n.grantPermission)))
          : Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('${_heading.toStringAsFixed(1)}°', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
              Text(_direction(_heading), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              Transform.rotate(
                angle: -_heading * pi / 180,
                child: SizedBox(
                  width: 280,
                  height: 280,
                  child: CustomPaint(painter: _CompassPainter(context: context)),
                ),
              ),
            ])),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final BuildContext context;
  _CompassPainter({required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = Theme.of(context).colorScheme.surfaceVariant
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paint);

    paint.color = Theme.of(context).colorScheme.outline;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    canvas.drawCircle(center, radius - 2, paint);

    // Ticks
    for (int i = 0; i < 360; i += 10) {
      final angle = i * pi / 180;
      final len = i % 30 == 0 ? 20.0 : 10.0;
      final p1 = Offset(center.dx + (radius - 10) * sin(angle), center.dy - (radius - 10) * cos(angle));
      final p2 = Offset(center.dx + (radius - 10 - len) * sin(angle), center.dy - (radius - 10 - len) * cos(angle));
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = i % 30 == 0 ? 2 : 1;
      paint.color = Theme.of(context).colorScheme.onSurface;
      canvas.drawLine(p1, p2, paint);
    }

    // Directions
    final dirs = {'N': 0.0, 'E': 90.0, 'S': 180.0, 'W': 270.0};
    for (final entry in dirs.entries) {
      final angle = entry.value * pi / 180;
      final tp = TextPainter(
        text: TextSpan(text: entry.key, style: TextStyle(color: entry.key == 'N' ? Colors.red : Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      final pos = Offset(center.dx + (radius - 40) * sin(angle) - tp.width / 2, center.dy - (radius - 40) * cos(angle) - tp.height / 2);
      tp.paint(canvas, pos);
    }

    // Needle
    final needlePaint = Paint()..style = PaintingStyle.fill;
    needlePaint.color = Colors.red;
    final northPath = Path()
      ..moveTo(center.dx, center.dy - radius + 60)
      ..lineTo(center.dx - 10, center.dy)
      ..lineTo(center.dx + 10, center.dy)
      ..close();
    canvas.drawPath(northPath, needlePaint);
    needlePaint.color = Colors.grey;
    final southPath = Path()
      ..moveTo(center.dx, center.dy + radius - 60)
      ..lineTo(center.dx - 10, center.dy)
      ..lineTo(center.dx + 10, center.dy)
      ..close();
    canvas.drawPath(southPath, needlePaint);
    canvas.drawCircle(center, 8, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
