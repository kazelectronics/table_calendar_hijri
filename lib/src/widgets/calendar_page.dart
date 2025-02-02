// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/widgets.dart';
import '../hijri_and_gregorian.dart';

class CalendarPage extends StatelessWidget {
  final Widget Function(BuildContext context, HijriAndGregorianDate day)? dowBuilder;
  final Widget Function(BuildContext context, HijriAndGregorianDate day) dayBuilder;
  final List<HijriAndGregorianDate> visibleDays;
  final Decoration? dowDecoration;
  final Decoration? rowDecoration;
  final TableBorder? tableBorder;
  final bool dowVisible;
  final bool showHijriDate;
  final bool showGregorianDate;
  final bool hijriHasPreference;
  final int adjustHijriDateByDays;

  const CalendarPage({
    Key? key,
    required this.visibleDays,
    this.dowBuilder,
    required this.dayBuilder,
    this.dowDecoration,
    this.rowDecoration,
    this.tableBorder,
    this.dowVisible = true,
    required this.showHijriDate,
    required this.showGregorianDate,
    required this.adjustHijriDateByDays,
    required this.hijriHasPreference,
  })  : assert(!dowVisible || dowBuilder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Table(
      border: tableBorder,
      children: [
        if (dowVisible) _buildDaysOfWeek(context),
        ..._buildCalendarDays(context),
      ],
    );
  }

  TableRow _buildDaysOfWeek(BuildContext context) {
    return TableRow(
      decoration: dowDecoration,
      children: List.generate(
        7,
        (index) => dowBuilder!(context, visibleDays[index]),
      ).toList(),
    );
  }

  List<TableRow> _buildCalendarDays(BuildContext context) {
    final rowAmount = visibleDays.length ~/ 7;

    return List.generate(rowAmount, (index) => index * 7)
        .map((index) => TableRow(
              decoration: rowDecoration,
              children: List.generate(
                7,
                (id) => dayBuilder(context, visibleDays[index + id]),
              ),
            ))
        .toList();
  }
}
