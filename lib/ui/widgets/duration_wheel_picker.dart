import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../domain/models/user_profile.dart';
import '../theme/app_theme.dart';

class _WheelScrollBehavior extends MaterialScrollBehavior {
  const _WheelScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

/// Opens a 2-part scroller wheel dialog (numbers on the left, units on the right).
Future<EscalationWindow?> showDurationWheelPicker(
  BuildContext context, {
  required String title,
  required EscalationWindow initial,
}) {
  return showDialog<EscalationWindow>(
    context: context,
    builder: (_) => _DurationWheelDialog(title: title, initial: initial),
  );
}

class _DurationWheelDialog extends StatefulWidget {
  final String title;
  final EscalationWindow initial;

  const _DurationWheelDialog({required this.title, required this.initial});

  @override
  State<_DurationWheelDialog> createState() => _DurationWheelDialogState();
}

class _DurationWheelDialogState extends State<_DurationWheelDialog> {
  static const _units = EscalationWindow.validUnits;
  static const double _itemExtent = 40;

  late int _value;
  late String _unit;
  late FixedExtentScrollController _valueCtrl;
  late FixedExtentScrollController _unitCtrl;

  int _maxForUnit(String unit) {
    switch (unit) {
      case 'minutes':
        return 60;
      case 'hours':
        return 48;
      case 'days':
        return 31;
      case 'weeks':
      case 'months':
      default:
        return 12;
    }
  }

  @override
  void initState() {
    super.initState();
    _unit = _units.contains(widget.initial.unit) ? widget.initial.unit : 'days';
    _value = widget.initial.value.clamp(1, _maxForUnit(_unit));
    _valueCtrl = FixedExtentScrollController(initialItem: _value - 1);
    _unitCtrl = FixedExtentScrollController(initialItem: _units.indexOf(_unit));
  }

  @override
  void dispose() {
    _valueCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  void _onUnitChanged(int index) {
    final nextUnit = _units[index];
    final nextMax = _maxForUnit(nextUnit);
    final clampedVal = _value.clamp(1, nextMax);
    setState(() {
      _unit = nextUnit;
      _value = clampedVal;
    });
    if (_valueCtrl.hasClients && _valueCtrl.selectedItem != clampedVal - 1) {
      _valueCtrl.jumpToItem(clampedVal - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxVal = _maxForUnit(_unit);

    return AlertDialog(
      title: Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      content: SizedBox(
        width: 280,
        height: 200,
        child: ScrollConfiguration(
          behavior: const _WheelScrollBehavior(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Center selection highlight band
              IgnorePointer(
                child: Container(
                  height: _itemExtent,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.45)),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      controller: _valueCtrl,
                      itemExtent: _itemExtent,
                      physics: const FixedExtentScrollPhysics(),
                      perspective: 0.003,
                      diameterRatio: 1.5,
                      onSelectedItemChanged: (idx) {
                        setState(() => _value = idx + 1);
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: maxVal,
                        builder: (context, idx) {
                          final numVal = idx + 1;
                          final isSelected = numVal == _value;
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _valueCtrl.animateToItem(
                              idx,
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOut,
                            ),
                            child: Center(
                              child: Text(
                                '$numVal',
                                style: AppTheme.mono(
                                  isSelected ? 18 : 14,
                                  color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
                                  weight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: ListWheelScrollView.useDelegate(
                      controller: _unitCtrl,
                      itemExtent: _itemExtent,
                      physics: const FixedExtentScrollPhysics(),
                      perspective: 0.003,
                      diameterRatio: 1.5,
                      onSelectedItemChanged: _onUnitChanged,
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: _units.length,
                        builder: (context, idx) {
                          final unit = _units[idx];
                          final isSelected = unit == _unit;
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _unitCtrl.animateToItem(
                              idx,
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOut,
                            ),
                            child: Center(
                              child: Text(
                                unit,
                                style: TextStyle(
                                  fontSize: isSelected ? 16 : 13,
                                  color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(EscalationWindow(value: _value, unit: _unit)),
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
