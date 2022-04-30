// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../shared/utils.dart';
import 'calendar_page.dart';
import 'package:hijri/hijri_calendar.dart';

typedef _OnCalendarPageChanged = void Function(
    int pageIndex, HijriAndGregorianDate focusedDay);

class CalendarCore extends StatelessWidget {
  final HijriAndGregorianDate? focusedDay;
  final HijriAndGregorianDate firstDay;
  final HijriAndGregorianDate lastDay;
  final CalendarFormat calendarFormat;
  final DayBuilder? dowBuilder;
  final FocusedDayBuilder dayBuilder;
  final bool sixWeekMonthsEnforced;
  final bool dowVisible;
  final Decoration? dowDecoration;
  final Decoration? rowDecoration;
  final TableBorder? tableBorder;
  final double? dowHeight;
  final double? rowHeight;
  final BoxConstraints constraints;
  final int? previousIndex;
  final StartingDayOfWeek startingDayOfWeek;
  final PageController? pageController;
  final ScrollPhysics? scrollPhysics;
  final _OnCalendarPageChanged onPageChanged;
  final bool showHijriDate;
  final bool showGregorianDate;
  final bool hijriHasPreference;
  final int adjustHijriDateByDays;

  const CalendarCore({
    Key? key,
    this.dowBuilder,
    required this.dayBuilder,
    required this.onPageChanged,
    required this.firstDay,
    required this.lastDay,
    required this.constraints,
    this.dowHeight,
    this.rowHeight,
    this.startingDayOfWeek = StartingDayOfWeek.sunday,
    this.calendarFormat = CalendarFormat.month,
    this.pageController,
    this.focusedDay,
    this.previousIndex,
    this.sixWeekMonthsEnforced = false,
    this.dowVisible = true,
    this.dowDecoration,
    this.rowDecoration,
    this.tableBorder,
    this.scrollPhysics,
    required this.showHijriDate,
    required this.showGregorianDate,
    required this.adjustHijriDateByDays,
    required this.hijriHasPreference,
  })  : assert(!dowVisible || (dowHeight != null && dowBuilder != null)),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      physics: scrollPhysics,
      itemCount: _getPageCount(calendarFormat, firstDay, lastDay),
      itemBuilder: (context, index) {
        final baseDay = _getBaseDay(calendarFormat, index);
        final visibleRange = _getVisibleRange(calendarFormat, baseDay);
        final visibleDays = _daysInRange(visibleRange.start, visibleRange.end);

        final actualDowHeight = dowVisible ? dowHeight! : 0.0;
        final constrainedRowHeight = constraints.hasBoundedHeight
            ? (constraints.maxHeight - actualDowHeight) /
                _getRowCount(calendarFormat, baseDay)
            : null;

        return CalendarPage(
          visibleDays: visibleDays,
          dowVisible: dowVisible,
          dowDecoration: dowDecoration,
          rowDecoration: rowDecoration,
          tableBorder: tableBorder,
          showHijriDate: showHijriDate,
          showGregorianDate: showGregorianDate,
          adjustHijriDateByDays: adjustHijriDateByDays,
          hijriHasPreference: hijriHasPreference,
          dowBuilder: (context, day) {
            return SizedBox(
              height: dowHeight,
              child: dowBuilder?.call(context, day),
            );
          },
          dayBuilder: (context, day) {
            HijriAndGregorianDate baseDay;
            final previousFocusedDay = focusedDay;
            if (previousFocusedDay == null || previousIndex == null) {
              baseDay = _getBaseDay(calendarFormat, index);
            } else {
              baseDay =
                  _getFocusedDay(calendarFormat, previousFocusedDay, index);
            }

            return SizedBox(
              height: constrainedRowHeight ?? rowHeight,
              child: dayBuilder(context, day, baseDay),
            );
          },
        );
      },
      onPageChanged: (index) {
        HijriAndGregorianDate baseDay;
        final previousFocusedDay = focusedDay;
        if (previousFocusedDay == null || previousIndex == null) {
          baseDay = _getBaseDay(calendarFormat, index);
        } else {
          baseDay = _getFocusedDay(calendarFormat, previousFocusedDay, index);
        }

        return onPageChanged(index, baseDay);
      },
    );
  }

  int _getPageCount(CalendarFormat format, HijriAndGregorianDate first, HijriAndGregorianDate last) {
    switch (format) {
      case CalendarFormat.month:
        return _getMonthCount(first, last) + 1;
      case CalendarFormat.twoWeeks:
        return _getTwoWeekCount(first, last) + 1;
      case CalendarFormat.week:
        return _getWeekCount(first, last) + 1;
      default:
        return _getMonthCount(first, last) + 1;
    }
  }

  int _getMonthCount(HijriAndGregorianDate first, HijriAndGregorianDate last) {
    return first.getMonthCount(last, hijriHasPreference);
  }

  int _getWeekCount(HijriAndGregorianDate first, HijriAndGregorianDate last) {

    return last.differenceInDays(_firstDayOfWeek(first),hijriHasPreference) ~/ 7;
  }

  int _getTwoWeekCount(HijriAndGregorianDate first, HijriAndGregorianDate last) {
    return last.differenceInDays(_firstDayOfWeek(first),hijriHasPreference) ~/ 14;
  }

  HijriAndGregorianDate _getFocusedDay(
      CalendarFormat format, HijriAndGregorianDate prevFocusedDay, int pageIndex) {
    if (pageIndex == previousIndex) {
      return prevFocusedDay;
    }

    final pageDif = pageIndex - previousIndex!;
    HijriAndGregorianDate day;

    switch (format) {
      case CalendarFormat.month:
        day = prevFocusedDay.getDateAnOffsetAway(0,pageDif,0,hijriHasPreference);
        break;
      case CalendarFormat.twoWeeks:
        day = prevFocusedDay.getDateAnOffsetAway(0,0,pageDif * 14,hijriHasPreference);
        break;
      case CalendarFormat.week:
        day = prevFocusedDay.getDateAnOffsetAway(0,0,pageDif * 7,hijriHasPreference);
        break;
    }

    if (day.isBefore(firstDay, hijriHasPreference)) {
      day = firstDay;
    } else if (day.isAfter(lastDay, hijriHasPreference)) {
      day = lastDay;
    }

    return day;
  }

  HijriAndGregorianDate _getBaseDay(CalendarFormat format, int pageIndex) {
    HijriAndGregorianDate day;

    switch (format) {
      case CalendarFormat.month:
        day = firstDay.getDateAnOffsetAway(0,pageIndex,0,hijriHasPreference);
        break;
      case CalendarFormat.twoWeeks:
        day = firstDay.getDateAnOffsetAway(0,0,pageIndex * 14,hijriHasPreference);
        break;
      case CalendarFormat.week:
        day = firstDay.getDateAnOffsetAway(0,0,pageIndex * 7,hijriHasPreference);
        break;
    }

    if (day.isBefore(firstDay, hijriHasPreference)) {
      day = firstDay;
    } else if (day.isAfter(lastDay, hijriHasPreference)) {
      day = lastDay;
    }

    return day;
  }

  HijriAndGregorianDateRange _getVisibleRange(CalendarFormat format, HijriAndGregorianDate focusedDay) {
    switch (format) {
      case CalendarFormat.month:
        return _daysInMonth(focusedDay);
      case CalendarFormat.twoWeeks:
        return _daysInTwoWeeks(focusedDay);
      case CalendarFormat.week:
        return _daysInWeek(focusedDay);
      default:
        return _daysInMonth(focusedDay);
    }
  }

  HijriAndGregorianDateRange _daysInWeek(HijriAndGregorianDate focusedDay) {
    final daysBefore = _getDaysBefore(focusedDay);
    final firstToDisplay = focusedDay.subtract(Duration(days: daysBefore), hijriHasPreference);
    final lastToDisplay = firstToDisplay.add(const Duration(days: 7),hijriHasPreference);
    return HijriAndGregorianDateRange(start: firstToDisplay, end: lastToDisplay);
  }

  HijriAndGregorianDateRange _daysInTwoWeeks(HijriAndGregorianDate focusedDay) {
    final daysBefore = _getDaysBefore(focusedDay);
    final firstToDisplay = focusedDay.subtract(Duration(days: daysBefore),hijriHasPreference);
    final lastToDisplay = firstToDisplay.add(const Duration(days: 14),hijriHasPreference);
    return HijriAndGregorianDateRange(start: firstToDisplay, end: lastToDisplay);
  }

  HijriAndGregorianDateRange _daysInMonth(HijriAndGregorianDate focusedDay) {
    final first = _firstDayOfMonth(focusedDay);
    final daysBefore = _getDaysBefore(first);
    final firstToDisplay = first.subtract(Duration(days: daysBefore),hijriHasPreference);

    if (sixWeekMonthsEnforced) {
      final end = firstToDisplay.add(const Duration(days: 42),hijriHasPreference);
      return HijriAndGregorianDateRange(start: firstToDisplay, end: end);
    }

    final last = _lastDayOfMonth(focusedDay);
    final daysAfter = _getDaysAfter(last);
    final lastToDisplay = last.add(Duration(days: daysAfter),hijriHasPreference);

    return HijriAndGregorianDateRange(start: firstToDisplay, end: lastToDisplay);
  }

  List<HijriAndGregorianDate> _daysInRange(HijriAndGregorianDate first, HijriAndGregorianDate last) {
    final dayCount = last.differenceInDays(first, hijriHasPreference) + 1;
    return List.generate(
      dayCount,
      (index) => first.getDateAnOffsetAway(0,0,index,hijriHasPreference),
    );
  }

  HijriAndGregorianDate _firstDayOfWeek(HijriAndGregorianDate week) {
    final daysBefore = _getDaysBefore(week);
    return week.subtract(Duration(days: daysBefore),hijriHasPreference);
  }

  HijriAndGregorianDate _firstDayOfMonth(HijriAndGregorianDate month) {
    return month.firstDayOfMonth(hijriHasPreference);
  }

  HijriAndGregorianDate _lastDayOfMonth(HijriAndGregorianDate month) {
    return month.lastDayOfMonth(hijriHasPreference);
  }

  int _getRowCount(CalendarFormat format, HijriAndGregorianDate focusedDay) {
    if (format == CalendarFormat.twoWeeks) {
      return 2;
    } else if (format == CalendarFormat.week) {
      return 1;
    } else if (sixWeekMonthsEnforced) {
      return 6;
    }

    final first = _firstDayOfMonth(focusedDay);
    final daysBefore = _getDaysBefore(first);
    final firstToDisplay = first.subtract(Duration(days: daysBefore),hijriHasPreference);

    final last = _lastDayOfMonth(focusedDay);
    final daysAfter = _getDaysAfter(last);
    final lastToDisplay = last.add(Duration(days: daysAfter),hijriHasPreference);

    return (lastToDisplay.differenceInDays(firstToDisplay,hijriHasPreference) + 1) ~/ 7;
  }

  int _getDaysBefore(HijriAndGregorianDate firstDay) {
    return (firstDay.weekday() + 7 - getWeekdayNumber(startingDayOfWeek)) % 7;
  }

  int _getDaysAfter(HijriAndGregorianDate lastDay) {
    int invertedStartingWeekday = 8 - getWeekdayNumber(startingDayOfWeek);

    int daysAfter = 7 - ((lastDay.weekday() + invertedStartingWeekday) % 7);
    if (daysAfter == 7) {
      daysAfter = 0;
    }

    return daysAfter;
  }
}
