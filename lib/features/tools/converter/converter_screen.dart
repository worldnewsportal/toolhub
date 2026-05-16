import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});
  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  int _catIndex = 0;
  String _fromUnit = '', _toUnit = '';
  final _ctrl = TextEditingController();
  String _result = '';

  final Map<String, Map<String, double>> _categories = {
    'Length': {'m': 1, 'km': 1000, 'cm': 0.01, 'mm': 0.001, 'mi': 1609.34, 'ft': 0.3048, 'in': 0.0254, 'yd': 0.9144},
    'Weight': {'kg': 1, 'g': 0.001, 'mg': 0.000001, 'lb': 0.453592, 'oz': 0.0283495, 't': 1000},
    'Temperature': {'°C': 1, '°F': 1, 'K': 1},
    'Area': {'m²': 1, 'km²': 1e6, 'cm²': 0.0001, 'ft²': 0.0929, 'acre': 4046.86, 'ha': 10000},
    'Volume': {'L': 1, 'mL': 0.001, 'm³': 1000, 'ft³': 28.3168, 'gal': 3.78541, 'cup': 0.236588},
    'Speed': {'m/s': 1, 'km/h': 0.277778, 'mph': 0.44704, 'knot': 0.514444},
    'Data': {'B': 1, 'KB': 1024, 'MB': 1048576, 'GB': 1073741824, 'TB': 1.0995e12},
    'Time': {'s': 1, 'min': 60, 'h': 3600, 'day': 86400, 'week': 604800, 'month': 2629800, 'year': 31557600},
  };

  String get _currentCat => _categories.keys.toList()[_catIndex];
  List<String> get _units => _categories[_currentCat]!.keys.toList();

  @override
  void initState() {
    super.initState();
    _fromUnit = _units.first;
    _toUnit = _units.length > 1 ? _units[1] : _units.first;
  }

  void _convert() {
    final val = double.tryParse(_ctrl.text);
    if (val == null) { setState(() => _result = ''); return; }
    double result;
    if (_currentCat == 'Temperature') {
      result = _convertTemp(val, _fromUnit, _toUnit);
    } else {
      final base = val * _categories[_currentCat]![_fromUnit]!;
      result = base / _categories[_currentCat]![_toUnit]!;
    }
    setState(() => _result = result % 1 == 0 ? result.toStringAsFixed(0) : result.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), ''));
  }

  double _convertTemp(double val, String from, String to) {
    double celsius;
    if (from == '°C') celsius = val;
    else if (from == '°F') celsius = (val - 32) * 5 / 9;
    else celsius = val - 273.15;
    if (to == '°C') return celsius;
    if (to == '°F') return celsius * 9 / 5 + 32;
    return celsius + 273.15;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.unitConverter)),
      body: Column(children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: _categories.keys.toList().asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(e.value),
                selected: _catIndex == e.key,
                onSelected: (_) {
                  setState(() {
                    _catIndex = e.key;
                    _fromUnit = _units.first;
                    _toUnit = _units.length > 1 ? _units[1] : _units.first;
                    _result = '';
                    _ctrl.clear();
                  });
                },
              ),
            )).toList(),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              Row(children: [
                Expanded(child: DropdownButtonFormField<String>(
                  value: _fromUnit,
                  decoration: InputDecoration(labelText: l10n.from, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                  onChanged: (v) { if (v != null) setState(() { _fromUnit = v; _convert(); }); },
                )),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: IconButton(
                    icon: const Icon(Icons.swap_horiz, size: 32),
                    onPressed: () => setState(() { final tmp = _fromUnit; _fromUnit = _toUnit; _toUnit = tmp; _convert(); }),
                  ),
                ),
                Expanded(child: DropdownButtonFormField<String>(
                  value: _toUnit,
                  decoration: InputDecoration(labelText: l10n.to, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                  onChanged: (v) { if (v != null) setState(() { _toUnit = v; _convert(); }); },
                )),
              ]),
              const SizedBox(height: 24),
              TextField(
                controller: _ctrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.value,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (_) => _convert(),
              ),
              const SizedBox(height: 24),
              if (_result.isNotEmpty) Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(children: [
                    Text(l10n.result, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 8),
                    Text('$_result $_toUnit', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
