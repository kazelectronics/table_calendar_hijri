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
    final yearDif = last.gregorianDate.year - first.gregorianDate.year;
    final monthDif = last.gregorianDate.month - first.gregorianDate.month;

    return yearDif * 12 + monthDif;
  }

  int _getWeekCount(HijriAndGregorianDate first, HijriAndGregorianDate last) {
    return last.gregorianDate.difference(_firstDayOfWeek(first).gregorianDate).inDays ~/ 7;
  }

  int _getTwoWeekCount(HijriAndGregorianDate first, HijriAndGregorianDate last) {
    return last.gregorianDate.difference(_firstDayOfWeek(first).gregorianDate).inDays ~/ 14;
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
        day = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(prevFocusedDay.gregorianDate.year, prevFocusedDay.gregorianDate.month + pageDif),adjustHijriDateByDays);
        break;
      case CalendarFormat.twoWeeks:
        day = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(prevFocusedDay.gregorianDate.year, prevFocusedDay.gregorianDate.month,
            prevFocusedDay.gregorianDate.day + pageDif * 14),adjustHijriDateByDays);
        break;
      case CalendarFormat.week:
        day = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(prevFocusedDay.gregorianDate.year, prevFocusedDay.gregorianDate.month,
            prevFocusedDay.gregorianDate.day + pageDif * 7),adjustHijriDateByDays);
        break;
    }

    if (day.gregorianDate.isBefore(firstDay.gregorianDate)) {
      day = firstDay;
    } else if (day.gregorianDate.isAfter(lastDay.gregorianDate)) {
      day = lastDay;
    }

    return day;
  }

  HijriAndGregorianDate _getBaseDay(CalendarFormat format, int pageIndex) {
    HijriAndGregorianDate day;

    switch (format) {
      case CalendarFormat.month:
        day = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(firstDay.gregorianDate.year, firstDay.gregorianDate.month + pageIndex),adjustHijriDateByDays);
        break;
      case CalendarFormat.twoWeeks:
        day = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(
            firstDay.gregorianDate.year, firstDay.gregorianDate.month, firstDay.gregorianDate.day + pageIndex * 14),adjustHijriDateByDays);
        break;
      case CalendarFormat.week:
        day = HijriAndGregorianDate.fromGregorianDate(DateTime.utc(
            firstDay.gregorianDate.year, firstDay.gregorianDate.month, firstDay.gregorianDate.day + pageIndex * 7),adjustHijriDateByDays);
        break;
    }

    if (day.gregorianDate.isBefore(firstDay.gregorianDate)) {
      day = firstDay;
    } else if (day.gregorianDate.isAfter(lastDay.gregorianDate)) {
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
    final firstToDisplay = HijriAndGregorianDate.fromGregorianDate(focusedDay.gregorianDate.subtract(Duration(days: daysBefore)),adjustHijriDateByDays);
    final lastToDisplay = HijriAndGregorianDate.fromGregorianDate(firstToDisplay.gregorianDate.add(const Duration(days: 7)),adjustHijriDateByDays);
    return HijriAndGregorianDateRange(start: firstToDisplay, end: lastToDisplay);
  }

  HijriAndGregorianDateRange _daysInTwoWeeks(HijriAndGregorianDate focusedDay) {
    final daysBefore = _getDaysBefore(focusedDay);
    final firstToDisplay = HijriAndGregorianDate.fromGregorianDate(focusedDay.gregorianDate.subtract(Duration(days: daysBefore)),adjustHijriDateByDays);
    final lastToDisplay = HijriAndGregorianDate.fromGregorianDate(firstToDisplay.gregorianDate.add(const Duration(days: 14)),adjustHijriDateByDays);
    return HijriAndGregorianDateRange(start: firstToDisplay, end: lastToDisplay);
  }

  HijriAndGregorianDateRange _daysInMonth(HijriAndGregorianDate focusedDay) {
    final first = _firstDayOfMonth(focusedDay);
    final daysBefore = _getDaysBefore(first);
    final firstToDisplay = HijriAndGregorianDate.fromGregorianDate(first.gregorianDate.subtract(Duration(days: daysBefore)),adjustHijriDateByDays);

    if (sixWeekMonthsEnforced) {
      final end = HijriAndGregorianDate.fromGregorianDate(firstToDisplay.gregorianDate.add(const Duration(days: 42)),adjustHijriDateByDays);
      return HijriAndGregorianDateRange(start: firstToDisplay, end: end);
    }

    final last = _lastDayOfMonth(focusedDay);
    final daysAfter = _getDaysAfter(last);
    final lastToDisplay = HijriAndGregorianDate.fromGregorianDate(last.gregorianDate.add(Duration(days: daysAfter)),adjustHijriDateByDays);

    return HijriAndGregorianDateRange(start: firstToDisplay, end: lastToDisplay);
  }

  List<HijriAndGregorianDate> _daysInRange(HijriAndGregorianDate first, HijriAndGregorianDate last) {
    final dayCount = last.gregorianDate.difference(first.gregorianDate).inDays + 1;
    return List.generate(
      dayCount,
      (index) => HijriAndGregorianDate.fromGregorianDate(DateTime.utc(first.gregorianDate.year, first.gregorianDate.month, first.gregorianDate.day + index),adjustHijriDateByDays),
    );
  }

  HijriAndGregorianDate _firstDayOfWeek(HijriAndGregorianDate week) {
    final daysBefore = _getDaysBefore(week);
    return HijriAndGregorianDate.fromGregorianDate(week.gregorianDate.subtract(Duration(days: daysBefore)),adjustHijriDateByDays);
  }

  HijriAndGregorianDate _firstDayOfMonth(HijriAndGregorianDate month) {
    return HijriAndGregorianDate.fromGregorianDate(DateTime.utc(month.gregorianDate.year, month.gregorianDate.month, 1),adjustHijriDateByDays);
  }

  HijriAndGregorianDate _lastDayOfMonth(HijriAndGregorianDate month) {
    final date = month.gregorianDate.month < 12
        ? DateTime.utc(month.gregorianDate.year, month.gregorianDate.month + 1, 1)
        : DateTime.utc(month.gregorianDate.year + 1, 1, 1);
    return HijriAndGregorianDate.fromGregorianDate(date.subtract(const Duration(days: 1)),adjustHijriDateByDays);
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
    final firstToDisplay = first.gregorianDate.subtract(Duration(days: daysBefore));

    final last = _lastDayOfMonth(focusedDay);
    final daysAfter = _getDaysAfter(last);
    final lastToDisplay = last.gregorianDate.add(Duration(days: daysAfter));

    return (lastToDisplay.difference(firstToDisplay).inDays + 1) ~/ 7;
  }

  int _getDaysBefore(HijriAndGregorianDate firstDay) {
    return (firstDay.gregorianDate.weekday + 7 - getWeekdayNumber(startingDayOfWeek)) % 7;
  }

  int _getDaysAfter(HijriAndGregorianDate lastDay) {
    int invertedStartingWeekday = 8 - getWeekdayNumber(startingDayOfWeek);

    int daysAfter = 7 - ((lastDay.gregorianDate.weekday + invertedStartingWeekday) % 7);
    if (daysAfter == 7) {
      daysAfter = 0;
    }

    return daysAfter;
  }
}
