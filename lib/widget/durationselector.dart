import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:softel_control/core/constant/app_theme.dart';

class DurationSelector extends StatefulWidget {
  final int? initialMonths;
  final Function(int months) onChanged;

  const DurationSelector({
    super.key,
    this.initialMonths,
    required this.onChanged,
  });

  @override
  State<DurationSelector> createState() => _DurationSelectorState();
}

class _DurationSelectorState extends State<DurationSelector> {
  final List<int> options = [3, 6, 12, 24, 60];

  RxString customLabel = "".obs;

  late int selected;
  TextEditingController customController = TextEditingController();
  @override
  void initState() {
    super.initState();
    selected = widget.initialMonths ?? 3;
  }

  String label(int months) {
    var years = months / 12;
    if (years == 1) {
      return "1 Year";
    } else if (years < 1) {
      return "$months Months";
    } else {
      String expersion = years % 1 == 0
          ? years.toInt().toString()
          : years.toStringAsFixed(1);
      return "$expersion Years";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children:
          options.map((months) {
            final isSelected = months == selected;
            return ChoiceChip(
              selectedColor: AppTheme.primaryBlue,
              label: Text(label(months)),
              selected: isSelected,
              onSelected: (_) {
                customController.clear();
                setState(() => selected = months);
                widget.onChanged(months);
              },
            );
          }).toList()..add(
            ChoiceChip(
              label: Text(
                customController.text.isEmpty
                    ? "Custom"
                    : "${label(int.parse(customController.text))} ",
              ),
              selectedColor: AppTheme.primaryBlue,
              selected: customController.text.isNotEmpty,
              onSelected: (_) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Custom Duration"),
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        spacing: 20,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: customController,
                              onChanged: (value) {
                                customLabel.value = label(
                                  int.parse(value.isEmpty ? "0" : value),
                                );
                              },
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(labelText: "Months"),
                            ),
                          ),
                          Expanded(
                            child: Obx(() {
                              return Text(
                                customLabel.value,
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(
                              () => selected = int.parse(customController.text),
                            );
                            widget.onChanged(int.parse(customController.text));
                            Navigator.pop(context);
                          },
                          child: Text("OK"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
    );
  }
}
